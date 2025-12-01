// lib/presentation/providers/home_provider.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../core/error/app_error.dart';
import '../../core/usecase/usecase.dart';
import '../../domain/entities/device.dart';
import '../../domain/entities/room.dart';
import '../../domain/usecases/device_usecases.dart';
import '../../domain/usecases/room_usecases.dart';

enum AlertType { info, warning }  // Trạng thái thông báo

class AlertLog {
  final String message;
  final DateTime timestamp;
  final AlertType type;

  AlertLog({
    required this.message,
    required this.timestamp,
    required this.type,
  });

  // Convert to Json
  Map<String, dynamic> toJson() => {
        'message': message,
        'timestamp': timestamp.toIso8601String(),
        'type': type.name,
      };

  // Convert to Object
  factory AlertLog.fromJson(Map<String, dynamic> json) => AlertLog(
        message: json['message'],
        timestamp: DateTime.parse(json['timestamp']),
        type: AlertType.values.firstWhere((e) => e.name == json['type']),
      );
}

enum HomeState { Initial, Loading, Loaded, Error } // Trạng thái tổng của màn

class HomeProvider extends ChangeNotifier {
  final GetRoomsUseCase getRoomsUseCase;
  final AddRoomUseCase addRoomUseCase;
  final DeleteRoomUseCase deleteRoomUseCase;
  final UpdateRoomUseCase updateRoomUseCase;
  final AddDeviceUseCase addDeviceUseCase;
  final DeleteDeviceUseCase deleteDeviceUseCase;
  final UpdateDeviceUseCase updateDeviceUseCase;
  final FlutterSecureStorage storage;
  final SharedPreferences sharedPreferences;

  HomeProvider({
    required this.getRoomsUseCase,
    required this.addRoomUseCase,
    required this.deleteRoomUseCase,
    required this.updateRoomUseCase,
    required this.addDeviceUseCase,
    required this.deleteDeviceUseCase,
    required this.updateDeviceUseCase,
    required this.storage,
    required this.sharedPreferences,
  }) {
    _loadAlerts();
  }

  HomeState _state = HomeState.Initial;
  HomeState get state => _state;

  List<Room> _rooms = [];
  List<Room> get rooms => _rooms;

  int _selectedRoomIndex = -1;
  int get selectedRoomIndex => _selectedRoomIndex;

  Room? get selectedRoom =>
      (_selectedRoomIndex >= 0 && _rooms.isNotEmpty)
          ? _rooms[_selectedRoomIndex]
          : null;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  bool _isLoadingAction = false;
  bool get isLoadingAction => _isLoadingAction;

  WebSocketChannel? _channel;
  StreamSubscription? _channelSubscription;

  List<AlertLog> _alerts = [];
  List<AlertLog> get alerts => _alerts;

  static const _alertsKey = 'alert_logs';

  Future<void> clearLocalData() async {
    _channelSubscription?.cancel();
    _channel?.sink.close();
    _channel = null;
    _rooms.clear();
    _alerts.clear();
    _selectedRoomIndex = -1;
    _state = HomeState.Initial;
    _errorMessage = '';
    await sharedPreferences.remove(_alertsKey);
    notifyListeners();
  }

  Future<void> _saveAlerts() async {
    final List<String> alertJsonList =
        _alerts.map((alert) => jsonEncode(alert.toJson())).toList();
    await sharedPreferences.setStringList(_alertsKey, alertJsonList);
  }

  void _loadAlerts() {
    final List<String>? alertJsonList =
        sharedPreferences.getStringList(_alertsKey);
    if (alertJsonList != null) {
      _alerts = alertJsonList
          .map((alertJson) => AlertLog.fromJson(jsonDecode(alertJson)))
          .toList();
    }
  }

  void _addLog(String message, AlertType type) {
    _alerts.insert(
        0, AlertLog(message: message, timestamp: DateTime.now(), type: type));
    if (_alerts.length > 50) {
      _alerts.removeLast();
    }
    _saveAlerts();
  }

  Future<void> fetchRooms() async {
    _state = HomeState.Loading;
    notifyListeners();

    final result = await getRoomsUseCase(NoParams());

    result.fold(
      (failure) {
        _errorMessage =
            failure is ServerFailure ? failure.message : 'Unknown Error';
        _state = HomeState.Error;
      },
      (roomData) {
        _rooms = roomData;
        _state = HomeState.Loaded;
        if (_rooms.isNotEmpty) {
          _selectedRoomIndex = 0;
          connectToWebSocket(_rooms.first.id);
        } else {
          _selectedRoomIndex = -1;
        }
      },
    );
    notifyListeners();
  }

