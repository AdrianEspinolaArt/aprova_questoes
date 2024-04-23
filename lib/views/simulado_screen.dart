import 'package:aprova_questoes/models/components/components_models.dart';
import 'package:flutter/material.dart';
import 'package:aprova_questoes/models/question_model.dart';
import 'dart:async';
import 'package:collection/collection.dart';
import 'package:aprova_questoes/views/resultado_simulado_screen.dart';

class SimuladoScreen extends StatefulWidget {
  final List<QuestionModel> questions;
  final int numberOfQuestions;
  final int timeInMinutes;

  const SimuladoScreen({
    super.key,
    required this.questions,
    required this.numberOfQuestions,
    required this.timeInMinutes,
  });

  @override
  _SimuladoScreenState createState() => _SimuladoScreenState();
}

class _SimuladoScreenState extends State<SimuladoScreen> {
  int _currentQuestionIndex = 0;
  late Timer _timer;
  int _countdown = 20; // 10 segundos para teste
  List<QuestionModel> _simuladoQuestions = [];
  final List<Map<String, dynamic>> _answers = [];
  

  @override
  void initState() {
    super.initState();
    _countdown = widget.timeInMinutes * 60;
    _startTimer();
    _embaralharQuestoes();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 0 && !_isMenuOpened) {
          _countdown--;
        } else if (_countdown <= 0) {
          _timer.cancel();
          _entregarSimulado();
        }
      });
    });
  }

  void _embaralharQuestoes() {
    List<QuestionModel> shuffledQuestions = List.from(widget.questions);
    shuffledQuestions.shuffle();
    _simuladoQuestions =
        shuffledQuestions.take(widget.numberOfQuestions).toList();
  }

  void _reiniciarSimulado() {
    _countdown = widget.timeInMinutes * 60;
    setState(() {
      _answers.clear();
      _currentQuestionIndex = 0;
    });
    _timer.cancel();
    _startTimer();
  }

  final bool _isMenuOpened = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simulado'),
      ),
      drawer: _buildDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTimer(),
                    const SizedBox(height: 16.0),
                    _buildQuestionInfo(),
                    const SizedBox(height: 8.0),
                    const SizedBox(height: 8.0),
                    const Text(
                      'Enunciado da Questão:',
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8.0),
                    _buildQuestionStatement(),
                    const SizedBox(height: 16.0),
                    const Text(
                      'Alternativas:',
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8.0),
                    _buildAlternativesList(),
                    const SizedBox(height: 1.0),
                  ],
                ),
              ),
            ),
          ),
          _buildBottomNavigationBar(),
        ],
      ),
    );
  }

