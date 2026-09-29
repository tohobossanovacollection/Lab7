/*
 * ============================================================================
 * Sinh viên thực hiện: Trần Minh Sơn
 * Mã sinh viên (MSV): 26A4041664
 * Môn học: Lập trình Di động (Mobile Programming)
 * Bài thực hành: Lab 7 – Form & Xác thực
 * File: lib/screens/lab7_2_password_screen.dart
 * Mô tả: Lab 7.2 – Quy tắc xác thực & Độ mạnh mật khẩu thời gian thực
 * ============================================================================
 */

import 'package:flutter/material.dart';
import '../models/password_strength.dart';
import '../widgets/password_strength_bar.dart';
import '../widgets/student_info_header.dart';

class Lab72PasswordScreen extends StatefulWidget {
  const Lab72PasswordScreen({super.key});

  @override
  State<Lab72PasswordScreen> createState() => _Lab72PasswordScreenState();
}

class _Lab72PasswordScreenState extends State<Lab72PasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  PasswordStrengthResult _strength = PasswordStrengthResult.calculate('');
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _passwordsMatch = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_onPasswordChanged);
    _confirmController.addListener(_onConfirmChanged);
  }

  void _onPasswordChanged() {
    setState(() {
      _strength = PasswordStrengthResult.calculate(_passwordController.text);
      _checkMatch();
    });
  }

  void _onConfirmChanged() {
    setState(() {
      _checkMatch();
    });
  }

  void _checkMatch() {
    final pass = _passwordController.text;
    final confirm = _confirmController.text;
    _passwordsMatch = pass.isNotEmpty && confirm.isNotEmpty && pass == confirm;
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_strength.level == PasswordStrengthLevel.weak) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cảnh báo: Mật khẩu còn yếu, vui lòng tăng độ phức tạp!'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.verified_user, color: Colors.green, size: 48),
          title: const Text('Mật Khẩu Đạt Chuẩn!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Độ mạnh: ${_strength.label}',
                  style: TextStyle(
                      color: _strength.color, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text('Sinh viên: Trần Minh Sơn'),
              const Text('Mã SV: 26A4041664'),
              const SizedBox(height: 10),
              const Text(
                'Mật khẩu đã thỏa mãn toàn bộ các quy tắc xác thực an toàn của Lab 7.2.',
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Xác nhận'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab 7.2 – Quy Tắc & Độ Mạnh Mật Khẩu'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const StudentInfoHeader(
                labTitle: 'Lab 7.2: Kiểm tra độ mạnh mật khẩu và quy tắc bảo mật',
              ),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'KIỂM TRA BẢO MẬT MẬT KHẨU',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),

                        // Trường nhập Mật khẩu
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Mật khẩu mới *',
                            hintText: 'Nhập mật khẩu để đánh giá',
                            prefixIcon: const Icon(Icons.shield_outlined),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập mật khẩu';
                            }
                            if (value.length < 8) {
                              return 'Mật khẩu phải có tối thiểu 8 ký tự';
                            }
                            if (!_strength.hasUppercase) {
                              return 'Mật khẩu phải chứa ít nhất 1 chữ hoa (A-Z)';
                            }
                            if (!_strength.hasDigit) {
                              return 'Mật khẩu phải chứa ít nhất 1 chữ số (0-9)';
                            }
                            if (!_strength.hasSpecialChar) {
                              return 'Mật khẩu phải chứa ít nhất 1 ký tự đặc biệt';
                            }
                            return null;
                          },
                        ),

                        // Thanh đo độ mạnh & Checklist
                        PasswordStrengthBar(
                          strength: _strength,
                          showCriteriaList: true,
                        ),
                        const SizedBox(height: 16),

                        // Trường xác nhận mật khẩu
                        TextFormField(
                          controller: _confirmController,
                          obscureText: _obscureConfirm,
                          decoration: InputDecoration(
                            labelText: 'Xác nhận lại mật khẩu *',
                            hintText: 'Khớp với mật khẩu trên',
                            prefixIcon: const Icon(Icons.lock_clock_outlined),
                            border: const OutlineInputBorder(),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_confirmController.text.isNotEmpty)
                                  Icon(
                                    _passwordsMatch
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                    color: _passwordsMatch
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                IconButton(
                                  icon: Icon(
                                    _obscureConfirm
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirm = !_obscureConfirm;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập lại mật khẩu';
                            }
                            if (value != _passwordController.text) {
                              return 'Mật khẩu xác nhận không khớp!';
                            }
                            return null;
                          },
                        ),
                        if (_confirmController.text.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            _passwordsMatch
                                ? '✓ Hai mật khẩu đã trùng khớp'
                                : '✕ Hai mật khẩu chưa trùng khớp',
                            style: TextStyle(
                              fontSize: 12,
                              color: _passwordsMatch ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),

                        ElevatedButton.icon(
                          onPressed: _submit,
                          icon: const Icon(Icons.security),
                          label: const Text(
                            'KIỂM TRA & LƯU MẬT KHẨU',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
