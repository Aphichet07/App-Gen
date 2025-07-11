import 'package:flutter/material.dart';
import 'package:gennext/screens/auth/login.dart';
import 'package:gennext/screens/auth/signup.dart';
import 'package:gennext/screens/blog/blog.dart';
import 'package:gennext/screens/core/home.dart';
// import 'package:gennext/screens/core/homepage.dart';
import 'package:gennext/screens/core/listener.dart';
import 'package:gennext/screens/core/speaker.dart';
import 'package:gennext/screens/setting/loading.dart';
import 'package:gennext/screens/setting/profile_config.dart';
import 'package:gennext/screens/setting/search.dart';
import 'package:gennext/screens/setting/setting.dart';
import 'package:gennext/screens/setting/splashpage.dart';
import 'package:gennext/screens/shop/shoppage.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/login':
      return MaterialPageRoute(builder: (_) => const Login());
    case '/signup':
      return MaterialPageRoute(builder: (_) => const Signup());
    case '/blog':
      return MaterialPageRoute(builder: (_) => const Blogpage());
    case '/home':
      return MaterialPageRoute(builder: (_) => const Home());

    case '/loading':
      return MaterialPageRoute(builder: (_) => const Loading());
    case '/profile_config':
      return MaterialPageRoute(builder: (_) => const ProfileConfig());
    case '/search':
      return MaterialPageRoute(builder: (_) => const Searchpage());
    case '/setting':
      return MaterialPageRoute(builder: (_) => const Setting());
    case '/splash':
      return MaterialPageRoute(builder: (_) => const SplashScreen());
    case '/shop':
      return MaterialPageRoute(builder: (_) => const Shop());
    case '/talkerScreen':
      final zone = settings.arguments as String;
      return MaterialPageRoute(builder: (_) => ListenerScreen(zone: zone));

    case '/talker':
      final roomId = settings.arguments as String;
      return MaterialPageRoute(builder: (_) => Talker(roomId: roomId));

    default:
      return MaterialPageRoute(
        builder: (_) =>
            const Scaffold(body: Center(child: Text('Page not found'))),
      );
  }
}
