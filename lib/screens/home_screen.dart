/*
 * ============================================================================
 * Sinh viên thực hiện: Trần Minh Sơn
 * Mã sinh viên (MSV): 26A4041664
 * Môn học: Lập trình Di động (Mobile Programming)
 * Bài thực hành: Lab 7 – Form & Xác thực
 * File: lib/screens/home_screen.dart
 * Mô tả: Màn hình chính điều hướng danh mục các bài thực hành Lab 7
 * ============================================================================
 */

import 'package:flutter/material.dart';
import '../widgets/student_info_header.dart';
import 'lab7_1_basic_form_screen.dart';
import 'lab7_2_password_screen.dart';
import 'lab7_3_focus_keyboard_screen.dart';
import 'lab7_4_async_email_screen.dart';
import 'full_registration_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final labItems = [
      _LabItem(
        title: 'Lab 7.1 – Form Đăng Ký Cơ Bản',
        subtitle:
            'Sử dụng Form, GlobalKey<FormState>, TextFormField và validation đồng bộ cơ bản.',
        icon: Icons.assignment_outlined,
        color: Colors.blue,
        screen: const Lab71BasicFormScreen(),
      ),
      _LabItem(
        title: 'Lab 7.2 – Quy Tắc & Độ Mạnh Mật Khẩu',
        subtitle:
            'Thanh đo độ mạnh (Yếu/TB/Mạnh) & checklist kiểm tra hoa, thường, số, ký tự đặc biệt.',
        icon: Icons.security_outlined,
        color: Colors.deepOrange,
        screen: const Lab72PasswordScreen(),
      ),
      _LabItem(
        title: 'Lab 7.3 – Quản Lý Focus & Bàn Phím',
        subtitle:
            'Quản lý FocusNode, TextInputAction (Next/Done), nhảy ô tự động và ẩn bàn phím khi chạm ra ngoài.',
        icon: Icons.keyboard_alt_outlined,
        color: Colors.teal,
        screen: const Lab73FocusKeyboardScreen(),
      ),
      _LabItem(
        title: 'Lab 7.4 – Kiểm Tra Email Bất Đồng Bộ',
        subtitle:
            'Mô phỏng API kiểm tra email trùng lặp với Debounce và CircularProgressIndicator.',
        icon: Icons.cloud_sync_outlined,
        color: Colors.purple,
        screen: const Lab74AsyncEmailScreen(),
      ),
      _LabItem(
        title: '⭐ Form Đăng Ký Tổng Hợp (All-in-One)',
        subtitle:
            'Màn hình hoàn chỉnh tích hợp trọn vẹn 7.1, 7.2, 7.3 và 7.4 phục vụ demo & chấm điểm.',
        icon: Icons.verified_user_outlined,
        color: Colors.indigo,
        screen: const FullRegistrationScreen(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab 7 – Form & Xác Thực'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const StudentInfoHeader(
              labTitle: 'Menu điều hướng các bài thực hành Lab 7.1 -> Lab 7.4',
            ),

            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'DANH SÁCH BÀI THỰC HÀNH',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),

            ...labItems.map((item) {
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: item.color.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => item.screen),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: item.color.withValues(alpha: 0.15),
                          child: Icon(item.icon, color: item.color, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.subtitle,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: Colors.grey.shade700,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Row(
                children: [
                  Icon(Icons.camera_alt_outlined, color: Colors.blueGrey, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Gợi ý: Mở từng bài để thực hiện thao tác và chụp ảnh màn hình nộp báo cáo.',
                      style: TextStyle(fontSize: 11.5, color: Colors.blueGrey),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LabItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget screen;

  _LabItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.screen,
  });
}
