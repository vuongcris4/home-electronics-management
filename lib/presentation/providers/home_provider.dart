// lib/presentation/providers/home_provider.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_home/core/constants/app_config.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../domain/entities/device.dart';
import '../../domain/entities/room.dart';
import '../../domain/repositories.dart';

// --- ENUMS & MODELS ---
enum AlertType { info }

// Entity AlertLog
class AlertLog {
  final String message;
  final DateTime timestamp;
  final AlertType type;

  AlertLog({
    required this.message,
    required this.timestamp,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
        'message': message,
        'timestamp': timestamp.toIso8601String(),
        'type': type.name,
      };

  factory AlertLog.fromJson(Map<String, dynamic> json) => AlertLog(
        message: json['message'],
        timestamp: DateTime.parse(json['timestamp']),
        // [UPDATE] Fallback về info nếu json cũ có warning
        type: AlertType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => AlertType.info,
        ),
      );
}

// Lifecycle của màn hình
enum HomeState { Initial, Loading, Loaded, Error }

// --- PROVIDER ---
class HomeProvider extends ChangeNotifier {
  final RoomRepository roomRepository;
  final DeviceRepository deviceRepository;

  final FlutterSecureStorage storage;
  final SharedPreferences sharedPreferences;

  HomeProvider({
    required this.roomRepository,
    required this.deviceRepository,
    required this.storage,
    required this.sharedPreferences,
  }) {
    _loadAlerts();
  }

  // --- STATES ---
  HomeState _state = HomeState.Initial;
  HomeState get state => _state;

  List<Room> _rooms = [];
  List<Room> get rooms => _rooms;

  int _selectedRoomIndex = -1;
  int get selectedRoomIndex => _selectedRoomIndex;

  Room? get selectedRoom => (_selectedRoomIndex >= 0 && _rooms.isNotEmpty)
      ? _rooms[_selectedRoomIndex]
      : null;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  bool _isLoadingAction = false;
  bool get isLoadingAction => _isLoadingAction;

  // WebSocket
  WebSocketChannel? _channel;
  StreamSubscription? _channelSubscription;

  // Alerts
  List<AlertLog> _alerts = [];
  List<AlertLog> get alerts => _alerts;
  static const _alertsKey = 'alert_logs';

  // --- HELPER METHODS ---

  Future<void> clearLocalData() async {
    _channelSubscription?.cancel(); // Ngừng lắng nghe dữ liệu trả về
    _channel?.sink.close(); // Ngắt kết nối hoàn toàn với _channel
    _channel = null;
    _rooms.clear();
    _alerts.clear();
    _selectedRoomIndex = -1;
    _state = HomeState.Initial;
    _errorMessage = '';
    await sharedPreferences.remove(_alertsKey);
    notifyListeners();
  }

  // Hàm giúp lưu danh sách Alerts vào sharedPreferences
  Future<void> _saveAlerts() async {
    final List<String> alertJsonList =
        _alerts.map((alert) => jsonEncode(alert.toJson())).toList();
    await sharedPreferences.setStringList(_alertsKey, alertJsonList);
  }

  // Hàm giúp load Alerts từ sharedPreferences
  void _loadAlerts() {
    final List<String>? alertJsonList =
        sharedPreferences.getStringList(_alertsKey);
    if (alertJsonList != null) {
      _alerts = alertJsonList
          .map((alertJson) => AlertLog.fromJson(jsonDecode(alertJson)))
          .toList();
    }
  }

  // Thêm log vào đầu danh sách và lưu danh sách
  void _addLog(String message, AlertType type) {
    _alerts.insert(
        0, AlertLog(message: message, timestamp: DateTime.now(), type: type));
    if (_alerts.length > 50) {
      _alerts.removeLast();
    }
    _saveAlerts();
  }

