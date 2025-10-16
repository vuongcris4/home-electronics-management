import 'dart:math' as math;
import 'package:flutter/material.dart';

// --- Các hằng số màu sắc ---
const Color kBackgroundColor = Color(0xFFF2F6FC);
const Color kPrimaryColor = Color(0xFF2666DE);
const Color kTextColorPrimary = Color(0xFF07123C);

class ControlScreen extends StatelessWidget {
  const ControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        // Dùng Stack để xếp chồng header và body
        child: Stack(
          children: [
            // Phần nội dung chính màu trắng
            Column(
              children: [
                const SizedBox(height: 140), // Tạo khoảng trống cho header
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    // Căn chỉnh nội dung bên trong
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _CircularKwhMeter(),
                        _ControlButton(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Header nằm đè lên trên
            const _Header(),
          ],
        ),
      ),
    );
  }
}

// --- Widget cho phần Header ---
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: kTextColorPrimary),
            onPressed: () {},
          ),
          const Text(
            'Light bubls',
            style: TextStyle(
              color: kTextColorPrimary,
              fontSize: 20,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: kPrimaryColor, size: 28),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

// --- Widget cho Biểu đồ tròn ---
class _CircularKwhMeter extends StatelessWidget {
  const _CircularKwhMeter();

  @override
  Widget build(BuildContext context) {
    // Giá trị giả lập để vẽ
    const double currentValue = 0.45;
    const double totalValue = 0.85;
    const double progress = currentValue / totalValue;

    return AspectRatio(
      aspectRatio: 1.1, // Tỉ lệ chiều rộng/cao
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Vòng tròn nền mờ bên ngoài
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFECF1FD).withOpacity(0.8),
            ),
          ),
          // Vòng tròn trắng bên trong có đổ bóng
          Container(
            margin: const EdgeInsets.all(40), // Tạo khoảng cách với vòng ngoài
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3880F6).withOpacity(0.12),
                  blurRadius: 100,
                  spreadRadius: 10,
                )
              ],
            ),
          ),
          // Dùng CustomPaint để vẽ đường cong và chấm tròn
          Padding(
            padding: const EdgeInsets.all(40.0),
            child: CustomPaint(
              painter: _MeterPainter(progress: progress),
              child: Container(),
            ),
          ),
          // Phần Text hiển thị thông số
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: '0.45',
                      style: TextStyle(
                        color: kTextColorPrimary,
                        fontSize: 30,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text: 'kWh',
                      style: TextStyle(
                        color: const Color(0xFFC9CBD8),
                        fontSize: 30,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '0.85Kwh outside',
                style: TextStyle(
                  color: kTextColorPrimary,
                  fontSize: 15,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- Custom Painter VÒNG TRÒN ĐẸP (ĐÃ THAY THẾ) ---
// --- Custom Painter VÒNG TRÒN ĐẸP (ĐÃ SỬA LỖI) ---
class _MeterPainter extends CustomPainter {
  final double progress;

  _MeterPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: size.width / 2);
    const startAngle = -2.3;
    const sweepAngle = 4.6;
    const strokeWidth = 12.0;

    // 1. Vẽ đường nền
    final backgroundPaint = Paint()
      ..color = const Color(0xFFECF1FD)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, startAngle, sweepAngle, false, backgroundPaint);

    // 2. Tạo Gradient cho đường tiến trình
    final progressGradient = SweepGradient(
      // *** SỬA LỖI Ở DÒNG NÀY ***
      center: Alignment.center, // Bỏ phần .resolve(rect)
      startAngle: startAngle,
      endAngle: startAngle + sweepAngle,
      tileMode: TileMode.clamp,
      colors: const [
        Color(0xFF538FFB),
        Color(0xFF2666DE),
      ],
    );

    // 3. Vẽ đường tiến trình với Gradient
    final progressPaint = Paint()
      ..shader = progressGradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, startAngle, sweepAngle * progress, false, progressPaint);
    
    // 4. Vẽ chấm tròn điều khiển
    final handleAngle = startAngle + (sweepAngle * progress);
    final handleOffset = Offset(
      center.dx + (size.width / 2) * math.cos(handleAngle),
      center.dy + (size.height / 2) * math.sin(handleAngle),
    );
    canvas.drawCircle(handleOffset, 8, Paint()..color = Colors.white);
    canvas.drawCircle(handleOffset, 6, Paint()..color = kPrimaryColor);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

// --- Widget cho Nút điều khiển ---
class _ControlButton extends StatelessWidget {
  const _ControlButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 146,
      decoration: BoxDecoration(
        color: kPrimaryColor,
        borderRadius: BorderRadius.circular(19),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.power_settings_new_rounded, color: Colors.white, size: 30),
          SizedBox(height: 20),
          Text(
            'Control',
            style: TextStyle(
              color: Color(0xFFD4E2FD),
              fontSize: 14,
              fontFamily: 'Inter',
            ),
          ),
          SizedBox(height: 5),
          Text(
            'ON',
            style: TextStyle(
              color: Color(0xFFD4E2FD),
              fontSize: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}