import 'package:dreith/main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart';

Future<void>handleBackgroundMessage(RemoteMessage message) async {
  print('Title:${message.notification?.title}');
  print('Body:${message.notification?.body}');
  print('Payload: ${message.data}');
}
class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;
  void handleBackgroundMessage(Request message) async{
        navigatorkey.currentState?.pushNamed('/notification',arguments: message);
  }

  void handleMessage(RemoteMessage? message) {
    if(message==null) return;

    navigatorkey.currentState?.pushNamed('/notification',arguments: message);
  
  }
  Future initPushNotification() async{
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  }
  
  Future<void>initNotification() async{
    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
    print('Token: $fCMToken');
    initPushNotification();
  }
  
}