  void selectRoom(int index) {
    if (index >= 0 && index < _rooms.length) {
      _selectedRoomIndex = index;
      connectToWebSocket(_rooms[index].id);
      notifyListeners();
    }
  }

  Future<void> connectToWebSocket(int roomId) async {
    _channelSubscription?.cancel();
    _channel?.sink.close();

    final token = await storage.read(key: 'access_token');
    if (token == null) {
      print('WebSocket Error: Authentication token not found.');
      return;
    }

    final uri = Uri(
      scheme: 'wss',
      host: 'mrh3.dongnama.app',
      path: '/ws/devices/$roomId/',
      queryParameters: {'token': token},
    );

    print('Connecting to WebSocket: $uri');

    _channel = WebSocketChannel.connect(uri);

    _channelSubscription = _channel!.stream.listen((message) {
      final data = jsonDecode(message);
      if (data.containsKey('error')) {
        print('WebSocket received error: ${data['error']}');
        return;
      }
      final int deviceId = data['device_id'];
      final bool isOn = data['is_on'];
      final Map<String, dynamic> attributes = data['attributes'] ?? {};
      attributes['is_on'] = isOn;

      _updateDeviceStateLocally(deviceId, attributes);
    }, onError: (error) {
      print('WebSocket Error: $error');
    }, onDone: () {
      print('WebSocket Disconnected');
    });
  }

  void updateDeviceState(int deviceId, Map<String, dynamic> newAttributes) {
    if (_channel != null) {
      final message = jsonEncode({
        'device_id': deviceId,
        'attributes': newAttributes,
      });
      _channel!.sink.add(message);
      _updateDeviceStateLocally(deviceId, newAttributes);
    }
  }

  void toggleDeviceStatus(int deviceId, bool newStatus) {
    updateDeviceState(deviceId, {'is_on': newStatus});
  }

  void _updateDeviceStateLocally(
      int deviceId, Map<String, dynamic> attributes) {
    for (int roomIndex = 0; roomIndex < _rooms.length; roomIndex++) {
      final deviceIndex =
          _rooms[roomIndex].devices.indexWhere((d) => d.id == deviceId);

      if (deviceIndex != -1) {
        final currentDevice = _rooms[roomIndex].devices[deviceIndex];
        Device updatedDevice;

        final bool? newIsOn = attributes['is_on'] as bool?;
        if (newIsOn != null && newIsOn != currentDevice.isOn) {
          final roomName = _rooms[roomIndex].name;
          _addLog(
            '${currentDevice.name} in "$roomName" was turned ${newIsOn ? 'ON' : 'OFF'}.',
            AlertType.info,
          );
        }

        if (currentDevice is DimmableLightDevice) {
          final int? newBrightness = attributes['brightness'] as int?;
          if (newBrightness != null && newBrightness > 90) {
            final roomName = _rooms[roomIndex].name;
            _addLog(
              'Warning: ${currentDevice.name} in "$roomName" brightness is at $newBrightness% (above 90% threshold).',
              AlertType.warning,
            );
          }
        }

        if (currentDevice is DimmableLightDevice) {
          updatedDevice = currentDevice.copyWith(
            isOn: attributes['is_on'] as bool? ?? currentDevice.isOn,
            brightness:
                attributes['brightness'] as int? ?? currentDevice.brightness,
          );
        } else {
          updatedDevice = currentDevice.copyWith(
            isOn: attributes['is_on'] as bool? ?? currentDevice.isOn,
          );
        }

        final newDevices = List<Device>.from(_rooms[roomIndex].devices);
        newDevices[deviceIndex] = updatedDevice;

        _rooms[roomIndex] = _rooms[roomIndex].copyWith(devices: newDevices);
        break;
      }
    }
    notifyListeners();
  }

