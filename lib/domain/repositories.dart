// lib/domain/repositories.dart
import 'entities/device.dart';
import 'entities/room.dart';
import 'entities/user.dart';

//--- Auth Repository ---
abstract class AuthRepository {
  // Login xong không cần trả về gì, lỗi thì throw, thành công thì thôi
  Future<void> login(String email, String password); 
  
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String password2,
    required String phoneNumber,
  });

  Future<User> getUserProfile();
  
  Future<User> updateUserProfile({
    required String name,
    required String phoneNumber,
  });
}

//--- Device Repository ---
abstract class DeviceRepository {
  Future<Device> addDevice(
    String name,
    String subtitle,
    String iconAsset,
    int roomId,
    DeviceType deviceType,
  );
  
  Future<void> deleteDevice(int deviceId);
  
  Future<Device> updateDevice(
    int deviceId,
    String name,
    String subtitle,
  );
}

//--- Room Repository ---
abstract class RoomRepository {
  Future<List<Room>> getRooms();
  Future<Room> addRoom(String name);
  Future<void> deleteRoom(int roomId);
  Future<Room> updateRoom(int roomId, String name);
}