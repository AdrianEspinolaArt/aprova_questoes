import 'package:aprova_questoes/models/components/components_models.dart';
import 'package:flutter/material.dart';
import 'package:aprova_questoes/controllers/home_controller.dart';
import 'package:aprova_questoes/views/new_simulado.dart';
import 'package:aprova_questoes/views/second_screen.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final HomeController _controller = HomeController();
  int _currentIndex = 0;

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Aprova'),
      automaticallyImplyLeading: false,
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color.fromARGB(255, 236, 182, 2), width: 4), // Adiciona a borda ao redor do CircleAvatar
                          ),
                          child: const CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.black,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 35,
                            height: 35,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green,
                            ),
                            child: IconButton(
                              onPressed: () {
                                // Adicione a função desejada para editar o perfil
                              },
                              icon: const Icon(Icons.edit, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                      width:
                          20), // Espaçamento entre a foto do perfil e o restante dos elementos
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Nome do Usuário',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        const Row(
                          children: [
                            SizedBox(width: 5),
                            Text(
                              'Nível: 10', // Substitua pelo valor real do XP
                              style: TextStyle(fontSize: 16),
                            ),
                            Icon(Icons.bolt,
                                color: Color.fromARGB(255, 160, 59, 255)),
                          ],
                        ),
                        const SizedBox(width: 5),
                        const LinearProgressIndicator(
                          semanticsLabel: 'Linear progress indicator',
                          value:
                              0.8, // Defina o valor desejado aqui (de 0 a 1)
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            _controller.onButtonPressed(context);
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.green,
                          ),
                          child: const Text('Editar Perfil'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20), // Espaçamento entre os Cards
          const Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PieChartSample3(),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    bottomNavigationBar: _buildBottomNavigationBar(),
  );
}


  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
          if (index == 1) {
            Navigator.of(context).push(_simuladoRoute());
          }
          if (index == 2) {
            Navigator.of(context).push(_disciplineRoute());
          }
        });
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add),
          label: 'Criar simulado',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.subject),
          label: 'Disciplinas',
        ),
      ],
    );
  }

  Route _simuladoRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const NewSimuladoScreen(),
      transitionsBuilder: buildTransitions,
    );
  }

  Route _disciplineRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const SecondScreen(),
      transitionsBuilder: buildTransitions,
    );
  }
}
