import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gennext/screens/auth/login.dart';
import 'package:gennext/widgets/rounded_inputfield.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final phoneController = TextEditingController();
  final userController = TextEditingController();
  final ageController = TextEditingController();

  bool isLoading = false;
  String role = 'listener';

  Future<void> register() async {
    setState(() {
      isLoading = true;
    });

    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final user = userCredential.user;

      if (user != null) {
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
                'username': userController.text.trim(),
                'phone': phoneController.text.trim(),
                'email': user.email,
                'age': int.tryParse(ageController.text.trim()) ?? 0,
                'role': role,
                'reputation': 0,
                'coin': 0,
              });
          print('User data saved successfully');
          print({
            'username': userController.text.trim(),
            'phone': phoneController.text.trim(),
            'email': user.email,
            'age': int.tryParse(ageController.text.trim()) ?? 0,
            'role': role,
            'reputation': 0,
            'coin': 0,
          });
        } catch (e) {
          print('Error saving user data: $e');
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error saving user data')));
        }
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sign Up Successful')));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? 'Sign Up Failed')));
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(242, 242, 242, 1),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ปุ่ม Back
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const Login()),
                    );
                  },
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 28,
                    color: Colors.black87,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // หัวข้อ
              const Text(
                'สมัครสมาชิก',
                style: TextStyle(
                  color: Color.fromRGBO(34, 39, 61, 1),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // รูปโปรไฟล์
              SizedBox(
                height: 100,
                width: 100,
                child: ClipOval(
                  child: Image.asset('images/qlementine-icons--user-16.png'),
                ),
              ),

              const SizedBox(height: 30),

              // Input Fields
              Column(
                children: [
                  RoundedInputfield(
                    hintText: 'อีเมล',
                    icon: Icons.email,
                    controller: emailController,
                  ),
                  const SizedBox(height: 10),
                  RoundedInputfield(
                    hintText: 'รหัสผ่าน',
                    icon: Icons.lock,
                    obscureText: true,
                    controller: passwordController,
                  ),
                  const SizedBox(height: 10),
                  RoundedInputfield(
                    hintText: 'ยืนยันรหัสผ่าน',
                    icon: Icons.lock_outline,
                    obscureText: true,
                    controller: confirmPasswordController,
                  ),
                  const SizedBox(height: 10),
                  RoundedInputfield(
                    hintText: 'เบอร์โทรศัพท์',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    controller: phoneController,
                  ),
                  const SizedBox(height: 10),
                  RoundedInputfield(
                    hintText: 'ชื่อสมาชิก',
                    icon: Icons.person,
                    controller: userController,
                  ),
                  const SizedBox(height: 10),
                  RoundedInputfield(
                    hintText: 'อายุ',
                    icon: Icons.person,
                    controller: ageController,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text("บทบาท: "),
                      DropdownButton<String>(
                        value: role,
                        items: const [
                          DropdownMenuItem(
                            value: 'speaker',
                            child: Text('ผู้พูด'),
                          ),
                          DropdownMenuItem(
                            value: 'listener',
                            child: Text('ผู้ฟัง'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              role = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // ปุ่มสมัคร
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: register,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F223C),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    'สมัครสมาชิก',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// class Signup extends StatelessWidget {
//   const Signup({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color.fromRGBO(242, 242, 242, 1),
//       body: Column(
//         children: [
//           SizedBox(height: 30),
//           SafeArea(
//             child: Align(
//               alignment: Alignment.centerLeft,
//               child: GestureDetector(
//                 onTap: () {
//                   // ตัวอย่าง: ย้อนกลับ
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => const Login()),
//                   );
//                 },
//                 child: Padding(
//                   padding: EdgeInsetsGeometry.only(left: 20),
//                   child: SizedBox(
//                     width: 40,
//                     height: 40,
//                     child: Image.asset('images/weui--back-filled.png'),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(height: 5),
//           Align(
//             alignment: Alignment.center,
//             child: TextButton(
//               onPressed: () {},
//               child: Text(
//                 'สมัครสมาชิก',
//                 style: TextStyle(
//                   color: Color.fromRGBO(34, 39, 61, 1),
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),

//           SizedBox(height: 20),

//           Align(
//             alignment: Alignment.center,
//             child: SizedBox(
//               height: 100,
//               width: 100,
//               child: Image.asset('images/qlementine-icons--user-16.png'),
//             ),
//           ),

//           SizedBox(height: 30),

//           Column(
//             children: [
//               SizedBox(child: RoundedInputfield(hintText: 'อีเมล'), width: 300),
//               SizedBox(height: 10),
//               SizedBox(
//                 child: RoundedInputfield(hintText: 'รหัสผ่าน'),
//                 width: 300,
//               ),
//               SizedBox(height: 10),
//               SizedBox(
//                 child: RoundedInputfield(hintText: 'ยืนยันรหัสผ่าน'),
//                 width: 300,
//               ),
//               SizedBox(height: 10),
//               SizedBox(
//                 child: RoundedInputfield(hintText: 'เบอร์โทรศัพท์'),
//                 width: 300,
//               ),
//               SizedBox(height: 10),
//               SizedBox(
//                 child: RoundedInputfield(hintText: 'ชื่อสมาชิก'),
//                 width: 300,
//               ),
//             ],
//           ),
//           SizedBox(height: 40),

//           TextButton(
//             onPressed: () {},
//             style: TextButton.styleFrom(
//               backgroundColor: const Color(0xFF1F223C), // สีกรม
//               padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(30), // โค้งมน
//               ),
//             ),
//             child: Text(
//               'สมัครสมาชิก',
//               style: TextStyle(
//                 fontSize: 12,
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
