/*
 * ============================================================================
 * Sinh viên thực hiện: Trần Minh Sơn
 * Mã sinh viên (MSV): 26A4041664
 * Môn học: Lập trình Di động (Mobile Programming)
 * Bài thực hành: Lab 7 – Form & Xác thực
 * File: lib/screens/lab7_4_async_email_screen.dart
 * Mô tả: Lab 7.4 – Kiểm tra Email bất đồng bộ (Async Validation & Debounce)
 * ============================================================================
 */

import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/student_info_header.dart';

class Lab74AsyncEmailScreen extends StatefulWidget {
  const Lab74AsyncEmailScreen({super.key});

  @override
  State<Lab74AsyncEmailScreen> createState() => _Lab74AsyncEmailScreenState();
}

class _Lab74AsyncEmailScreenState extends State<Lab74AsyncEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();

  // Danh sách email giả lập đã tồn tại trong hệ thống cơ sở dữ liệu
  final List<String> _existingEmails = [
    'admin@gmail.com',
    'phuoc@gmail.com',
    'test@example.com',
    'user@domain.com',
    'haphoc@gmail.com',
  ];

  Timer? _debounceTimer;
  bool _isChecking = false;
  bool? _isEmailAvailable;
  String? _asyncEmailError;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onEmailChanged);
    _emailFocusNode.addListener(() {
      if (!_emailFocusNode.hasFocus && _emailController.text.isNotEmpty) {
        _validateEmailAsync(_emailController.text.trim());
      }
    });
  }

  void _onEmailChanged() {
    final text = _emailController.text.trim();
    if (text.isEmpty) {
      _debounceTimer?.cancel();
      setState(() {
        _isChecking = false;
        _isEmailAvailable = null;
        _asyncEmailError = null;
      });
      return;
    }

    // Debounce: Chờ người dùng ngừng gõ 700ms mới kích hoạt gọi bất đồng bộ
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 700), () {
      _validateEmailAsync(text);
    });
  }

  Future<void> _validateEmailAsync(String email) async {
    // Kiểm tra định dạng cơ bản trước
    final emailRegex = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    if (!emailRegex.hasMatch(email)) {
      setState(() {
        _isChecking = false;
        _isEmailAvailable = false;
        _asyncEmailError = 'Email không đúng định dạng';
      });
      return;
    }

    setState(() {
      _isChecking = true;
      _asyncEmailError = null;
      _isEmailAvailable = null;
    });

    // Giả lập độ trễ mạng API (1.2 giây)
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;

    final isTaken = _existingEmails.map((e) => e.toLowerCase()).contains(email.toLowerCase());

    setState(() {
      _isChecking = false;
      if (isTaken) {
        _isEmailAvailable = false;
        _asyncEmailError = 'Email này đã tồn tại trong hệ thống!';
      } else {
        _isEmailAvailable = true;
        _asyncEmailError = null;
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _nameController.dispose();
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_isChecking) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đang kiểm tra email, vui lòng đợi trong giây lát...'),
        ),
      );
      return;
    }

    if (_isEmailAvailable == false || _asyncEmailError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_asyncEmailError ?? 'Email không hợp lệ!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      if (_isEmailAvailable == null) {
        await _validateEmailAsync(_emailController.text.trim());
        if (_isEmailAvailable != true) return;
      }

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.cloud_done, color: Colors.green, size: 48),
          title: const Text('Xác thực bất đồng bộ xong!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Họ và tên: ${_nameController.text}'),
              Text('Email hợp lệ: ${_emailController.text}'),
              const SizedBox(height: 8),
              const Text('Sinh viên: Trần Minh Sơn - MSV: 26A4041664'),
              const SizedBox(height: 6),
              const Text(
                'Email đã vượt qua bước kiểm tra bất đồng bộ giả lập API!',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Đóng'),
            ),
          ],
        ),
      );
    }
  }

  Widget? _buildEmailSuffix() {
    if (_isChecking) {
      return const Padding(
        padding: EdgeInsets.all(12.0),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2.2),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab 7.4 – Kiểm Tra Bất Đồng Bộ'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const StudentInfoHeader(
                labTitle:
                    'Lab 7.4: Giả lập API kiểm tra Email đã tồn tại (Async Validation)',
              ),

              // Gợi ý danh sách email mẫu để test
              Card(
                color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.3),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline,
                              size: 18, color: theme.colorScheme.secondary),
                          const SizedBox(width: 6),
                          const Text(
                            'Email mẫu đã tồn tại (để test báo lỗi trùng):',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: _existingEmails.map((email) {
                          return ActionChip(
                            label: Text(email, style: const TextStyle(fontSize: 11)),
                            onPressed: () {
                              _emailController.text = email;
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

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
                          'KIỂM TRA EMAIL TRỰC TUYẾN',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),

                        // Trường Họ và tên
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Họ và tên *',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Bắt buộc nhập' : null,
                        ),
                        const SizedBox(height: 16),

                        // Trường Email với Async Validation & Spinner
                        TextFormField(
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Địa chỉ Email *',
                            hintText: 'Nhập email kiểm tra',
                            prefixIcon: const Icon(Icons.email),
                            border: const OutlineInputBorder(),
                            suffixIcon: _buildEmailSuffix(),
                            errorText: _asyncEmailError,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Vui lòng nhập Email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),

                        // Trạng thái kiểm tra email thời gian thực
                        if (_isChecking)
                          const Row(
                            children: [
                              SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Đang kết nối kiểm tra dữ liệu...',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          )
                        else if (_isEmailAvailable == true)
                          const Row(
                            children: [
                              Icon(Icons.check, size: 16, color: Colors.green),
                              SizedBox(width: 6),
                              Text(
                                'Email khả dụng và có thể sử dụng!',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),

                        const SizedBox(height: 24),

                        ElevatedButton.icon(
                          onPressed: _submit,
                          icon: const Icon(Icons.cloud_upload_outlined),
                          label: const Text(
                            'GỬI THÔNG TIN XÁC THỰC',
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
