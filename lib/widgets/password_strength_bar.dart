/*
 * ============================================================================
 * Sinh viên thực hiện: Trần Minh Sơn
 * Mã sinh viên (MSV): 26A4041664
 * Môn học: Lập trình Di động (Mobile Programming)
 * Bài thực hành: Lab 7 – Form & Xác thực
 * File: lib/widgets/password_strength_bar.dart
 * Mô tả: Widget hiển thị thanh đo và danh sách tiêu chí độ mạnh mật khẩu (Lab 7.2)
 * ============================================================================
 */

import 'package:flutter/material.dart';
import '../models/password_strength.dart';

class PasswordStrengthBar extends StatelessWidget {
  final PasswordStrengthResult strength;
  final bool showCriteriaList;

  const PasswordStrengthBar({
    super.key,
    required this.strength,
    this.showCriteriaList = true,
  });

  @override
  Widget build(BuildContext context) {
    if (strength.level == PasswordStrengthLevel.empty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Độ mạnh mật khẩu:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            Text(
              strength.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: strength.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            tween: Tween<double>(begin: 0, end: strength.score),
            builder: (context, value, _) {
              return LinearProgressIndicator(
                value: value,
                minHeight: 6,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(strength.color),
              );
            },
          ),
        ),
        if (showCriteriaList) ...[
          const SizedBox(height: 12),
          _buildCriteriaItem('Tối thiểu 8 ký tự', strength.hasMinLength),
          _buildCriteriaItem('Chứa chữ hoa (A-Z)', strength.hasUppercase),
          _buildCriteriaItem('Chứa chữ thường (a-z)', strength.hasLowercase),
          _buildCriteriaItem('Chứa số (0-9)', strength.hasDigit),
          _buildCriteriaItem('Chứa ký tự đặc biệt (!@#\$%^&*)', strength.hasSpecialChar),
        ],
      ],
    );
  }

  Widget _buildCriteriaItem(String title, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.cancel_outlined,
            size: 16,
            color: isMet ? Colors.green : Colors.grey.shade400,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isMet ? Colors.green.shade800 : Colors.grey.shade600,
              fontWeight: isMet ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
