import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gennext/services/firebase_service.dart';
import 'package:gennext/services/user_provider.dart';
import 'package:gennext/widgets/drawer.dart';
import 'package:gennext/widgets/navbar.dart';
import 'package:gennext/widgets/rounded_inputfield.dart';
import 'package:provider/provider.dart';

class ProfileConfig extends StatefulWidget {
  const ProfileConfig({super.key});

  @override
  State<ProfileConfig> createState() => _ProfileConfigState();
}

class _ProfileConfigState extends State<ProfileConfig> {
  final nameController = TextEditingController();
  final userController = TextEditingController();
  final ageController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  Future<void> changeSetting() async {
    final FirebaseFirestore fs = FirebaseFirestore.instance;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      print('User not logged in');
      return;
    }

    try {
      await fs.collection('users').doc(uid).update({
        'name': nameController.text.trim(),
        'username': userController.text.trim(),
        'age': ageController.text.trim(),
        'phone': phoneController.text.trim(),
        'email': emailController.text.trim(),
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('อัปเดตข้อมูลสำเร็จ')));

      print('User settings updated successfully');
    } catch (e) {
      print('Error updating user: $e');
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    userController.dispose();
    ageController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserProvider>(context).userData;
    final FireStoreServices fs = FireStoreServices();

    return Scaffold(
      extendBodyBehindAppBar: true,
      // backgroundColor: Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: GestureDetector(
              child: Icon(Icons.account_circle, color: Colors.black),
              onTap: () => {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => ProfileConfig(),
                    transitionsBuilder: (_, animation, __, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    transitionDuration: const Duration(milliseconds: 400),
                  ),
                ),
              }, //
            ),
          ),
        ],
      ),
      drawer: DrawerSide(),

      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsetsGeometry.symmetric(horizontal: 130),
              child: Text(
                userData != null ? userData['username'] ?? 'Guest' : 'Guest',
                style: const TextStyle(
                  fontSize: 30,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsetsGeometry.symmetric(horizontal: 130),
              child: Icon(Icons.account_circle, color: Colors.black, size: 150),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: 300,
              child: Column(
                children: [
                  RoundedInputfield(
                    hintText: 'ชื่อ-นามสกุล',
                    icon: Icons.email,
                    controller: nameController,
                  ),
                  const SizedBox(height: 10),
                  RoundedInputfield(
                    hintText: 'ชื่อผู้ใช้',
                    icon: Icons.lock,
                    obscureText: false,
                    controller: userController,
                  ),
                  const SizedBox(height: 10),

                  RoundedInputfield(
                    hintText: 'อายุ',
                    icon: Icons.person,
                    controller: ageController,
                  ),
                  const SizedBox(height: 10),
                  RoundedInputfield(
                    hintText: 'เบอร์โทรศัพท์',
                    icon: Icons.lock_outline,
                    obscureText: false,
                    controller: phoneController,
                  ),
                  const SizedBox(height: 10),
                  RoundedInputfield(
                    hintText: 'อีเมล',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    controller: emailController,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: 150,
              height: 60,
              child: ElevatedButton(
                onPressed: changeSetting,
                child: Text(
                  "บันทึก",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            //   SizedBox(
            //     width: double.infinity,
            //     child: ElevatedButton(
            //       onPressed: () async {
            //         final email = emailController.text.trim();
            //         final age = ageController.text;
            //         final username = userController.text;
            //         final phone = phoneController.text;
            //         final name = nameController.text;

            //         try {
            //           UserCredential userCredential = await FirebaseAuth.instance
            //               .createUserWithEmailAndPassword(
            //                 email: email,
            //                 password: password,
            //               );

            //           final user = userCredential.user;

            //           if (user != null) {
            //             try {
            //               await FirebaseFirestore.instance
            //                   .collection('users')
            //                   .doc(user.uid)
            //                   .set({
            //                     'username': userController.text.trim(),
            //                     'phone': phoneController.text.trim(),
            //                     'email': user.email,
            //                   });
            //               print('User data saved successfully');
            //               print({
            //                 'username': userController.text.trim(),
            //                 'phone': phoneController.text.trim(),
            //                 'email': user.email,
            //               });
            //             } catch (e) {
            //               print('Error saving user data: $e');
            //               ScaffoldMessenger.of(context).showSnackBar(
            //                 SnackBar(content: Text('Error saving user data')),
            //               );
            //             }
            //           }

            //           ScaffoldMessenger.of(context).showSnackBar(
            //             const SnackBar(content: Text('Sign Up Successful')),
            //           );

            //           Navigator.pushReplacement(
            //             context,
            //             MaterialPageRoute(builder: (context) => const Login()),
            //           );
            //         } on FirebaseAuthException catch (e) {
            //           ScaffoldMessenger.of(context).showSnackBar(
            //             SnackBar(content: Text(e.message ?? 'Sign Up Failed')),
            //           );
            //         }
            //       },

            //       style: ElevatedButton.styleFrom(
            //         backgroundColor: const Color(0xFF1F223C),
            //         padding: const EdgeInsets.symmetric(vertical: 14),
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(30),
            //         ),
            //         elevation: 4,
            //       ),
            //       child: const Text(
            //         'สมัครสมาชิก',
            //         style: TextStyle(
            //           fontSize: 14,
            //           color: Colors.white,
            //           fontWeight: FontWeight.bold,
            //         ),
            //       ),
            //     ),
            //   ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavBar(),
    );
  }
}