Widget _buildDrawer() {
  return Drawer(
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20.0),
          child: const Text(
            "Menu",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 20), // Espaçamento entre o cabeçalho e as ListTile
        Expanded(
          child: ListView.builder(
            itemCount: _simuladoQuestions.length,
            itemBuilder: (context, index) {
              bool answered = _answers.any((answer) => answer['questionIndex'] == index);

              return InkWell(
                onTap: () {
                  setState(() {
                    _currentQuestionIndex = index;
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  margin: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 10.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: _currentQuestionIndex == index ? const Color(0xFF22005d).withOpacity(0.3) : Colors.transparent,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        'Questão ${index + 1}',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: _currentQuestionIndex == index ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(width: 10), // Espaçamento entre o texto da questão e a coluna de checks e hífens
                      Row(
                        children: [
                          answered
                              ? const Icon(Icons.check_circle, color: Color(0xFF346a22)) // Marcação para questão respondida
                              : const Text('-', style: TextStyle(fontSize: 20)), // Marcação para questão não respondida
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}

  Widget _buildTimer() {
    return Text(
      'Tempo restante: ${_formatDuration(Duration(seconds: _countdown))}',
      style: const TextStyle(fontSize: 18.0),
    );
  }

  Widget _buildQuestionInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Questão ${_currentQuestionIndex + 1} de ${_simuladoQuestions.length}',
          style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8.0),
        const Divider(),
        const SizedBox(height: 8.0),
      ],
    );
  }

  Widget _buildQuestionStatement() {
    return Text(
      _simuladoQuestions[_currentQuestionIndex].enunciado,
      style: const TextStyle(fontSize: 16.0),
    );
  }

  Widget _buildAlternativesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < _simuladoQuestions[_currentQuestionIndex].alternativas.length; i++)
          if (_simuladoQuestions[_currentQuestionIndex].alternativas[i].containsKey('text'))
            _buildAlternativeWidget(i),
      ],
    );
  }

  Widget _buildAlternativeWidget(int i) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      child: GestureDetector(
        onTap: () => _selectOption(i),
        child: buildShadowBox(
          context,
         Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color.fromARGB(82, 53, 53, 53),
            ),
            borderRadius: BorderRadius.circular(8.0),
            color: _getSelectedOptionIndex(_currentQuestionIndex) == i
                ? const Color(0XFFb5f39a)
                : const Color.fromARGB(255, 229, 229, 230),
          ),
          child: Text(
            '${String.fromCharCode(65 + i)}) ${_simuladoQuestions[_currentQuestionIndex].alternativas[i]['text']}',
            style: TextStyle(
              fontSize: 16.0,
              color: _getSelectedOptionIndex(_currentQuestionIndex) == i
                  ? Colors.black
                  : Colors.black,
            ),
          ),
        ),
         ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _currentQuestionIndex > 0 ? _previousQuestion : null,
          ),
          _buildCentralButton(),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: _currentQuestionIndex < _simuladoQuestions.length - 1 ? _nextQuestion : null,
          ),
        ],
      ),
    );
  }

  Widget _buildCentralButton() {
    return GestureDetector(
      onTap: _showBottomMenu,
      child: Container(
        width: 90,
        height: 90,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color.fromARGB(255, 68, 14, 161),
        ),
        child: Center(
          child: Text(
            _formatDuration(Duration(seconds: _countdown)),
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
        ),
      ),
    );
  }

void _showBottomMenu() {
  _timer.cancel();
  showDialog(
    context: context,
    barrierDismissible: false, // Impede que o diálogo seja fechado clicando fora dele
    builder: (BuildContext context) {
      return _buildAlertDialog();
    },
  );
}

AlertDialog _buildAlertDialog() {
  return AlertDialog(
    insetPadding: const EdgeInsets.only(bottom: 30.0), // Adiciona espaço na parte inferior
    contentPadding: const EdgeInsets.all(20.0),
    content: Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Resumo do Simulado',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          _buildTimer(),
          const SizedBox(height: 16.0),
          Expanded(
            child: SingleChildScrollView(
              child: 
                Container(
                margin: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.white, 
                ),
                child: DataTable(
                  columnSpacing: 40,
                  headingRowHeight: 40,
                  headingTextStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                  columns: const [
                    DataColumn(label: Text('Questão')),
                    DataColumn(label: Text('Resposta')),
                    DataColumn(label: Text('Tempo')),
                  ],
                  rows: _buildTableRows(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _startTimer();
                    },
                  ),
                  const Text('Voltar'),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      _reiniciarSimulado();
                      Navigator.of(context).pop();
                    },
                  ),
                  const Text('Reiniciar'),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.exit_to_app),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _confirmExit();
                    },
                  ),
                  const Text('Sair'),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.assignment_turned_in),
                    onPressed: _showEntregarSimuladoDialog,
                  ),
                  const Text('Entregar'),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

  void _selectOption(int alternativeIndex) {
    setState(() {
      _answers.removeWhere(
          (answer) => answer['questionIndex'] == _currentQuestionIndex);
      _answers.add({
        'questionIndex': _currentQuestionIndex,
        'alternativeIndex': alternativeIndex
      });
    });
  }

  int? _getSelectedOptionIndex(int questionIndex) {
    final selectedAnswer = _answers
        .firstWhereOrNull((answer) => answer['questionIndex'] == questionIndex);
    if (selectedAnswer != null) {
      return selectedAnswer['alternativeIndex'];
    }
    return null;
  }

  void _nextQuestion() {
    setState(() {
      _currentQuestionIndex++;
    });
  }

  void _previousQuestion() {
    setState(() {
      _currentQuestionIndex--;
    });
  }


