import 'package:flutter/material.dart';

class ActionBTN extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const ActionBTN({required this.label, required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromRGBO(210, 118, 71, 1),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(2, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// class ActionBTN extends StatelessWidget {
//   final String
//   label; // ใช้ final เพราะ StatelessWidget ไม่ควรมีค่าที่เปลี่ยนได้
//   final VoidCallback onPressed;

//   const ActionBTN({super.key, required this.label, required this.onPressed});

//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       onPressed: onPressed,
//       style: ElevatedButton.styleFrom(
//         backgroundColor: const Color(0xFF1F223C),
//         shadowColor: Colors.black45,
//         padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
//       ),
//       child: Text(
//         label,
//         style: const TextStyle(
//           fontSize: 14,
//           fontWeight: FontWeight.bold,
//           color: Colors.white,
//         ),
//       ),
//     );
//   }
// }
