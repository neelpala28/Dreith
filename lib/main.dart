import 'package:dreith/screens/home/create_post_screen.dart';
import 'package:dreith/screens/profile/edit_profile.dart';
import 'package:dreith/firebase_options.dart';
import 'package:dreith/screens/profile/followers_list.dart';
import 'package:dreith/screens/profile/following_list.dart';
import 'package:dreith/screens/auth/forgot_password.dart';
import 'package:dreith/screens/home/home_screen.dart';
import 'package:dreith/landing_page.dart';
import 'package:dreith/screens/auth/login.dart';
import 'package:dreith/screens/profile/profile_page.dart';
import 'package:dreith/screens/auth/sign_up.dart';
import 'package:dreith/core/theme_data.dart';
import 'package:dreith/user_details.dart';
import 'package:dreith/providers/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAuth.instance.currentUser?.reload();

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => UserProvider())],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Dreith",
      theme: dreithDarkTheme,
      home: LandingPage(),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/login': (context) => Login(),
        '/signup': (context) => SignUp(),
        '/forgotpassword': (context) => ForgotPassword(),
        '/homescreen': (context) => HomeScreen(),
        '/profile': (context) => ProfilePage(),
        '/createpost': (context) => CreatePostScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/userdetails') {
          final userId = settings.arguments as String; // ✅ get the id
          return MaterialPageRoute(
            builder: (context) => UserDetails(id: userId),
          );
        } else if(settings.name == '/followerslist'){
          final userId = settings.arguments as String;
          return MaterialPageRoute(builder: (context) => FollowersList(id: userId,));
        } else if(settings.name == '/followinglist'){
          final userId = settings.arguments as String;
          return MaterialPageRoute(builder: (context) => FollowingList(id: userId,));
        } else if(settings.name ==  '/editprofile'){
          final currentUserId = settings.arguments as String;
          return MaterialPageRoute(builder: (context) => EditProfile(id: currentUserId));
        }

        return null;
      },
    );
  }
}
