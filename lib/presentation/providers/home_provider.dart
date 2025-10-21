// d:/ute/home_electronis_management/lib/presentation/providers/home_provider.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../core/error/failures.dart';
import '../../core/usecase/usecase.dart';
import '../../domain/entities/device.dart';
import '../../domain/entities/room.dart';
import '../../domain/usecases/get_rooms_usecase.dart';
// Giả định bạn đã tạo các file usecase này theo hướng dẫn
import '../../domain/usecases/add_device_usecase.dart';
import '../../domain/usecases/add_room_usecase.dart';
import '../../domain/usecases/delete_device_usecase.dart';
import '../../domain/usecases/delete_room_usecase.dart';


enum HomeState { Initial, Loading, Loaded, Error }

class HomeProvider extends ChangeNotifier {
  final GetRoomsUseCase getRoomsUseCase;
  // Thêm các use case mới
  final AddRoomUseCase addRoomUseCase;
  final DeleteRoomUseCase deleteRoomUseCase;
  final AddDeviceUseCase addDeviceUseCase;
  final DeleteDeviceUseCase deleteDeviceUseCase;
  final FlutterSecureStorage storage;


  HomeProvider({
    required this.getRoomsUseCase,
    required this.addRoomUseCase,
    required this.deleteRoomUseCase,
    required this.addDeviceUseCase,
    required this.deleteDeviceUseCase,
    required this.storage,
  });

  HomeState _state = HomeState.Initial;
  HomeState get state => _state;

  List<Room> _rooms = [];
  List<Room> get rooms => _rooms;

  int _selectedRoomIndex = -1; // Bắt đầu bằng -1 để không có phòng nào được chọn
  int get selectedRoomIndex => _selectedRoomIndex;

  Room? get selectedRoom => (_selectedRoomIndex >= 0 && _rooms.isNotEmpty) ? _rooms[_selectedRoomIndex] : null;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;
  
  bool _isLoadingAction = false; // Thêm state để xử lý loading cho các action
  bool get isLoadingAction => _isLoadingAction;

  WebSocketChannel? _channel;
  StreamSubscription? _channelSubscription;

