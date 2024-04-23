import 'dart:math';
import 'package:aprova_questoes/views/home_screen.dart';
import 'package:aprova_questoes/views/new_simulado.dart';
import 'package:flutter/material.dart';
import 'package:aprova_questoes/controllers/discipline_controller.dart';
import 'package:aprova_questoes/models/discipline_model.dart';
import 'package:aprova_questoes/views/question_list.dart';
import 'package:aprova_questoes/models/components/components_models.dart';

class SecondScreen extends StatefulWidget {
  const SecondScreen({super.key, Key});

  @override
  _SecondScreenState createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  final DisciplineController _disciplineController = DisciplineController();
  List<Discipline> _disciplines = [];
  List<Discipline> _displayedDisciplines = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isSortedAlphabetically = false;
  int _currentPage = 0;
  final int _itemsPerPage = 8;

  @override
  void initState() {
    super.initState();
    _loadDisciplines();
  }

  Future<void> _loadDisciplines() async {
    List<Discipline> disciplines = await _disciplineController.getDisciplines();
    setState(() {
      _disciplines = disciplines;
      _displayedDisciplines = _paginateDisciplines(disciplines, _currentPage, _itemsPerPage);
    });
  }

  List<Discipline> _paginateDisciplines(List<Discipline> disciplines, int currentPage, int itemsPerPage) {
    int startIndex = currentPage * itemsPerPage;
    int endIndex = min(startIndex + itemsPerPage, disciplines.length);
    return disciplines.sublist(startIndex, endIndex);
  }
  int _currentIndex = 2;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disciplinas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort_by_alpha),
            onPressed: _sortDisplayedDisciplinesAlphabetically,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: buttonPesq(),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _displayedDisciplines.length,
              itemBuilder: (context, index) {
                return buildOption(context, _displayedDisciplines[index]);
              },
            ),
          ),
          _buildPaginationButtons(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            if (index == 0) {
             Navigator.of(context).push(_homeRoute());
            }
            if (index == 1) {
             Navigator.of(context).push(_createRoute());
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
            icon: Icon(Icons.subject), // Alterado para o ícone de Disciplinas
            label: 'Disciplinas',
          ),
        ],
      ),
    );
  }

  Route _homeRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => const HomeView(),
    transitionsBuilder: buildTransitions,
  );
}

  Route _createRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => const NewSimuladoScreen(),
    transitionsBuilder: buildTransitions,
  );
}



  Widget buildOption(BuildContext context, Discipline discipline) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.0),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Questionlist(disciplineId: discipline.id)),
            );
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 12.0,
            ),
            minimumSize: const Size(120, 0),
          ),
          child: Text(
            discipline.name,
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationButtons() {
    int totalPages = (_disciplines.length / _itemsPerPage).ceil();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _currentPage == 0 ? null : () => _changePage(-1),
        ),
        Text('Página ${_currentPage + 1} de $totalPages'),
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: _currentPage == totalPages - 1 ? null : () => _changePage(1),
        ),
      ],
    );
  }


  Widget buttonPesq(){
    return Padding(
    padding: const EdgeInsets.all(9.0),
    child: TextField(
      controller: _searchController,
      onChanged: _filterDisciplines,
      decoration: InputDecoration(
        hintText: 'Pesquisar...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0), // Define o raio das bordas
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0), // Define o espaçamento interno
      ),
    ),
  );
}
  
  void _filterDisciplines(String query) {
    setState(() {
      _currentPage = 0;
      _displayedDisciplines = _paginateDisciplines(
        _disciplines.where((discipline) {
          return discipline.name.toLowerCase().contains(query.toLowerCase());
        }).toList(),
        _currentPage,
        _itemsPerPage,
      );
    });
  }

  void _sortDisplayedDisciplinesAlphabetically() {
    setState(() {
      _isSortedAlphabetically = !_isSortedAlphabetically;
      _disciplines.sort((a, b) => _isSortedAlphabetically ? a.name.compareTo(b.name) : b.name.compareTo(a.name));
      _displayedDisciplines = _paginateDisciplines(_disciplines, _currentPage, _itemsPerPage);
    });
  }

  void _changePage(int increment) {
    setState(() {
      _currentPage += increment;
      _displayedDisciplines = _paginateDisciplines(_disciplines, _currentPage, _itemsPerPage);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
}
