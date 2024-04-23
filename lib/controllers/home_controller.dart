import 'package:flutter/material.dart';
import 'package:aprova_questoes/views/second_screen.dart';


class HomeController {
  void onButtonPressed(BuildContext context) {
    // Navegar para a segunda tela
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SecondScreen()),
    );
  }
}