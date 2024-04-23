import 'package:flutter/material.dart';
import 'package:aprova_questoes/controllers/question_controller.dart';
import 'package:aprova_questoes/models/question_model.dart';
import 'package:aprova_questoes/views/question_screen.dart';
import 'package:aprova_questoes/views/simulado_screen.dart';

class Questionlist extends StatefulWidget {
  final String disciplineId;

  const Questionlist({super.key, required this.disciplineId});

  @override
  _QuestionlistState createState() => _QuestionlistState();
}

class _QuestionlistState extends State<Questionlist> {
  final QuestionController _questionController = QuestionController();
  late List<QuestionModel> _questions = [];
  List<QuestionModel> _displayedQuestions = [];
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 0;
  final int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    List<QuestionModel> questions =
        await _questionController.getQuestionsForDiscipline(widget.disciplineId);
    setState(() {
      _questions = questions;
      _displayedQuestions = _paginateQuestions(questions, _currentPage, _itemsPerPage);
    });
  }

  List<QuestionModel> _paginateQuestions(
      List<QuestionModel> questions, int currentPage, int itemsPerPage) {
    int startIndex = currentPage * itemsPerPage;
    int endIndex = startIndex + itemsPerPage;
    return questions.sublist(startIndex, endIndex.clamp(0, questions.length));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Questões da Disciplina'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buttonPesqQuestion(),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10.0),
            child: ElevatedButton(
              onPressed: () {
                showSimuladoOptionsPopup(context);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                minimumSize: const Size(80, 0),
              ),
              child: const Text('Simulado'),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _displayedQuestions.length,
              itemBuilder: (context, index) {
                return buildOption(context, _displayedQuestions[index]);
              },
            ),
          ),
          _buildPaginationButtons(),
        ],
      ),
    );
  }

  Widget buttonPesqQuestion() {
    return Padding(
      padding: const EdgeInsets.all(9.0),
      child: TextField(
        controller: _searchController,
        onChanged: _filterQuestions,
        decoration: InputDecoration(
          hintText: 'Pesquisar...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0), // Define o raio das bordas
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0), // Define o espaçamento interno
        ),
      ),
    );
  }

  Widget buildOption(BuildContext context, QuestionModel question) {
    return ListTile(
      title: Text('ID: ${question.id}'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => QuestionScreen(question: question)),
        );
      },
    );
  }

  Widget _buildPaginationButtons() {
    int totalPages = (_questions.length / _itemsPerPage).ceil();
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

  void _filterQuestions(String query) {
    setState(() {
      _currentPage = 0;
      _displayedQuestions = _paginateQuestions(
        _questions.where((question) {
          return question.id.toLowerCase().contains(query.toLowerCase());
        }).toList(),
        _currentPage,
        _itemsPerPage,
      );
    });
  }

  void _changePage(int increment) {
    setState(() {
      _currentPage += increment;
      _displayedQuestions = _paginateQuestions(_questions, _currentPage, _itemsPerPage);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void showSimuladoOptionsPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimuladoOptionsPopup(
          totalQuestions: _questions.length,
          onStartSimulado: _startSimulado,
        );
      },
    );
  }

  void _startSimulado(int numberOfQuestions, int estimatedTotalTime) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SimuladoScreen(
          questions: _questions,
          numberOfQuestions: numberOfQuestions,
          timeInMinutes: estimatedTotalTime,
        ),
      ),
    );
  }
}

class SimuladoOptionsPopup extends StatefulWidget {
  final Function(int, int) onStartSimulado;
  final int totalQuestions;

  const SimuladoOptionsPopup({super.key, required this.onStartSimulado, required this.totalQuestions});

  @override
  _SimuladoOptionsPopupState createState() => _SimuladoOptionsPopupState();
}

class _SimuladoOptionsPopupState extends State<SimuladoOptionsPopup> {
  int _selectedNumberOfQuestions = 5;  
  int _selectedTimeInMinutes = 10;
  int _selectedEndOfTime = 0; // Defina um valor padrão para o radio button

  @override
  Widget build(BuildContext context) {
    // Cálculo do tempo total estimado
    int estimatedTotalTime = _selectedNumberOfQuestions * _selectedTimeInMinutes;

    return AlertDialog(
      title: const Text('Opções do Simulado'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quantidade de Questões: ${widget.totalQuestions}'),
          const Text('Selecione a quantidade de questões para o simulado:'),
          DropdownButton<int>(
            value: _selectedNumberOfQuestions,
            onChanged: (value) {
              setState(() {
                _selectedNumberOfQuestions = value!;
              });
            },
            items: List.generate(16, (index) => (index + 1) * 5).map<DropdownMenuItem<int>>((value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text('$value'),
              );
            }).toList(),
          ),
          const Text('Tempo para cada questão:'),
          DropdownButton<int>(
            value: _selectedTimeInMinutes,
            onChanged: (value) {
              setState(() {
                _selectedTimeInMinutes = value!;
              });
            },
            items: [ 1, 2, 3, 4, 5, 8, 10].map<DropdownMenuItem<int>>((value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text('$value'),
              );
            }).toList(),
          ),
          const Text('O tempo total do simulado será limitado pelo tempo definido para cada questão?'),
          Row(
            children: [
              Expanded(
                child: RadioListTile<int>(
                  title: const Text('Sim'),
                  value: 1,
                  groupValue: _selectedEndOfTime,
                  onChanged: (value) {
                    setState(() {
                      _selectedEndOfTime = value!;
                    });
                  },
                ),
              ),
              Expanded(
                child: RadioListTile<int>(
                  title: const Text('Não'),
                  value: 0,
                  groupValue: _selectedEndOfTime,
                  onChanged: (value) {
                    setState(() {
                      _selectedEndOfTime = value!;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Tempo total estimado: $estimatedTotalTime minutos'),
        ],
      ),
      actions: [
        Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                minimumSize: const Size(100, 0),
              ),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                widget.onStartSimulado(_selectedNumberOfQuestions, estimatedTotalTime);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                minimumSize: const Size(100, 0),
              ),
              child: const Text('Iniciar'),
            ),
          ],
        ),
      ],
    );
  }
}