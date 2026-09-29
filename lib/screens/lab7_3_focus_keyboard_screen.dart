/*
 * ============================================================================
 * Sinh viên thực hiện: Trần Minh Sơn
 * Mã sinh viên (MSV): 26A4041664
 * Môn học: Lập trình Di động (Mobile Programming)
 * Bài thực hành: Lab 7 – Form & Xác thực
 * File: lib/screens/lab7_3_focus_keyboard_screen.dart
 * Mô tả: Lab 7.3 – Quản lý FocusNode, bàn phím ảo, TextInputAction và unfocus
 * ============================================================================
 */

import 'package:flutter/material.dart';
import '../widgets/student_info_header.dart';

class Lab73FocusKeyboardScreen extends StatefulWidget {
  const Lab73FocusKeyboardScreen({super.key});

  @override
  State<Lab73FocusKeyboardScreen> createState() =>
      _Lab73FocusKeyboardScreenState();
}

class _Lab73FocusKeyboardScreenState extends State<Lab73FocusKeyboardScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmFocusNode = FocusNode();

  String _currentFocusedFieldName = 'Chưa chọn ô nào';

  @override
  void initState() {
    super.initState();

    _nameFocusNode.addListener(() => _updateFocusName('Họ và tên', _nameFocusNode));
    _emailFocusNode.addListener(() => _updateFocusName('Email', _emailFocusNode));
    _phoneFocusNode.addListener(() => _updateFocusName('Số điện thoại', _phoneFocusNode));
    _passwordFocusNode.addListener(() => _updateFocusName('Mật khẩu', _passwordFocusNode));
    _confirmFocusNode.addListener(() => _updateFocusName('Xác nhận mật khẩu', _confirmFocusNode));
  }

  void _updateFocusName(String fieldName, FocusNode node) {
    if (node.hasFocus) {
      setState(() {
        _currentFocusedFieldName = fieldName;
      });
    } else {
      if (!_nameFocusNode.hasFocus &&
          !_emailFocusNode.hasFocus &&
          !_phoneFocusNode.hasFocus &&
          !_passwordFocusNode.hasFocus &&
          !_confirmFocusNode.hasFocus) {
        setState(() {
          _currentFocusedFieldName = 'Bàn phím đã ẩn (Không có ô nào focus)';
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();

    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmFocusNode.dispose();

    super.dispose();
  }

  void _submit() {
    // Ẩn bàn phím trước khi submit
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.keyboard_double_arrow_right,
              color: Colors.blue, size: 48),
          title: const Text('Thành công (Lab 7.3)'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Quá trình quản lý Focus và bàn phím hoạt động chuẩn xác!'),
              const Divider(),
              Text('Họ tên: ${_nameController.text}'),
              Text('Email: ${_emailController.text}'),
              Text('SĐT: ${_phoneController.text}'),
              const SizedBox(height: 8),
              const Text('Sinh viên: Trần Minh Sơn - MSV: 26A4041664',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Chạm ra ngoài để ẩn bàn phím (GestureDetector unfocus)
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lab 7.3 – Quản Lý Focus & Bàn Phím'),
          actions: [
            IconButton(
              tooltip: 'Ẩn bàn phím ngay',
              icon: const Icon(Icons.keyboard_hide),
              onPressed: () => FocusScope.of(context).unfocus(),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const StudentInfoHeader(
                  labTitle:
                      'Lab 7.3: FocusNode, TextInputAction, Chuyển tiếp & Ẩn bàn phím',
                ),

                // Trạng thái Focus hiện tại
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.touch_app, color: theme.colorScheme.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Trạng thái: $_currentFocusedFieldName',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
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
                          // 1. Trường Họ và tên
                          TextFormField(
                            controller: _nameController,
                            focusNode: _nameFocusNode,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.name,
                            decoration: const InputDecoration(
                              labelText: '1. Họ và tên (TextInputType.name) *',
                              prefixIcon: Icon(Icons.person),
                              border: OutlineInputBorder(),
                              helperText: 'Nhấn Next trên bàn phím để sang Email',
                            ),
                            onFieldSubmitted: (_) {
                              // Tự động chuyển focus sang ô Email
                              FocusScope.of(context).requestFocus(_emailFocusNode);
                            },
                            validator: (v) =>
                                (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
                          ),
                          const SizedBox(height: 16),

                          // 2. Trường Email
                          TextFormField(
                            controller: _emailController,
                            focusNode: _emailFocusNode,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: '2. Email (TextInputType.emailAddress) *',
                              prefixIcon: Icon(Icons.email),
                              border: OutlineInputBorder(),
                              helperText: 'Nhấn Next trên bàn phím để sang Số ĐT',
                            ),
                            onFieldSubmitted: (_) {
                              FocusScope.of(context).requestFocus(_phoneFocusNode);
                            },
                            validator: (v) =>
                                (v == null || !v.contains('@')) ? 'Email sai' : null,
                          ),
                          const SizedBox(height: 16),

                          // 3. Trường Số điện thoại
                          TextFormField(
                            controller: _phoneController,
                            focusNode: _phoneFocusNode,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: '3. Số điện thoại (TextInputType.phone) *',
                              prefixIcon: Icon(Icons.phone),
                              border: OutlineInputBorder(),
                              helperText: 'Bàn phím hiển thị phím số',
                            ),
                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(_passwordFocusNode);
                            },
                            validator: (v) =>
                                (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
                          ),
                          const SizedBox(height: 16),

                          // 4. Trường Mật khẩu
                          TextFormField(
                            controller: _passwordController,
                            focusNode: _passwordFocusNode,
                            obscureText: true,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.visiblePassword,
                            decoration: const InputDecoration(
                              labelText: '4. Mật khẩu *',
                              prefixIcon: Icon(Icons.lock),
                              border: OutlineInputBorder(),
                              helperText: 'Nhấn Next để sang Xác nhận mật khẩu',
                            ),
                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(_confirmFocusNode);
                            },
                            validator: (v) =>
                                (v == null || v.length < 6) ? 'Tối thiểu 6 ký tự' : null,
                          ),
                          const SizedBox(height: 16),

                          // 5. Trường Xác nhận mật khẩu (Done)
                          TextFormField(
                            controller: _confirmController,
                            focusNode: _confirmFocusNode,
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            decoration: const InputDecoration(
                              labelText: '5. Xác nhận mật khẩu (TextInputAction.done) *',
                              prefixIcon: Icon(Icons.check_circle_outline),
                              border: OutlineInputBorder(),
                              helperText: 'Nhấn Done/Enter trên bàn phím để Gửi form',
                            ),
                            onFieldSubmitted: (_) {
                              // Khi nhấn Done thì submit luôn form
                              _submit();
                            },
                            validator: (v) =>
                                (v != _passwordController.text) ? 'Không khớp' : null,
                          ),
                          const SizedBox(height: 24),

                          // Nút chuyển focus nhanh bằng code
                          const Text(
                            'Thử chuyển Focus bằng nút bấm:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              ActionChip(
                                label: const Text('Focus Họ tên'),
                                avatar: const Icon(Icons.person, size: 16),
                                onPressed: () => FocusScope.of(context)
                                    .requestFocus(_nameFocusNode),
                              ),
                              ActionChip(
                                label: const Text('Focus Email'),
                                avatar: const Icon(Icons.email, size: 16),
                                onPressed: () => FocusScope.of(context)
                                    .requestFocus(_emailFocusNode),
                              ),
                              ActionChip(
                                label: const Text('Focus SĐT'),
                                avatar: const Icon(Icons.phone, size: 16),
                                onPressed: () => FocusScope.of(context)
                                    .requestFocus(_phoneFocusNode),
                              ),
                              ActionChip(
                                label: const Text('Ẩn bàn phím'),
                                avatar: const Icon(Icons.close, size: 16),
                                onPressed: () => FocusScope.of(context).unfocus(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          ElevatedButton.icon(
                            onPressed: _submit,
                            icon: const Icon(Icons.send),
                            label: const Text(
                              'HOÀN TẤT & GỬI FORM',
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
      ),
    );
  }
}
