import 'package:flutter/material.dart';

class RoundedInputfield extends StatefulWidget {
  final String hintText;
  final IconData? icon;
  final bool obscureText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final void Function(String)? onSubmitted; // callback กดส่งข้อความ

  const RoundedInputfield({
    super.key,
    required this.hintText,
    this.icon,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.onSubmitted,
  });

  @override
  State<RoundedInputfield> createState() => _RoundedInputfieldState();
}

class _RoundedInputfieldState extends State<RoundedInputfield> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;
    widget.onSubmitted?.call(text.trim());
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // สีเงา
            blurRadius: 8, // ความเบลอ
            offset: Offset(0, 4), // เงาอยู่ล่าง
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        obscureText: widget.obscureText,
        keyboardType: widget.keyboardType,
        decoration: InputDecoration(
          prefixIcon: widget.icon != null
              ? Icon(widget.icon, color: Colors.grey)
              : null,
          hintText: widget.hintText,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
        textInputAction: TextInputAction.send,
        onSubmitted: _handleSubmitted,
      ),
    );
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      // กรณีสร้าง controller เอง ต้อง dispose
      _controller.dispose();
    }
    super.dispose();
  }
}
