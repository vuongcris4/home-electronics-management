import 'package:flutter/material.dart';

// --- Bảng màu và Kiểu chữ (Để dễ quản lý) ---
const Color kBackgroundColor = Color(0xFFF2F6FC);
const Color kPrimaryColor = Color(0xFF2666DE);
const Color kTextColorPrimary = Color(0xFF07123C);
const Color kTextColorSecondary = Color(0xFF6F7EA8);
const Color kActiveCardColor = Color(0xFF2666DE);
const Color kInactiveCardColor = Colors.white;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Home UI',
      theme: ThemeData(
        fontFamily: 'Inter',
        scaffoldBackgroundColor: kBackgroundColor,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        useMaterial3: true,
        switchTheme: SwitchThemeData(
          trackColor: MaterialStateProperty.resolveWith<Color?>((states) {
            if (states.contains(MaterialState.selected)) {
              return const Color(0xFF669BF7);
            }
            return const Color(0xFFD4E2FD);
          }),
          thumbColor: MaterialStateProperty.resolveWith<Color?>((states) {
            if (states.contains(MaterialState.selected)) {
              return Colors.white;
            }
            return kPrimaryColor;
          }),
          trackOutlineColor: MaterialStateProperty.resolveWith<Color?>((states) {
            return Colors.transparent;
          }),
        ),
      ),
      home: const SmartHomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// --- Màn hình chính ---
class SmartHomeScreen extends StatelessWidget {
  const SmartHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  const SizedBox(height: 130),
                  _RoomTabs(),
                  const SizedBox(height: 20),
                  _DeviceGrid(),
                  const Spacer(),
                  _AddButton(),
                  const Spacer(),
                ],
              ),
            ),
            _Header(),
          ],
        ),
      ),
      bottomNavigationBar: _BottomNavBar(),
    );
  }
}


// --- Các Widget con được tách ra cho dễ đọc ---

/// Widget hiển thị phần Header (Ngày tháng, tiêu đề và icon)
class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'May 16, 2025',
                style: TextStyle(color: kTextColorSecondary, fontSize: 14),
              ),
              SizedBox(height: 8),
              Text(
                'Smart home',
                style: TextStyle(
                  color: kTextColorPrimary,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: kPrimaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
            // *** THAY ĐỔI: Dùng Image.asset cho icon exit ***
            child: Center( // Dùng Center để căn giữa icon trong Container
              child: Image.asset(
                'assets/icons/exit.png', // <-- TÊN FILE ICON CỦA BẠN
                width: 22,
                height: 22,

              ),
            ),
          ),
        ],
      ),
    );
  }
}


/// Widget hiển thị các tab chọn phòng
class _RoomTabs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // *** THAY ĐỔI: Dùng Image.asset cho icon remove/minus ***
        Image.asset(
          'assets/icons/minus.png', // <-- TÊN FILE ICON CỦA BẠN
          width: 24,
          height: 24,

        ),
        const Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _RoomTabItem(text: 'Living Room', isActive: true),
              _RoomTabItem(text: 'Kitchen'),
              _RoomTabItem(text: 'Dinning Room'),
            ],
          ),
        ),
        // *** THAY ĐỔI: Dùng Image.asset cho icon add ***
        Image.asset(
          'assets/icons/add.png', // <-- TÊN FILE ICON CỦA BẠN
          width: 24,
          height: 24,

        ),
      ],
    );
  }
}

/// Widget con cho từng tab phòng
class _RoomTabItem extends StatelessWidget {
  final String text;
  final bool isActive;

  const _RoomTabItem({required this.text, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          text,
          style: TextStyle(
            color: isActive ? kPrimaryColor : kTextColorSecondary,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (isActive)
          Container(
            width: 32,
            height: 4,
            decoration: BoxDecoration(
              color: kPrimaryColor,
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
      ],
    );
  }
}

/// Widget hiển thị lưới các thiết bị
class _DeviceGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      // *** THAY ĐỔI: Truyền đường dẫn icon vào các DeviceCard ***
      children: const [
        DeviceCard(
          iconAsset: 'assets/icons/lightbulb.png', // <-- ĐƯỜNG DẪN ICON
          title: 'Light bubls',
          subtitle: 'Philips Hue 2',
          isActive: true,
        ),
        DeviceCard(
          iconAsset: 'assets/icons/smart-tv.png', // <-- ĐƯỜNG DẪN ICON
          title: 'Smart TV',
          subtitle: 'Panasonic',
          isActive: false,
        ),
        DeviceCard(
          iconAsset: 'assets/icons/wifi-router.png', // <-- ĐƯỜNG DẪN ICON
          title: 'Wi-Fi Router',
          subtitle: 'TP Link',
          isActive: false,
        ),
        DeviceCard(
          iconAsset: 'assets/icons/cctv-camera.png', // <-- ĐƯỜNG DẪN ICON
          title: 'CCTV',
          subtitle: 'Security Camera 360°',
          isActive: false,
        ),
      ],
    );
  }
}

/// Widget card cho từng thiết bị (đã được sửa để nhận đường dẫn ảnh)
class DeviceCard extends StatelessWidget {
  // *** THAY ĐỔI: Chuyển từ IconData sang String ***
  final String iconAsset;
  final String title;
  final String subtitle;
  final bool isActive;

  const DeviceCard({
    super.key,
    required this.iconAsset, // <-- Sửa ở đây
    required this.title,
    required this.subtitle,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final Color cardColor = isActive ? kActiveCardColor : kInactiveCardColor;
    final Color titleColor = isActive ? Colors.white : kTextColorSecondary;
    final Color subtitleColor = isActive ? Colors.white.withOpacity(0.8) : kTextColorSecondary;
    final Color iconColor = isActive ? Colors.white : kTextColorSecondary;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(19),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // *** THAY ĐỔI: Dùng Image.asset thay cho Icon ***
              Image.asset(
                iconAsset,
                width: 32,
                height: 32,
                color: iconColor,
              ),
              Transform.scale(
                scale: 1,
                child: Switch(
                  value: isActive,
                  onChanged: (value) {},
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: titleColor,
                  fontSize: 16.17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: TextStyle(
                  color: subtitleColor,
                  fontSize: 14.26,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Widget cho nút "Add"
class _AddButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimaryColor,
        minimumSize: const Size(260, 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 8,
        shadowColor: kPrimaryColor.withOpacity(0.4),
        side: BorderSide.none,
      ),
      child: const Text(
        'Add',
        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

/// Widget cho thanh điều hướng dưới cùng
class _BottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      decoration: const BoxDecoration(
          color: kPrimaryColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          )
      ),
      // *** THAY ĐỔI: Dùng Image.asset cho các icon điều hướng ***
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Image.asset(
            'assets/icons/document.png', // <-- TÊN FILE ICON CỦA BẠN
            width: 30,
            height: 30,
            color: Colors.white,
          ),
          Image.asset(
            'assets/icons/home.png', // <-- TÊN FILE ICON CỦA BẠN
            width: 30,
            height: 30,
            color: Colors.white,
          ),
          Image.asset(
            'assets/icons/profile.png', // <-- TÊN FILE ICON CỦA BẠN
            width: 30,
            height: 30,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}