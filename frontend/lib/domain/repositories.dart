// lib/domain/repositories.dart
import 'entities/device.dart';
import 'entities/room.dart';
import 'entities/user.dart';

// Interface cho auth repository trong tầng lõi
abstract class AuthRepository {
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

// Interface cho device repository trong tầng lõi
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

// Interface cho room repository trong tầng lõi
abstract class RoomRepository {
  Future<List<Room>> getRooms();
  Future<Room> addRoom(String name);
  Future<void> deleteRoom(int roomId);
  Future<Room> updateRoom(int roomId, String name);
}