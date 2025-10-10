import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/home_screen.dart';
import 'screens/call_summaries_screen.dart';
import 'services/api_key_manager.dart';
import 'services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // تهيئة قاعدة البيانات
  final db = DatabaseService();
  await db.init();
  
  // تهيئة مدير API Keys
  final apiKeyManager = APIKeyManager();
  await apiKeyManager.loadKeys();
  
  // إعداد التطبيق
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  
  runApp(MyApp(apiKeyManager: apiKeyManager));
}

class MyApp extends StatelessWidget {
  final APIKeyManager apiKeyManager;
  
  const MyApp({super.key, required this.apiKeyManager});

  @override
  Widget build(BuildContext context) {
    return Provider<APIKeyManager>.value(
      value: apiKeyManager,
      child: MaterialApp(
        title: '🤖 Smart Assistant',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          textTheme: GoogleFonts.cairoTextTheme(),
        ),
        home: HomeScreen(),
      ),
    );
  }
}

