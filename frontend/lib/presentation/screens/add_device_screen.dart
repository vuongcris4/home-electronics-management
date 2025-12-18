// Lưu Ngọc Thiện

// lib/presentation/screens/add_device_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/device.dart'; 
import '../providers/home_provider.dart';

// --- Các hằng số màu sắc và style cho nhất quán ---
// Định nghĩa màu chính của ứng dụng.
const Color kPrimaryColor = Color(0xFF2666DE);
// Định nghĩa màu chữ phụ (thường dùng cho text mờ, hint).
const Color kTextColorSecondary = Color(0xFF6F7EA8);
// Định nghĩa màu cho đường viền (border).
const Color kBorderColor = Color(0xFFCFCFCF);
// Định nghĩa màu cho nhãn (label) của các ô text field.
const Color kLabelColor = Color(0xFF13304A);

// --- Dữ liệu giả lập cho các icon ---
// Một class (lớp) đơn giản để chứa thông tin cho mỗi icon.
class IconInfo {
  final IconData iconData;
  final String label;
  final String assetName;

  IconInfo(
      {required this.iconData, required this.label, required this.assetName});
}

// Một danh sách (List) các đối tượng IconInfo, định nghĩa các icon có sẵn để chọn.
final List<IconInfo> availableIcons = [
  IconInfo(
      iconData: Icons.lightbulb_outline,
      label: 'Light',
      assetName: 'lightbulb.png'),
  IconInfo(
      iconData: Icons.air, label: 'Cooler', assetName: 'air_conditioner.png'),
  IconInfo(iconData: Icons.tv, label: 'TV', assetName: 'tv.png'),
  IconInfo(iconData: Icons.wifi, label: 'Wifi', assetName: 'wifi.png'),
  IconInfo(
      iconData: Icons.music_note, label: 'Music', assetName: 'speaker.png'),
  IconInfo(iconData: Icons.power, label: 'Other', assetName: 'power.png'),
];

// Định nghĩa màn hình AddDeviceScreen là một StatefulWidget.
// (Stateful vì trạng thái của nó thay đổi: text trong ô input, icon được chọn).
class AddDeviceScreen extends StatefulWidget {
  // Constructor cho AddDeviceScreen.
  const AddDeviceScreen({super.key});

  // Ghi đè phương thức createState để tạo đối tượng State cho widget này.
  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

// Đây là class State, nơi chứa toàn bộ trạng thái và logic của màn hình.
class _AddDeviceScreenState extends State<AddDeviceScreen> {
  final _nameController = TextEditingController();
  final _noteController = TextEditingController();
  String _selectedIconAsset = availableIcons.first.assetName;

  // Hàm dispose được gọi khi widget bị gỡ khỏi cây widget (ví dụ: khi đóng màn hình).
  @override
  void dispose() {
    // "Huỷ" các controller để giải phóng tài nguyên, tránh rò rỉ bộ nhớ.
    _nameController.dispose();
    _noteController.dispose();
    // Gọi hàm dispose của lớp cha.
    super.dispose();
  }

  // Hàm xử lý logic khi người dùng nhấn nút "Add".
  // `async` vì nó sẽ gọi một hàm bất đồng bộ (await provider.addNewDevice).
  void _addDevice() async {
    // Kiểm tra (validate) xem ô tên có trống không (sau khi đã cắt khoảng trắng).
    if (_nameController.text.trim().isEmpty) {
      // Nếu trống, hiển thị một thông báo lỗi (SnackBar) ở cuối màn hình.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Device name cannot be empty.'),
            backgroundColor: Colors.red),
      );
      return;
    }

    // Lấy HomeProvider từ cây widget.
    // không cần build lại màn hình này khi HomeProvider thay đổi.
    final provider = Provider.of<HomeProvider>(context, listen: false);

    // Ghi chú: Xác định loại thiết bị dựa trên icon đã chọn.
    // Đây là logic nghiệp vụ đơn giản: nếu icon là 'lightbulb.png'...
    final deviceType = _selectedIconAsset == 'lightbulb.png'
        ? DeviceType.dimmableLight // ...thì gán loại là đèn có thể điều chỉnh độ sáng.
        : DeviceType.binarySwitch; // ...nếu không, gán là công tắc (bật/tắt).

