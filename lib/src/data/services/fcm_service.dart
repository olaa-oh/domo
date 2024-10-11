// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// class FCMService {
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//   final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//    Future<void> initialize() async {
//     // Request permission for iOS devices
//     await _firebaseMessaging.requestPermission(
//       alert: true,
//       badge: true,
//       provisional: false,
//       sound: true,
//       criticalAlert: false,
//       announcement: true,
//       carPlay: false,

//     );

//     // Configure FCM
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       _showNotification(message);
//     });

//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       // Handle notification tapped logic here
//     });

//     // Initialize local notifications
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');
//     final DarwinInitializationSettings initializationSettingsIOS =
//         const DarwinInitializationSettings();
//     final InitializationSettings initializationSettings =
//         InitializationSettings(
//       android: initializationSettingsAndroid,
//       iOS: initializationSettingsIOS,
//     );
//     await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
//   }

//   Future<String?> getToken() async {
//     final deviceToken = await _firebaseMessaging.getToken();
//     print("device token: $deviceToken");
//     return deviceToken;
//   }

//   void _showNotification(RemoteMessage message) async {
//     RemoteNotification? notification = message.notification;
//     AndroidNotification? android = message.notification?.android;

//     if (notification != null && android != null) {
//       await _flutterLocalNotificationsPlugin.show(
//         notification.hashCode,
//         notification.title,
//         notification.body,
//         const NotificationDetails(
//           android: AndroidNotificationDetails(
//             'channel_id',
//             'channel_name',
//             importance: Importance.max,
//             priority: Priority.high,
//           ),
//         ),
//       );
//     }
//   }
// }