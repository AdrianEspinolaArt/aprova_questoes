import 'package:aprova_questoes/src/shared/themes/color_schemes.g.dart';
import 'package:aprova_questoes/views/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,  
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aprova Questões',
      
      theme: 
      ThemeData(
        primaryColor: lightColorScheme.primary,
       
       elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 5,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              side: BorderSide(color: Color(0xFF22005D)), // Cor da borda do Button
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0), // Raio de curvatura da borda
            ),
          ),
          ),
        ),
       cardTheme: CardTheme(
            elevation: 5,
            color: lightColorScheme.primaryContainer.withOpacity(1.0),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              side: BorderSide(color: Color(0xFF6750A4), ), 
            ),
          ),

        chipTheme: const ChipThemeData(
          
          backgroundColor: Color(0xFFE9DDFF),
          ),

        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: lightColorScheme.primary,
          foregroundColor: Colors.white,
          ),

        dialogTheme: DialogTheme(
          backgroundColor: lightColorScheme.primaryContainer,
        ),

        drawerTheme: DrawerThemeData(
          backgroundColor: lightColorScheme.secondaryContainer,
          ),

        scaffoldBackgroundColor: lightColorScheme.secondaryContainer,  
        appBarTheme: AppBarTheme(
          backgroundColor: lightColorScheme.primary,
          foregroundColor: lightColorScheme.onPrimary     
             
        ),

        bottomAppBarTheme: BottomAppBarTheme(
          color: lightColorScheme.primaryContainer.withOpacity(1.0),
          ),
        
        useMaterial3: true, 
        colorScheme: lightColorScheme,
        ),

      darkTheme: 
      
      ThemeData(
        useMaterial3: true, 
        colorScheme: darkColorScheme
        
        
        ),
      home: const HomeView(),
    );
  }
}