    // Gọi hàm `addNewDevice` từ provider và chờ (await) kết quả trả về (true/false).
    final success = await provider.addNewDevice(
      _nameController.text.trim(), // Truyền tên thiết bị (đã cắt khoảng trắng).
      _noteController.text.trim(), // Truyền ghi chú (đã cắt khoảng trắng).
      'assets/icons/$_selectedIconAsset', // Tạo đường dẫn asset đầy đủ (ví dụ: 'assets/icons/tv.png').
      deviceType, // Truyền loại thiết bị đã xác định ở trên.
    );

    // Điều này để tránh lỗi nếu người dùng đã back ra khỏi màn hình trong khi đang chờ.
    if (mounted) {
      // Nếu thêm thành công (success == true).
      if (success) {
        // Đóng màn hình hiện tại (quay lại màn hình trước đó).
        Navigator.of(context).pop();
      } else {
        // Nếu thêm thất bại, hiển thị SnackBar lỗi.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              // Lấy thông báo lỗi cụ thể từ provider.
              content: Text('Failed to add device: ${provider.errorMessage}'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  // Hàm `build` chịu trách nhiệm xây dựng giao diện người dùng (UI).
  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<HomeProvider>().isLoadingAction;

    // Trả về Scaffold, là cấu trúc cơ bản của một màn hình Material Design.
    return Scaffold(
      backgroundColor: Colors.white, // Đặt màu nền là trắng.
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 35.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.black),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Add Device',
                  textAlign: TextAlign.center, 
                  style: TextStyle(
                    color: Color(0xFF404040),
                    fontSize: 32,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 60),
                _CustomTextField(
                  label: 'Name Device',
                  hint: 'Name Device',
                  controller: _nameController,
                ),
                const SizedBox(height: 30),
                _CustomTextField(
                  label: 'Note',
                  hint: 'Note (e.g. brand, location)',
                  controller: _noteController,
                ),
                const SizedBox(height: 60),
                const Text(
                  'Select Icon',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 30),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal, 
                  child: Row(
                    // `map` để biến đổi mỗi `iconInfo` trong list `availableIcons`...
                    children: availableIcons.map((iconInfo) {
                      // ...thành một widget `_IconSelectionButton` với padding.
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: _IconSelectionButton(
                          icon: iconInfo.iconData, // Truyền icon.
                          label: iconInfo.label, // Truyền nhãn.
                          // Kiểm tra xem icon này có đang được chọn không.
                          isSelected: _selectedIconAsset == iconInfo.assetName,
                          // Hàm được gọi khi nhấn vào icon này.
                          onTap: () {
                            // Gọi `setState` để thông báo cho Flutter rằng state đã thay đổi
                            // và cần build lại UI.
                            setState(() {
                              // Cập nhật biến `_selectedIconAsset` bằng asset của icon vừa nhấn.
                              _selectedIconAsset = iconInfo.assetName;
                            });
                          },
                        ),
                      );
                    }).toList(), // Chuyển kết quả của `map` thành một `List<Widget>`.
                  ),
                ),
                // Khoảng đệm dọc 80px.
                const SizedBox(height: 80),
                // Nút bấm "Add".
                ElevatedButton(
                  // Xử lý khi nhấn:
                  // Nếu đang `isLoading` (true), gán `onPressed` là `null` (vô hiệu hóa nút).
                  // Nếu không (false), gán hàm `_addDevice` để thực thi.
                  onPressed: isLoading ? null : _addDevice,
                  // Style cho nút.
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor, // Màu nền của nút.
                    padding: const EdgeInsets.symmetric(
                        vertical: 19), // Đệm bên trong nút.
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(14), // Bo góc 14px.
                    ),
                  ),
                  // Nội dung bên trong nút (child).
                  child: isLoading
                      // Nếu `isLoading` là true: hiển thị vòng xoay loading.
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      // Nếu `isLoading` là false: hiển thị chữ "Add".
                      : const Text(
                          'Add',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
                // Khoảng đệm 40px ở dưới cùng.
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Định nghĩa một widget custom (tái sử dụng) cho ô nhập liệu.
// Đây là `StatelessWidget` vì nó không tự quản lý trạng thái
// (trạng thái được truyền vào qua `TextEditingController`).
class _CustomTextField extends StatelessWidget {
  final String label; // Nhãn (ví dụ: 'Name Device')
  final String hint; // Chữ gợi ý (ví dụ: 'Enter name...')
  final TextEditingController controller; // Controller để quản lý text.

  // Constructor.
  const _CustomTextField({
    required this.label,
    required this.hint,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    // Sử dụng `Stack` để xếp chồng `TextField` và `Text` (label).
    // Điều này cho phép label "nổi" lên trên đường viền của TextField.
    return Stack(
      // `Clip.none` cho phép `label` (con) được vẽ bên ngoài ranh giới của `Stack` (cha).
      clipBehavior: Clip.none,
      children: [
        // Widget TextField cơ bản.
        TextField(
          controller: controller, // Gắn controller.
          decoration: InputDecoration(
            hintText: hint, // Đặt text gợi ý.
            hintStyle: const TextStyle(color: kBorderColor), // Style cho hint.
            // Đệm bên trong TextField (giữa text và đường viền).
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 32, vertical: 19),
            // Style cho đường viền khi TextField *không* được focus.
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32), // Bo góc 32.
              borderSide:
                  const BorderSide(color: kBorderColor, width: 1), // Viền xám.
            ),
            // Style cho đường viền khi TextField *đang* được focus.
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32),
              borderSide: const BorderSide(
                  color: kPrimaryColor, width: 1.5), // Viền màu chính.
            ),
          ),
        ),

        // `Positioned` để đặt `label` ở một vị trí cụ thể trong `Stack`.
        Positioned(
          left: 40, // Cách lề trái 40.
          top: -10, // Cách lề trên -10 (đi lên trên, ra khỏi TextField).
          // Bọc `Text` trong `Container` để đặt màu nền.
          child: Container(
            color: Colors.white, // Màu nền trắng. 
            padding:
                const EdgeInsets.symmetric(horizontal: 8), // Đệm 2 bên chữ.
            child: Text(
              label,
              style: const TextStyle(
                color: kLabelColor,
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Định nghĩa widget custom cho nút chọn icon (ví dụ: nút 'Light', 'TV').
class _IconSelectionButton extends StatelessWidget {
  final IconData icon; 
  final String label; 
  final bool isSelected;
  final VoidCallback onTap; 

  // Constructor.
  const _IconSelectionButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Sử dụng `GestureDetector` để bắt sự kiện `onTap`.
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 67,
            height: 67,
            decoration: BoxDecoration(
                // Nếu đang được chọn (isSelected == true), nền là màu chính.
                // Nếu không, nền là màu trắng.
                color: isSelected ? kPrimaryColor : Colors.white,
                borderRadius: BorderRadius.circular(16), // Bo góc.
                // Nếu được chọn, thêm hiệu ứng đổ bóng (BoxShadow).
                // Nếu không, danh sách shadow rỗng.
                boxShadow: isSelected
                    ? [
                        const BoxShadow(
                          color: Color(0x5B3880F6),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        )
                      ]
                    : [],
                // Nếu *không* được chọn, thêm đường viền.
                // Nếu được chọn, không cần viền (null).
                border: isSelected
                    ? null
                    : Border.all(color: kBorderColor.withOpacity(0.5))),
            // Widget Icon bên trong Container.
            child: Icon(
              icon,
              // Nếu được chọn, icon màu trắng.
              // Nếu không, icon màu phụ.
              color: isSelected ? Colors.white : kTextColorSecondary,
              size: 30,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? kPrimaryColor : kTextColorSecondary,
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          )
        ],
      ),
    );
  }
}