  // Chọn 0<=Room<length, kết nối tới Websocket _rooms[index] 
  void selectRoom(int index) {
    if (index >= 0 && index < _rooms.length) {
      _selectedRoomIndex = index;
      connectToWebSocket(_rooms[index].id);
      notifyListeners();
    }
  }

  // Tìm kiếm một thiết bị cụ thể dựa trên ID (deviceId) trong danh sách các phòng (_rooms)
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

  // --- API / REPOSITORY METHODS (Using Try-Catch) ---
  // Các màn hình thì luôn theo thứ tự trạng thái Loading -> Loaded -> Error

  // Ban đầu lấy danh sách các phòng, select phòng đầu tiên, kết nối websocket tới phòng đó.
  Future<void> fetchRooms() async {
    _state = HomeState.Loading;
    notifyListeners();

    try {
      _rooms = await roomRepository.getRooms();
      _state = HomeState.Loaded;

      if (_rooms.isNotEmpty) {
        _selectedRoomIndex = 0;
        connectToWebSocket(_rooms.first.id);
      } else {
        _selectedRoomIndex = -1;
      }
    } catch (e) {
      // Loại bỏ tiền tố "Exception: " để message sạch đẹp hơn
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      _state = HomeState.Error;
    }
    notifyListeners();
  }

  // _isLoadingAction: true -> false -> true
  // Thêm phòng mới
  Future<bool> addNewRoom(String name) async {
    _isLoadingAction = true;
    notifyListeners();

    try {
      // Thêm phòng mới, tự select phòng vừa mới thêm, và kết nối WebSocket tới.
      final newRoom = await roomRepository.addRoom(name);
      _rooms.add(newRoom);
      _selectedRoomIndex = _rooms.length - 1;
      connectToWebSocket(newRoom.id);
      
      _isLoadingAction = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      _isLoadingAction = false;
      notifyListeners();
      return false;
    }
  }

  // Xoá phòng đang được Select, giảm _selectedRoomIndex xuống -1
  Future<bool> removeSelectedRoom() async {
    if (selectedRoom == null) return false;
    _isLoadingAction = true;
    notifyListeners();

    try {
      await roomRepository.deleteRoom(selectedRoom!.id);
      _rooms.removeAt(_selectedRoomIndex);
      _selectedRoomIndex = _rooms.isNotEmpty ? 0 : -1;
      
      if (selectedRoom != null) {
        connectToWebSocket(selectedRoom!.id);
      } else {
        _channelSubscription?.cancel();
        _channel?.sink.close();
        _channel = null;
      }

      _isLoadingAction = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      _isLoadingAction = false;
      notifyListeners();
      return false;
    }
  }

