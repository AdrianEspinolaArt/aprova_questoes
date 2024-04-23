import 'package:aprova_questoes/src/shared/themes/color_schemes.g.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:aprova_questoes/models/question_model.dart';
import 'package:aprova_questoes/models/components/components_models.dart';

class QuestionScreen extends StatefulWidget {
  final QuestionModel question;

  const QuestionScreen({super.key, required this.question});

  @override
  _QuestionScreenState createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  late String selectedOption = '';
  // ignore: unused_field
  int? _selectedOptionIndex; // Adicionando a variável para controlar a opção selecionada
  final List<Map<String, dynamic>> _answers = []; // Lista para armazenar as respostas selecionadas e se estão corretas

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Questão'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enunciado da Questão:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              Text(
                widget.question.enunciado,
                style: const TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Alternativas:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < widget.question.alternativas.length; i++) ...[
                  if (widget.question.alternativas[i].containsKey('text')) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: GestureDetector(
                        onTap: () => _selectOption(i),
                        child: buildShadowBox(
                          context,
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            decoration: BoxDecoration(
                              color: lightColorScheme.onSecondary,
                              border: Border.all(
                                color: const Color.fromARGB(82, 53, 53, 53),
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Text(
                              '${String.fromCharCode(65 + i)}) ${widget.question.alternativas[i]['text']}',
                              style: TextStyle(
                                fontSize: 16.0,
                                color: _getSelectedOptionIndex(widget.question.id) != null && _getSelectedOptionIndex(widget.question.id) == i
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ],
            ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              onPressed: () {
                // Lógica para gerar uma nova questão
              },
              child: const Text('Pular'),
            ),
            ElevatedButton(
              onPressed: () {
                // Lógica para voltar para a tela anterior
                Navigator.pop(context);
              },
              child: const Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }

void _selectOption(int alternativeIndex) {
  setState(() {
    _answers.removeWhere((answer) => answer['questionIndex'] == widget.question.id);
    _answers.add({
      'questionIndex': widget.question.id,
      'alternativeIndex': alternativeIndex
    });
    _showResultPopup(widget.question.alternativas[alternativeIndex]['isCorrect'] as bool);
  });
}

int? _getSelectedOptionIndex(String questionId) {
  final selectedAnswer = _answers.firstWhereOrNull(
      (answer) => answer['questionIndex'] == questionId);
  if (selectedAnswer != null) {
    return selectedAnswer['alternativeIndex'];
  }
  return null;
}

  void _showResultPopup(bool isCorrect) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isCorrect ? 'Parabéns!' : 'Tentar novamente'),
          content: Text(isCorrect ? 'Você acertou!' : 'Você errou. Tente novamente.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}