String formatarTempo(int tempoEmSegundos) {
  int horas = tempoEmSegundos ~/ 3600;
  int minutos = (tempoEmSegundos % 3600) ~/ 60;
  int segundos = tempoEmSegundos % 60;

  String horasStr = horas.toString().padLeft(2, '0');
  String minutosStr = minutos.toString().padLeft(2, '0');
  String segundosStr = segundos.toString().padLeft(2, '0');

  return '$horasStr:$minutosStr:$segundosStr';
}

void _entregarSimulado() {
  int acertos = 0;
  List<bool> questoesCorretas = [];
  for (var i = 0; i < _simuladoQuestions.length; i++) {
    var respostaUsuario = _answers.firstWhere(
      (answer) => answer['questionIndex'] == i,
      orElse: () => {'alternativeIndex': -1},
    );
    if (respostaUsuario['alternativeIndex'] != -1 &&
        _simuladoQuestions[i].alternativas[respostaUsuario['alternativeIndex']]['isCorrect']) {
      acertos++;
      questoesCorretas.add(true);
    } else {
      questoesCorretas.add(false);
    }
  }
  double nota = (acertos / _simuladoQuestions.length) * 10;
  // Arredonda a nota para o valor inteiro mais próximo
  nota = nota.roundToDouble();

  // Calcula o tempo total do simulado
  int tempoTotalSimulado = widget.timeInMinutes * 60;
  // Calcula o tempo que o usuário levou para finalizar o simulado
  int tempoUsuario = tempoTotalSimulado - _countdown;
  // Formata o tempo do usuário
  String tempoUsuarioFormatado = formatarTempo(tempoUsuario);

  Navigator.of(context).pop();
  Navigator.of(context).push(MaterialPageRoute(
    builder: (context) => ResultadoSimuladoScreen(
      nota: nota,
      questoesCorretas: questoesCorretas,
      simuladoQuestions: _simuladoQuestions,
      answers: _answers,
      tempoUsuario: tempoUsuarioFormatado, // Passa o tempo formatado para a página de resultado
    ),
  ));
}

  void _showEntregarSimuladoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Entregar Simulado'),
          content: const Text('Tem certeza de que deseja entregar o simulado?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _entregarSimulado();
              },
              child: const Text('Sim'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

List<DataRow> _buildTableRows() {
  List<DataRow> rows = [];
  // Ordenar as respostas com base no índice da questão
  _answers.sort((a, b) => a['questionIndex'].compareTo(b['questionIndex']));
  for (int i = 0; i < _answers.length; i++) {
    var questionIndex = _answers[i]['questionIndex'];
    var alternativeIndex = _answers[i]['alternativeIndex'];
    
    // Verificar se a questão foi respondida ou não
    var response = '-';
    if (alternativeIndex != null) {
      response = String.fromCharCode(alternativeIndex + 65);
    }
    
    rows.add(
      DataRow(
        cells: [
          DataCell(
            Center(
              child: Text('${questionIndex + 1}'),
            ),
          ),
          DataCell(
            Center(
              child: Text(response),
            ),
          ),
          DataCell(
            Center(
              child: Text(_formatDuration(const Duration())),
            ),
          ),
        ],
      ),
    );
  }
  return rows;
}

  void _confirmExit() {
    Navigator.of(context).pop();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
    } else {
      return '$twoDigitMinutes:$twoDigitSeconds';
    }
  }
}
