import 'package:flutter/material.dart';
import 'package:aprova_questoes/controllers/question_controller.dart';
import 'package:aprova_questoes/controllers/discipline_controller.dart';
import 'package:aprova_questoes/models/discipline_model.dart';
import 'package:aprova_questoes/models/question_model.dart';
import 'package:aprova_questoes/views/simulado_screen.dart';

class NewSimuladoScreen extends StatefulWidget {
  const NewSimuladoScreen({super.key});

  @override
  _NewSimuladoScreenState createState() => _NewSimuladoScreenState();
  
}

class _NewSimuladoScreenState extends State<NewSimuladoScreen> {
  final QuestionController _questionController = QuestionController();
  final DisciplineController _disciplineController = DisciplineController();
  List<Discipline> _disciplines = [];
  final List<Discipline> _selectedDisciplines = [];
  int _quantityQuestions = 10;
  int _timePerQuestion = 5;
  int _selectedEndOfTime = 0;
  @override
  void initState() {
    super.initState();
    _loadDisciplines();
  }

  Future<void> _loadDisciplines() async {
    List<Discipline> disciplines = await _disciplineController.getDisciplines();
    setState(() {
      _disciplines = disciplines;
    });
  }

  Widget _buildQuantityDropdown() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text('Quantidade de Questões:'),
        const SizedBox(height: 10),
        DropdownButton<int>(
          value: _quantityQuestions,
          onChanged: (value) {
            setState(() {
              _quantityQuestions = value!;
            });
          },
          items: [10, 15, 20, 40, 50, 80, 100].map((value) {
            return DropdownMenuItem<int>(
              value: value,
              child: Text('$value'),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTimePerQuestionDropdown() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text('Tempo por Questão (minutos):'),
        const SizedBox(height: 10),
        DropdownButton<int>(
          value: _timePerQuestion,
          onChanged: (value) {
            setState(() {
              _timePerQuestion = value!;
            });
          },
          items: [1, 2, 3, 5, 10].map((value) {
            return DropdownMenuItem<int>(
              value: value,
              child: Text('$value'),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _handleEndOfTimeSelection(int? value) {
    setState(() {
      _selectedEndOfTime = value!;
    });
  }

  Widget _buildSelectedDisciplinesChips() {
    // Criar os chips
    List<Widget> chips = _selectedDisciplines
        .map(
          (discipline) => Chip(
            key: ValueKey(discipline), // Chave única para manter a ordem
            label: Text(
              discipline.name,
              style: const TextStyle(fontSize: 12.0),
            ),
            onDeleted: () {
              setState(() {
                _selectedDisciplines.remove(discipline);
              });
            },
          ),
        )
        .toList();

    // Ordenar os chips com base na quantidade de caracteres nos rótulos
    chips.sort((a, b) {
      int lengthA = (a.key as ValueKey).value.name.length;
      int lengthB = (b.key as ValueKey).value.name.length;
      return lengthA.compareTo(lengthB);
    });

    return Center(
      child: Container(
        padding: const EdgeInsets.all(5.0),
        child: SingleChildScrollView(
          child: Wrap(
            alignment: WrapAlignment.center, // Centralizar os chips
            spacing: 10.0,
            runSpacing: 0.5,
            children: chips,
          ),
        ),
      ),
    );
  }

  Widget _buildDisciplineSelectionList() {
    return Container(
      color: Colors.white.withOpacity(0.1),
      height: 180, // Altura fixa do container
      child: SingleChildScrollView(
        child: Column(
          children: _disciplines
              .map((discipline) => CheckboxListTile(
                    title: Text(discipline.name),
                    value: _selectedDisciplines.contains(discipline),
                    onChanged: (value) {
                      _toggleDisciplineSelection(discipline);
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _opAvanced() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _buildOpAvanced();
      },
    );
  }

  void _clearSelectedDisciplines() {
    setState(() {
      _selectedDisciplines.clear();
    });
  }

  Widget _buildBottomButtons() {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildCentralButton(),
        ],
      ),
    );
  }

  Widget _buildCentralButton() {
    return GestureDetector(
      onTap: _startSimulation,
      child: Container(
        width: 90,
        height: 90,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color.fromARGB(255, 68, 14, 161),
        ),
        child: const Center(
          child: Icon(
            Icons.play_arrow,
            color: Color(0xFFE9DDFF),
          ),
        ),
      ),
    );
  }

  void _startSimulation() async {
    if (_selectedDisciplines.isNotEmpty &&
        _quantityQuestions > 0 &&
        _timePerQuestion > 0) {
      List<String> selectedDisciplineIds =
          _selectedDisciplines.map((discipline) => discipline.id).toList();
      List<QuestionModel> questions =
          await _questionController.getRandomQuestionsFromAllDisciplines(
              selectedDisciplineIds, _quantityQuestions);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SimuladoScreen(
            questions: questions,
            numberOfQuestions: _quantityQuestions,
            timeInMinutes: _timePerQuestion * _quantityQuestions,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Selecione disciplinas e preencha a quantidade/tempo de questões corretamente.'),
        ),
      );
    }
  }

  AlertDialog _buildOpAvanced() {
    return AlertDialog(
      title: const Text('Opções Avançadas'),
      content: SizedBox(
        width: 400,
        height: 300,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                      'O simulado será finalizado ao término do tempo determinado?'),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<int>(
                          title: const Text('Sim'),
                          value: 1,
                          groupValue: _selectedEndOfTime,
                          onChanged: _handleEndOfTimeSelection,
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<int>(
                          title: const Text('Não'),
                          value: 0,
                          groupValue: _selectedEndOfTime,
                          onChanged: _handleEndOfTimeSelection,
                        ),
                      ),
                    ],
                  ),
                  const Center(
                    child: Text(
                      'Ao optar por "não", o simulado poderá estender-se além do tempo estabelecido para cada pergunta',
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 7, 7),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Confirmar'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDisciplineSelectionCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDisciplineSelectionList(),
      ],
    );
  }

  void _toggleDisciplineSelection(Discipline discipline) {
    setState(() {
      if (!_selectedDisciplines.contains(discipline)) {
        if (_selectedDisciplines.length < 5) {
          _selectedDisciplines.add(discipline);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Limite máximo de 5 disciplinas atingido.'),
            ),
          );
        }
      } else {
        _selectedDisciplines.remove(discipline);
      }
    });
  }

void _filterFullDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) => Dialog(
      insetPadding: EdgeInsets.zero,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildFilterField(label: 'Data'),
              _buildFilterField(label: 'Banca'),
              _buildFilterField(label: 'Disciplina'),
              _buildFilterField(label: 'Assunto'),
              _buildFilterField(label: 'Cargo'),
              _buildFilterField(label: 'Prova'),
              _buildFilterField(label: 'Ano'),
              _buildFilterField(label: 'Nível'),
              _buildFilterField(label: 'Área de Formação'),
              _buildFilterField(label: 'Modalidade'),
              _buildFilterField(label: 'Instituição'),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildFilterField({required String label}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      TextField(
        decoration: InputDecoration(
          hintText: 'Digite o filtro para $label',
          border: const OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 20),
    ],
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Simulado'),
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              const SizedBox(height: 20),
              Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      title: const Text('Selecione as Disciplinas'),
                      trailing: IconButton(
                        icon: const Icon(Icons.filter_list),
                        onPressed: () {
                          _filterFullDialog();
                        },
                      ),
                    ),
                    Column(
                      children: <Widget>[
                        _buildDisciplineSelectionCard(),
                        const SizedBox(height: 2),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              _clearSelectedDisciplines();
                            },
                            child: const Text('Limpar'),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          _buildSelectedDisciplinesChips(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      title:
                          Text('Tempo Total: ${_calculateTotalTime()} minutos'),
                    ),
                    Column(
                      children: <Widget>[
                        _buildQuantityDropdown(),
                        const SizedBox(height: 2),
                        _buildTimePerQuestionDropdown(),
                        const SizedBox(height: 2),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  _opAvanced();
                                },
                                child: const Text('Opções Avançadas'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          )),
      bottomNavigationBar: _buildBottomButtons(),
    );
  }

  int _calculateTotalTime() {
    return _quantityQuestions * _timePerQuestion;
  }
}