  Device? findDeviceById(int deviceId) {
    try {
      for (final room in _rooms) {
        final device = room.devices.cast<Device?>().firstWhere(
              (d) => d?.id == deviceId,
              orElse: () => null,
            );
        if (device != null) return device;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> addNewRoom(String name) async {
    _isLoadingAction = true;
    notifyListeners();
    final result = await addRoomUseCase(AddRoomParams(name: name));
    _isLoadingAction = false;

    return result.fold(
      (failure) {
        _errorMessage =
            failure is ServerFailure ? failure.message : 'Failed to add room';
        notifyListeners();
        return false;
      },
      (newRoom) {
        _rooms.add(newRoom);
        _selectedRoomIndex = _rooms.length - 1;
        connectToWebSocket(newRoom.id);
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> removeSelectedRoom() async {
    if (selectedRoom == null) return false;

    _isLoadingAction = true;
    notifyListeners();
    final result =
        await deleteRoomUseCase(DeleteRoomParams(roomId: selectedRoom!.id));
    _isLoadingAction = false;

    return result.fold(
      (failure) {
        _errorMessage = failure is ServerFailure
            ? failure.message
            : 'Failed to delete room';
        notifyListeners();
        return false;
      },
      (_) {
        _rooms.removeAt(_selectedRoomIndex);
        _selectedRoomIndex = _rooms.isNotEmpty ? 0 : -1;
        if (selectedRoom != null) {
          connectToWebSocket(selectedRoom!.id);
        } else {
          _channelSubscription?.cancel();
          _channel?.sink.close();
          _channel = null;
        }
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> addNewDevice(
    String name,
    String subtitle,
    String iconAsset,
    DeviceType deviceType,
  ) async {
    if (selectedRoom == null) return false;

    _isLoadingAction = true;
    notifyListeners();

    final params = AddDeviceParams(
        name: name,
        subtitle: subtitle,
        iconAsset: iconAsset,
        roomId: selectedRoom!.id,
        deviceType: deviceType);
    final result = await addDeviceUseCase(params);
    _isLoadingAction = false;

    return result.fold(
      (failure) {
        _errorMessage =
            failure is ServerFailure ? failure.message : 'Failed to add device';
        notifyListeners();
        return false;
      },
      (newDevice) {
        final roomIndex =
            _rooms.indexWhere((room) => room.id == selectedRoom!.id);
        if (roomIndex != -1) {
          final updatedDevices = List<Device>.from(_rooms[roomIndex].devices)
            ..add(newDevice);
          _rooms[roomIndex] =
              _rooms[roomIndex].copyWith(devices: updatedDevices);
        }
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> removeDevice(int deviceId) async {
    _isLoadingAction = true;
    notifyListeners();
    final result =
        await deleteDeviceUseCase(DeleteDeviceParams(deviceId: deviceId));
    _isLoadingAction = false;

    return result.fold((failure) {
      _errorMessage = failure is ServerFailure
          ? failure.message
          : 'Failed to delete device';
      notifyListeners();
      return false;
    }, (_) {
      final roomIndex = _rooms.indexWhere(
          (room) => room.devices.any((device) => device.id == deviceId));

      if (roomIndex != -1) {
        final updatedDevices = List<Device>.from(_rooms[roomIndex].devices)
          ..removeWhere((d) => d.id == deviceId);
        _rooms[roomIndex] =
            _rooms[roomIndex].copyWith(devices: updatedDevices);
      }
      notifyListeners();
      return true;
    });
  }

  Future<bool> updateRoomName(int roomId, String newName) async {
    _isLoadingAction = true;
    notifyListeners();
    final result = await updateRoomUseCase(UpdateRoomParams(id: roomId, name: newName));
    _isLoadingAction = false;

    return result.fold(
      (failure) {
        _errorMessage =
            failure is ServerFailure ? failure.message : 'Failed to update room';
        notifyListeners();
        return false;
      },
      (updatedRoom) {
        final index = _rooms.indexWhere((room) => room.id == roomId);
        if (index != -1) {
          _rooms[index] = _rooms[index].copyWith(name: updatedRoom.name);
        }
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> updateDeviceDetails(
      int deviceId, String newName, String newSubtitle) async {
    _isLoadingAction = true;
    notifyListeners();
    final result = await updateDeviceUseCase(UpdateDeviceParams(
        id: deviceId, name: newName, subtitle: newSubtitle));
    _isLoadingAction = false;

    return result.fold(
      (failure) {
        _errorMessage = failure is ServerFailure
            ? failure.message
            : 'Failed to update device';
        notifyListeners();
        return false;
      },
      (updatedDevice) {
        for (int i = 0; i < _rooms.length; i++) {
          final deviceIndex =
              _rooms[i].devices.indexWhere((d) => d.id == deviceId);
          if (deviceIndex != -1) {
            final newDevices = List<Device>.from(_rooms[i].devices);
            
            newDevices[deviceIndex] = newDevices[deviceIndex].copyWith(
              name: updatedDevice.name,
              subtitle: updatedDevice.subtitle,
            );
            _rooms[i] = _rooms[i].copyWith(devices: newDevices);
            break;
          }
        }
        notifyListeners();
        return true;
      },
    );
  }

  @override
  void dispose() {
    _channelSubscription?.cancel();
    _channel?.sink.close();
    super.dispose();
  }
}