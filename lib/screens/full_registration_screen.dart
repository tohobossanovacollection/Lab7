/*
 * ============================================================================
 * Sinh viên thực hiện: Trần Minh Sơn
 * Mã sinh viên (MSV): 26A4041664
 * Môn học: Lập trình Di động (Mobile Programming)
 * Bài thực hành: Lab 7 – Form & Xác thực
 * File: lib/screens/full_registration_screen.dart
 * Mô tả: Form đăng ký tổng hợp đầy đủ (Tích hợp Lab 7.1, 7.2, 7.3, 7.4)
 * ============================================================================
 */

import 'dart:async';
import 'package:flutter/material.dart';
import '../models/password_strength.dart';
import '../widgets/password_strength_bar.dart';
import '../widgets/student_info_header.dart';

class FullRegistrationScreen extends StatefulWidget {
  const FullRegistrationScreen({super.key});

  @override
  State<FullRegistrationScreen> createState() => _FullRegistrationScreenState();
}

class _FullRegistrationScreenState extends State<FullRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // FocusNodes (Lab 7.3)
  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmFocusNode = FocusNode();

  // Mật khẩu (Lab 7.1, Lab 7.2)
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  PasswordStrengthResult _strength = PasswordStrengthResult.calculate('');
  bool _agreeToTerms = false;

  // Async Email Validation (Lab 7.4)
  final List<String> _takenEmails = [
    'admin@gmail.com',
    'phuoc@gmail.com',
    'test@example.com',
    'support@service.vn',
  ];
  Timer? _debounceTimer;
  bool _isCheckingEmail = false;
  bool? _isEmailAvailable;
  String? _emailAsyncError;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_handlePasswordChange);
    _emailController.addListener(_handleEmailChange);
  }

  void _handlePasswordChange() {
    setState(() {
      _strength = PasswordStrengthResult.calculate(_passwordController.text);
    });
  }

  void _handleEmailChange() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _debounceTimer?.cancel();
      setState(() {
        _isCheckingEmail = false;
        _isEmailAvailable = null;
        _emailAsyncError = null;
      });
      return;
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 700), () {
      _checkEmailAvailability(email);
    });
  }

  Future<void> _checkEmailAvailability(String email) async {
    final emailRegex = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    if (!emailRegex.hasMatch(email)) {
      setState(() {
        _isCheckingEmail = false;
        _isEmailAvailable = false;
        _emailAsyncError = 'Định dạng email chưa đúng';
      });
      return;
    }

    setState(() {
      _isCheckingEmail = true;
      _emailAsyncError = null;
      _isEmailAvailable = null;
    });

    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;

    final taken = _takenEmails.map((e) => e.toLowerCase()).contains(email.toLowerCase());

    setState(() {
      _isCheckingEmail = false;
      if (taken) {
        _isEmailAvailable = false;
        _emailAsyncError = 'Email này đã có người đăng ký!';
      } else {
        _isEmailAvailable = true;
        _emailAsyncError = null;
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();

    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmFocusNode.dispose();

    super.dispose();
  }

  void _submitForm() async {
    // Ẩn bàn phím khi submit (Lab 7.3)
    FocusScope.of(context).unfocus();

    if (_isCheckingEmail) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hệ thống đang kiểm tra email, vui lòng đợi...')),
      );
      return;
    }

    if (_isEmailAvailable == false || _emailAsyncError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_emailAsyncError ?? 'Email không hợp lệ'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      if (_strength.level == PasswordStrengthLevel.weak) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mật khẩu quá yếu! Vui lòng làm theo checklist bảo mật.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          icon: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 54),
          title: const Text('ĐĂNG KÝ THÀNH CÔNG!'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildInfoRow('Họ và tên:', _nameController.text),
                _buildInfoRow('Email:', _emailController.text),
                _buildInfoRow('Số điện thoại:', _phoneController.text),
                _buildInfoRow('Độ mạnh mật khẩu:', _strength.label),
                const Divider(height: 24),
                const Text(
                  'Thông tin sinh viên nộp bài:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 4),
                const Text('• Họ và tên: Trần Minh Sơn'),
                const Text('• Mã sinh viên (MSV): 26A4041664'),
                const Text('• Đã đáp ứng toàn bộ Lab 7.1 -> Lab 7.4'),
              ],
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Xác nhận & Hoàn tất'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget? _buildEmailSuffix() {
    if (_isCheckingEmail) {
      return const Padding(
        padding: EdgeInsets.all(12.0),
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    if (_isEmailAvailable == true) {
      return const Icon(Icons.check_circle, color: Colors.green);
    }
    if (_isEmailAvailable == false) {
      return const Icon(Icons.error, color: Colors.red);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Chạm ra ngoài để ẩn bàn phím
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Form Đăng Ký Tổng Hợp (Lab 7)'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const StudentInfoHeader(
                  labTitle: 'Tổng hợp hoàn chỉnh: Lab 7.1 + 7.2 + 7.3 + 7.4',
                ),

                Card(
                  elevation: 3,
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
                            'ĐĂNG KÝ THÀNH VIÊN',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Điền thông tin và kiểm tra quy tắc xác thực an toàn',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),

                          // 1. Họ và tên
                          TextFormField(
                            controller: _nameController,
                            focusNode: _nameFocusNode,
                            keyboardType: TextInputType.name,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Họ và tên *',
                              hintText: 'VD: Trần Minh Sơn',
                              prefixIcon: Icon(Icons.person_outline),
                              border: OutlineInputBorder(),
                            ),
                            onFieldSubmitted: (_) {
                              FocusScope.of(context).requestFocus(_emailFocusNode);
                            },
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Vui lòng nhập họ và tên';
                              }
                              if (v.trim().length < 2) {
                                return 'Tên tối thiểu 2 ký tự';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // 2. Email (Có Async Validation)
                          TextFormField(
                            controller: _emailController,
                            focusNode: _emailFocusNode,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: 'Địa chỉ Email *',
                              hintText: 'name@example.com',
                              prefixIcon: const Icon(Icons.email_outlined),
                              border: const OutlineInputBorder(),
                              suffixIcon: _buildEmailSuffix(),
                              errorText: _emailAsyncError,
                            ),
                            onFieldSubmitted: (_) {
                              FocusScope.of(context).requestFocus(_phoneFocusNode);
                            },
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Vui lòng nhập email';
                              }
                              return null;
                            },
                          ),
                          if (_isCheckingEmail)
                            const Padding(
                              padding: EdgeInsets.only(top: 4, left: 12),
                              child: Text(
                                'Đang kiểm tra tính duy nhất của email...',
                                style: TextStyle(fontSize: 11, color: Colors.blue),
                              ),
                            )
                          else if (_isEmailAvailable == true)
                            const Padding(
                              padding: EdgeInsets.only(top: 4, left: 12),
                              child: Text(
                                '✓ Email khả dụng và hợp lệ',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          const SizedBox(height: 16),

                          // 3. Số điện thoại
                          TextFormField(
                            controller: _phoneController,
                            focusNode: _phoneFocusNode,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Số điện thoại *',
                              hintText: '09xxxxxxxx',
                              prefixIcon: Icon(Icons.phone_outlined),
                              border: OutlineInputBorder(),
                            ),
                            onFieldSubmitted: (_) {
                              FocusScope.of(context).requestFocus(_passwordFocusNode);
                            },
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Vui lòng nhập số điện thoại';
                              }
                              if (v.trim().length < 9) {
                                return 'Số điện thoại không hợp lệ';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // 4. Mật khẩu
                          TextFormField(
                            controller: _passwordController,
                            focusNode: _passwordFocusNode,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: 'Mật khẩu bảo mật *',
                              hintText: 'Tối thiểu 8 ký tự, hoa, thường, số, ký tự đb',
                              prefixIcon: const Icon(Icons.lock_outline),
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
                            onFieldSubmitted: (_) {
                              FocusScope.of(context).requestFocus(_confirmFocusNode);
                            },
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Vui lòng nhập mật khẩu';
                              }
                              if (v.length < 8) {
                                return 'Mật khẩu cần tối thiểu 8 ký tự';
                              }
                              return null;
                            },
                          ),

                          // Thanh hiển thị độ mạnh mật khẩu (Lab 7.2)
                          PasswordStrengthBar(
                            strength: _strength,
                            showCriteriaList: true,
                          ),
                          const SizedBox(height: 16),

                          // 5. Xác nhận mật khẩu
                          TextFormField(
                            controller: _confirmPasswordController,
                            focusNode: _confirmFocusNode,
                            obscureText: _obscureConfirmPassword,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              labelText: 'Nhập lại mật khẩu *',
                              hintText: 'Khớp với mật khẩu trên',
                              prefixIcon: const Icon(Icons.lock_reset_outlined),
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                              ),
                            ),
                            onFieldSubmitted: (_) => _submitForm(),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Vui lòng xác nhận mật khẩu';
                              }
                              if (v != _passwordController.text) {
                                return 'Mật khẩu xác nhận không khớp!';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // 6. Điều khoản sử dụng
                          FormField<bool>(
                            initialValue: _agreeToTerms,
                            validator: (v) {
                              if (!_agreeToTerms) {
                                return 'Bạn phải đồng ý với điều khoản sử dụng';
                              }
                              return null;
                            },
                            builder: (state) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: _agreeToTerms,
                                        onChanged: (val) {
                                          setState(() {
                                            _agreeToTerms = val ?? false;
                                          });
                                          state.didChange(_agreeToTerms);
                                        },
                                      ),
                                      const Expanded(
                                        child: Text(
                                          'Tôi đã đọc và đồng ý với Quy chế & Chính sách bảo mật',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (state.hasError)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 12),
                                      child: Text(
                                        state.errorText!,
                                        style: TextStyle(
                                          color: theme.colorScheme.error,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 24),

                          // Nút Đăng ký
                          FilledButton.icon(
                            onPressed: _submitForm,
                            icon: const Icon(Icons.how_to_reg),
                            label: const Text(
                              'HOÀN TẤT ĐĂNG KÝ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
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
      ),
    );
  }
}
