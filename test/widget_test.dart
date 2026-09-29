/*
 * ============================================================================
 * Sinh viên thực hiện: Trần Minh Sơn
 * Mã sinh viên (MSV): 26A4041664
 * Môn học: Lập trình Di động (Mobile Programming)
 * Bài thực hành: Lab 7 – Form & Xác thực
 * ============================================================================
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:lab7/main.dart';

void main() {
  testWidgets('Kiểm thử khởi chạy ứng dụng Lab 7', (WidgetTester tester) async {
    // Khởi chạy ứng dụng
    await tester.pumpWidget(const MyApp());

    // Kiểm tra hiển thị tiêu đề và tên sinh viên
    expect(find.text('Lab 7 – Form & Xác Thực'), findsOneWidget);
    expect(find.text('Trần Minh Sơn'), findsWidgets);
  });
}