  Future<void> fetchRooms() async {
    _state = HomeState.Loading;
    notifyListeners();

    final result = await getRoomsUseCase(NoParams());

    result.fold(
      (failure) {
        _errorMessage = failure is ServerFailure ? failure.message : 'Unknown Error';
        _state = HomeState.Error;
      },
      (roomData) {
        _rooms = roomData;
        _state = HomeState.Loaded;
        if (_rooms.isNotEmpty) {
           // Tự động chọn phòng đầu tiên
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
      // Kết nối lại WebSocket cho phòng mới được chọn
      connectToWebSocket(_rooms[index].id);
      notifyListeners();
    }
  }
  
  Future<void> connectToWebSocket(int roomId) async {
    // Đóng kết nối cũ nếu có
    _channelSubscription?.cancel();
    _channel?.sink.close();

    // Lấy token từ storage
    final token = await storage.read(key: 'access_token');
    if (token == null) {
      print('WebSocket Error: Authentication token not found.');
      return;
    }

    // Dùng cách này để tạo URI - An toàn và chính xác hơn
    final uri = Uri(
      scheme: 'wss',
      host: 'mrh3.dongnama.app',
      path: '/ws/devices/$roomId/',
      // Gửi token qua query parameter để backend xác thực
      queryParameters: { 'token': token },
    );
    
    print('Connecting to WebSocket: $uri'); // In ra để kiểm tra URL

    _channel = WebSocketChannel.connect(uri);

    _channelSubscription = _channel!.stream.listen((message) {
      final data = jsonDecode(message);
      // Kiểm tra xem có lỗi từ backend không
      if (data.containsKey('error')) {
        print('WebSocket received error: ${data['error']}');
        return;
      }
      final int deviceId = data['device_id'];
      final bool isOn = data['is_on'];
      _updateDeviceStatusLocally(deviceId, isOn);
    },
    onError: (error) {
      print('WebSocket Error: $error');
    },
    onDone: () {
      print('WebSocket Disconnected');
    });
  }

  void toggleDeviceStatus(int deviceId, bool newStatus) {
    if (_channel != null) {
      final message = jsonEncode({
        'device_id': deviceId,
        'is_on': newStatus,
      });
      _channel!.sink.add(message);
      // Cập nhật UI ngay lập tức
      _updateDeviceStatusLocally(deviceId, newStatus);
    }
  }
  
  Future<bool> addNewRoom(String name) async {
    _isLoadingAction = true;
    notifyListeners();
    final result = await addRoomUseCase(AddRoomParams(name: name));
    _isLoadingAction = false;

    return result.fold(
      (failure) {
        _errorMessage = failure is ServerFailure ? failure.message : 'Failed to add room';
        notifyListeners();
        return false;
      },
      (newRoom) {
        _rooms.add(newRoom);
        // Tự động chuyển đến phòng mới tạo
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
    final result = await deleteRoomUseCase(DeleteRoomParams(roomId: selectedRoom!.id));
    _isLoadingAction = false;
    
    return result.fold(
      (failure) {
        _errorMessage = failure is ServerFailure ? failure.message : 'Failed to delete room';
        notifyListeners();
        return false;
      },
      (_) {
        _rooms.removeAt(_selectedRoomIndex);
        // Chuyển về phòng đầu tiên hoặc trạng thái rỗng
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

  Future<bool> addNewDevice(String name, String subtitle, String iconAsset) async {
     if (selectedRoom == null) return false;
      
    _isLoadingAction = true;
    notifyListeners();

    final params = AddDeviceParams(name: name, subtitle: subtitle, iconAsset: iconAsset, roomId: selectedRoom!.id);
    final result = await addDeviceUseCase(params);
    _isLoadingAction = false;

    return result.fold(
      (failure) {
      _errorMessage = failure is ServerFailure ? failure.message : 'Failed to add device';
      notifyListeners();
      return false;
      },
      (newDevice) {
        final roomIndex = _rooms.indexWhere((room) => room.id == selectedRoom!.id);
        if (roomIndex != -1) {
            final updatedDevices = List<Device>.from(_rooms[roomIndex].devices)..add(newDevice);
            _rooms[roomIndex] = Room(id: _rooms[roomIndex].id, name: _rooms[roomIndex].name, devices: updatedDevices);
        }
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> removeDevice(int deviceId) async {
    if (selectedRoom == null) return false;
    
     _isLoadingAction = true;
    notifyListeners();
    final result = await deleteDeviceUseCase(DeleteDeviceParams(deviceId: deviceId));
    _isLoadingAction = false;

    return result.fold(
      (failure) {
        _errorMessage = failure is ServerFailure ? failure.message : 'Failed to delete device';
        notifyListeners();
        return false;
      },
      (_) {
        final roomIndex = _rooms.indexWhere((room) => room.id == selectedRoom!.id);
        if (roomIndex != -1) {
            final updatedDevices = List<Device>.from(_rooms[roomIndex].devices)..removeWhere((d) => d.id == deviceId);
            _rooms[roomIndex] = Room(id: _rooms[roomIndex].id, name: _rooms[roomIndex].name, devices: updatedDevices);
        }
        notifyListeners();
        return true;
      }
    );
  }

  void _updateDeviceStatusLocally(int deviceId, bool isOn) {
      if (selectedRoom == null) return;
      
      final roomIndex = _rooms.indexWhere((room) => room.id == selectedRoom!.id);
      if(roomIndex == -1) return;

      final deviceIndex = _rooms[roomIndex].devices.indexWhere((d) => d.id == deviceId);
      if (deviceIndex != -1) {
          final updatedDevice = _rooms[roomIndex].devices[deviceIndex].copyWith(isOn: isOn);
          final newDevices = List<Device>.from(_rooms[roomIndex].devices);
          newDevices[deviceIndex] = updatedDevice;
          
          _rooms[roomIndex] = Room(
               id: _rooms[roomIndex].id,
               name: _rooms[roomIndex].name,
               devices: newDevices
          );

          notifyListeners();
      }
  }

  @override
  void dispose() {
    _channelSubscription?.cancel();
    _channel?.sink.close();
    super.dispose();
  }
}