  // Thêm mới device
  Future<bool> addNewDevice(
    String name,
    String subtitle,
    String iconAsset,
    DeviceType deviceType,
  ) async {
    if (selectedRoom == null) return false;

    _isLoadingAction = true;
    notifyListeners();

    try {
      final newDevice = await deviceRepository.addDevice(
        name,
        subtitle,
        iconAsset,
        selectedRoom!.id,
        deviceType,
      );

      // Cập nhật local list
      final roomIndex =
          _rooms.indexWhere((room) => room.id == selectedRoom!.id);
      if (roomIndex != -1) {
        final updatedDevices = List<Device>.from(_rooms[roomIndex].devices)
          ..add(newDevice);
          // UI (Provider / ChangeNotifier / Riverpod…) chỉ nhận ra thay đổi khi có object mới. Nếu bạn sửa trực tiếp list devices cũ, UI có thể không rebuild. Việc tạo list mới + copyWith đảm bảo Flutter hiểu rằng state đã thay đổi.
        _rooms[roomIndex] =
            _rooms[roomIndex].copyWith(devices: updatedDevices);
      }

      _isLoadingAction = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      _isLoadingAction = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeDevice(int deviceId) async {
    _isLoadingAction = true;
    notifyListeners();

    try {
      await deviceRepository.deleteDevice(deviceId);

      // Cập nhật local list
      final roomIndex = _rooms.indexWhere(
          (room) => room.devices.any((device) => device.id == deviceId));

      if (roomIndex != -1) {
        final updatedDevices = List<Device>.from(_rooms[roomIndex].devices)
          ..removeWhere((d) => d.id == deviceId);
        _rooms[roomIndex] =
            _rooms[roomIndex].copyWith(devices: updatedDevices);
      }

      _isLoadingAction = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      _isLoadingAction = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateRoomName(int roomId, String newName) async {
    _isLoadingAction = true;
    notifyListeners();

    try {
      final updatedRoom = await roomRepository.updateRoom(roomId, newName);

      final index = _rooms.indexWhere((room) => room.id == roomId);
      if (index != -1) {
        _rooms[index] = _rooms[index].copyWith(name: updatedRoom.name);
      }

      _isLoadingAction = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      _isLoadingAction = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateDeviceDetails(
      int deviceId, String newName, String newSubtitle) async {
    _isLoadingAction = true;
    notifyListeners();

    try {
      final updatedDevice = await deviceRepository.updateDevice(
          deviceId, newName, newSubtitle);

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

      _isLoadingAction = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      _isLoadingAction = false;
      notifyListeners();
      return false;
    }
  }

  // --- WEBSOCKET LOGIC ---
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
      host: AppConfig.apiHost,
      path: '/ws/devices/$roomId/', // Chuyển room thì đổi websocket qua room khác
      queryParameters: {'token': token},  // Có token nên phân biệt được giữa các user với nhau
    );

    print('Connecting to WebSocket: $uri');

    // Trả về một WebSocketChannel
    _channel = WebSocketChannel.connect(uri);

    // Lắng nghe WebSocket truyền dữ liệu
    _channelSubscription = _channel!.stream.listen((message) {
      final data = jsonDecode(message); // string decode về json
      // Nếu backend gửi error thì chỉ print lỗi
      if (data.containsKey('error')) {
        print('WebSocket received error: ${data['error']}');
        return;
      }
      final int deviceId = data['device_id'];
      final bool isOn = data['is_on'];
      final Map<String, dynamic> attributes = data['attributes'] ?? {};
      attributes['is_on'] = isOn;

      _updateDeviceStateLocally(deviceId, attributes);  // {attributes: is_on:}
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

  // Tìm thiết bị trong danh sách _rooms
  // Cập nhật trạng thái mới (is_on, brightness,... )
  // Ghi log khi thiết bị bật/ tắt
  // Thông báo UI cập nhật (notifyListeners())
  void _updateDeviceStateLocally(
      int deviceId, Map<String, dynamic> attributes) {
    for (int roomIndex = 0; roomIndex < _rooms.length; roomIndex++) {
      final deviceIndex =
          _rooms[roomIndex].devices.indexWhere((d) => d.id == deviceId);

      if (deviceIndex != -1) {
        final currentDevice = _rooms[roomIndex].devices[deviceIndex];
        Device updatedDevice;

        // attributes là JSON server gửi (trong websocket). Có thể có is_on hoặc không. Dùng kiểu bool? cho an toàn
        final bool? newIsOn = attributes['is_on'] as bool?;
        
        // Chỉ ghi log khi server gửi is_on hợp lệ. Và trạng thái thay đổi.
        if (newIsOn != null && newIsOn != currentDevice.isOn) {
          final roomName = _rooms[roomIndex].name;
          _addLog(
            '${currentDevice.name} in "$roomName" was turned ${newIsOn ? 'ON' : 'OFF'}.',
            AlertType.info,
          );
        }

        // Nếu là đèn có thay đổi độ sáng. Update isOn. Update brightness nếu server trả về.
        // Nếu không có, giữ giá trị cũ.
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

  @override
  void dispose() {
    _channelSubscription?.cancel();
    _channel?.sink.close();
    super.dispose();
  }
}