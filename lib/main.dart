import 'dart:convert';

import 'package:api_cache_manager/models/cache_db_model.dart';
import 'package:api_cache_manager/utils/cache_manager.dart';
import 'package:checkpoint/provider/AuthProvider.dart';
import 'package:checkpoint/provider/GetProvider.dart';
import 'package:checkpoint/provider/PostProvider.dart';
import 'package:checkpoint/provider/conversation_provider.dart';
import 'package:checkpoint/style/constants.dart';
import 'package:checkpoint/ui/Auth/board.dart';
import 'package:checkpoint/ui/Home.dart';
import 'package:checkpoint/ui/Splash.dart';
import 'package:checkpoint/ui/maps.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

Future<dynamic> _firebaseMessagingBackgroundHandler(RemoteMessage message,
    {BuildContext? context}) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  bool exist = await APICacheManager().isAPICacheKeyExist('back_notify');
  print('Handling a background message111 ${message.data}');
  if (exist) {
    bool test = await APICacheManager().isAPICacheKeyExist('back_notify');
    if (test) {
      var temp = await APICacheManager().getCacheData('back_notify');
      if (temp != null) {
        var data = jsonDecode(temp.syncData);

        data.add(message.data);
        APICacheDBModel apiCacheDBModel =
            APICacheDBModel(key: 'back_notify', syncData: jsonEncode(data));
        await APICacheManager().addCacheData(apiCacheDBModel);
      }
    }
  } else {
    List data = [];
    data.add(message.data);
    APICacheDBModel apiCacheDBModel =
        APICacheDBModel(key: 'back_notify', syncData: jsonEncode(data));
    await APICacheManager().addCacheData(apiCacheDBModel);
  }

  return message.data;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await Firebase.initializeApp();
  //SharedPreferences.setMockInitialValues({});
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  /*await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);*/

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]).then((_) => runApp(EasyLocalization(
      supportedLocales: [Locale('ar', 'SA'), Locale('en', 'US')],
      path: 'assets/lang', // <-- change patch to your
      fallbackLocale: Locale('en', 'US'),
      saveLocale: true, //saveLocale: true,
      startLocale: Locale('en', 'US'),
      child: MultiProvider(providers: [
        ChangeNotifierProvider<GetProvider>(
          create: (_) => GetProvider(),
        ),
        ChangeNotifierProvider<ConversationProvider>(
          create: (_) => ConversationProvider(),
        ),
        ChangeNotifierProvider<PostProvider>(
          create: (_) => PostProvider(),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
      ], child: MyApp()))));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //  model.changeLanguage(EasyLocalization.of(context).locale);
    return ScreenUtilInit(
      designSize: Size(480, 800),
      builder: (ctx, c) => MaterialApp(
        key: ValueKey<Locale>(context.locale),
        debugShowCheckedModeBanner: false,
        title: 'checkpoint',
        theme: ThemeData(
          fontFamily: GoogleFonts.elMessiri().fontFamily,
          primaryColor: PrimaryColor,
          // accentColor: AccentColor,
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
        ),
        supportedLocales: EasyLocalization.of(context)!.supportedLocales,
        locale: EasyLocalization.of(context)!.locale,
        localizationsDelegates: context.localizationDelegates,
        localeResolutionCallback: (deviceLocale, supportedLocales) {
          for (var locale in supportedLocales) {
            if (locale.languageCode == deviceLocale?.languageCode &&
                locale.countryCode == deviceLocale?.countryCode) {
              return deviceLocale;
            }
          }
          return supportedLocales.first;
        },
        initialRoute: 'splash', //model.login?'main':'login',
        routes: {
          'splash': (context) => Splash(),
          'home': (context) => Home(),
          'login': (context) => Board(),
          'map': (context) => MapScreen(),
        },
      ),
    );
  }
}
