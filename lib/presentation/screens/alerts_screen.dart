import 'package:flutter/material.dart';

// ==========================================================
// PHẦN 1: HÀM main()
// ==========================================================
void main() {
  runApp(const MyApp());
}

// ==========================================================
// PHẦN 2: WIDGET GỐC MyApp
// ==========================================================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Home',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF3F6FF),
        fontFamily: 'Roboto', // Bạn có thể đổi font chữ ở đây
      ),
      home: const HomeScreen(),
    );
  }
}

// ==========================================================
// PHẦN 3: WIDGET HomeScreen ĐÃ LÀM LẠI HOÀN CHỈNH
// ==========================================================
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // DANH SÁCH DỮ LIỆU MẪU CHO CÁC CẢNH BÁO
  // Sau này bạn có thể thay bằng dữ liệu thật từ API
  final List<String> alerts = const [
    'Living room light was turned ON at 19:00',
    'Bedroom temperature reached 25°C at 18:30',
    'Front door was unlocked at 17:45',
    'Kitchen window opened at 16:20',
    'Motion detected in garage at 15:00',
    'Water leak detected in bathroom at 14:10',
    'Smoke alarm triggered in kitchen at 13:00',
  ];

  // WIDGET HELPER: Tái sử dụng để vẽ mỗi card cảnh báo
  // Giúp code sạch sẽ và dễ bảo trì hơn
  Widget _buildAlertCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), // Bo tròn hơn theo thiết kế
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, color: Colors.black87),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // SafeArea tự động tránh các phần tai thỏ, camera...
        bottom: false, // Không áp dụng SafeArea cho phần đáy vì đã có BottomNavBar
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ========================================================
            // HEADER: Giữ nguyên icon và điều chỉnh layout
            // ========================================================
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'May 16, 2025',
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Smart home',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 26,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  // Giữ nguyên icon logout của bạn
                  SizedBox(
                    width: 44,
                    height: 44,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Image.asset('assets/images/log_out_icon.png'),
                      onPressed: () {
                        // Xử lý sự kiện đăng xuất ở đây
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ========================================================
            // TIÊU ĐỀ ALERTS: Giữ nguyên icon
            // ========================================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Alerts',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6F7EA8),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Giữ nguyên icon thông báo của bạn
                  Image.asset(
                    'assets/images/notific.png',
                    width: 30,
                    height: 30,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ========================================================
            // DANH SÁCH CÁC ALERTS (CÓ THỂ CUỘN)
            // ========================================================
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: alerts.length,
                itemBuilder: (context, index) {
                  return _buildAlertCard(alerts[index]);
                },
                separatorBuilder: (context, index) => const SizedBox(height: 12),
              ),
            ),
          ],
        ),
      ),
      // ========================================================
      // BOTTOM NAVIGATION BAR: Giữ nguyên icon
      // ========================================================
      bottomNavigationBar: Container(
        height: 85,
        decoration: const BoxDecoration(
          color: Color(0xFF2666DE),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          child: BottomNavigationBar(
            items: [
              BottomNavigationBarItem(
                icon: Image.asset('assets/images/Analyze.png', width: 24, height: 24, color: Colors.white.withOpacity(0.7)),
                activeIcon: Image.asset('assets/images/Analyze.png', width: 24, height: 24, color: Colors.white),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Image.asset('assets/images/Home.png', width: 24, height: 24, color: Colors.white.withOpacity(0.7)),
                activeIcon: Image.asset('assets/images/Home.png', width: 24, height: 24, color: Colors.white),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Image.asset('assets/images/Male User.png', width: 24, height: 24, color: Colors.white.withOpacity(0.7)),
                activeIcon: Image.asset('assets/images/Male User.png', width: 24, height: 24, color: Colors.white),
                label: '',
              ),
            ],
            currentIndex: 1, // Icon ở giữa sẽ được chọn
            onTap: (index) {
              // Xử lý sự kiện chuyển tab ở đây
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            showSelectedLabels: false,
            showUnselectedLabels: false,
          ),
        ),
      ),
    );
  }
}
