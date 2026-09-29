/*
 * ============================================================================
 * Sinh viên thực hiện: Trần Minh Sơn
 * Mã sinh viên (MSV): 26A4041664
 * Môn học: Lập trình Di động (Mobile Programming)
 * Bài thực hành: Lab 7 – Form & Xác thực
 * File: lib/models/password_strength.dart
 * Mô tả: Phân tích độ mạnh mật khẩu và kiểm tra các tiêu chí xác thực (Lab 7.2)
 * ============================================================================
 */

import 'package:flutter/material.dart';

enum PasswordStrengthLevel {
  empty,
  weak,
  medium,
  strong,
}

class PasswordStrengthResult {
  final PasswordStrengthLevel level;
  final double score; // 0.0 -> 1.0
  final String label;
  final Color color;
  final bool hasMinLength;
  final bool hasUppercase;
  final bool hasLowercase;
  final bool hasDigit;
  final bool hasSpecialChar;

  PasswordStrengthResult({
    required this.level,
    required this.score,
    required this.label,
    required this.color,
    required this.hasMinLength,
    required this.hasUppercase,
    required this.hasLowercase,
    required this.hasDigit,
    required this.hasSpecialChar,
  });

  static PasswordStrengthResult calculate(String password) {
    if (password.isEmpty) {
      return PasswordStrengthResult(
        level: PasswordStrengthLevel.empty,
        score: 0.0,
        label: 'Chưa nhập mật khẩu',
        color: Colors.grey,
        hasMinLength: false,
        hasUppercase: false,
        hasLowercase: false,
        hasDigit: false,
        hasSpecialChar: false,
      );
    }

    final hasMinLength = password.length >= 8;
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasDigit = password.contains(RegExp(r'[0-9]'));
    final hasSpecialChar = password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));

    int criteriaMet = 0;
    if (hasMinLength) criteriaMet++;
    if (hasUppercase) criteriaMet++;
    if (hasLowercase) criteriaMet++;
    if (hasDigit) criteriaMet++;
    if (hasSpecialChar) criteriaMet++;

    double score = criteriaMet / 5.0;

    PasswordStrengthLevel level;
    String label;
    Color color;

    if (criteriaMet <= 2) {
      level = PasswordStrengthLevel.weak;
      label = 'Yếu';
      color = Colors.red;
    } else if (criteriaMet <= 4) {
      level = PasswordStrengthLevel.medium;
      label = 'Trung bình';
      color = Colors.orange;
    } else {
      level = PasswordStrengthLevel.strong;
      label = 'Mạnh';
      color = Colors.green;
    }

    return PasswordStrengthResult(
      level: level,
      score: score,
      label: label,
      color: color,
      hasMinLength: hasMinLength,
      hasUppercase: hasUppercase,
      hasLowercase: hasLowercase,
      hasDigit: hasDigit,
      hasSpecialChar: hasSpecialChar,
    );
  }
}
