import 'package:flutter/material.dart';
import 'package:aprova_questoes/models/question_model.dart';
import 'package:aprova_questoes/views/simulado_screen.dart';

class ResultadoSimuladoScreen extends StatelessWidget {
  final double nota;
  final List<bool> questoesCorretas;
  final List<QuestionModel> simuladoQuestions;
  final List<Map<String, dynamic>> answers;
  final String
      tempoUsuario; // Adiciona o parâmetro para o tempo do usuário formatado

  const ResultadoSimuladoScreen({
    super.key,
    required this.nota,
    required this.questoesCorretas,
    required this.simuladoQuestions,
    required this.answers,
    required this.tempoUsuario, // Atualiza o construtor para receber o tempo do usuário
  });

  @override
  Widget build(BuildContext context) {
    int totalQuestoesCorretas = questoesCorretas.where((e) => e).length;
    int totalQuestoesErradas = questoesCorretas.length - totalQuestoesCorretas;
    int totalQuestoes = totalQuestoesCorretas + totalQuestoesErradas;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultado do Simulado'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildResultadoContainer(
                  totalQuestoes, totalQuestoesCorretas, totalQuestoesErradas),
              const SizedBox(height: 10.0),
              _buildDataTable(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        padding: const EdgeInsets.all(5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => _confirmExit(context),
                  icon: const Icon(Icons.exit_to_app),
                ),
                const Text('Sair'),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => _reiniciarSimulado(context),
                  icon: const Icon(Icons.refresh),
                ),
                const Text('Reiniciar'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultadoContainer(
      int totalQuestoes, int totalQuestoesCorretas, int totalQuestoesErradas) {
    return Container(
      padding: const EdgeInsets.all(30.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Nota do aluno: $nota',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(height: 10.0),
              Text(
                'Quantidade de questões: $totalQuestoes',
                style: const TextStyle(
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(height: 5.0),
              Text(
                'Questões corretas: $totalQuestoesCorretas',
                style: const TextStyle(
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(height: 5.0),
              Text(
                'Questões erradas: $totalQuestoesErradas',
                style: const TextStyle(
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(height: 10.0),
              Text(
                'Tempo total: $tempoUsuario',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataTable() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.white,
      ),
      child: DataTable(
        columnSpacing: 45,
        headingRowHeight: 40,
        headingTextStyle: const TextStyle(color: Colors.white),
        decoration: BoxDecoration(
          color: const Color(0xFF4F378A),
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        columns: const [
          DataColumn(label: Text('Questão')),
          DataColumn(label: Text('Resposta')),
          DataColumn(label: Text('Correta')),
        ],
        rows: _buildTableRows(),
      ),
    );
  }

  List<DataRow> _buildTableRows() {
    List<DataRow> rows = [];
    for (int i = 0; i < answers.length; i++) {
      var questionIndex = answers[i]['questionIndex'];
      var alternativeIndex = answers[i]['alternativeIndex'];
      var correctAlternativeIndex =
          simuladoQuestions[questionIndex].alternativas.indexWhere(
                (alternative) => alternative['isCorrect'] == true,
              );

      var color = questoesCorretas[i] ? Colors.green[100] : Colors.red[100];

      rows.add(
        DataRow(
          color: MaterialStateProperty.all(color),
          cells: [
            DataCell(
              Center(
                child: Text('${questionIndex + 1}'),
              ),
            ),
            DataCell(
              Center(
                child: Text(String.fromCharCode(alternativeIndex + 65)),
              ),
            ),
            DataCell(
              Center(
                child: Text(String.fromCharCode(correctAlternativeIndex + 65)),
              ),
            ),
          ],
        ),
      );
    }
    return rows;
  }

  void _confirmExit(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _reiniciarSimulado(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => SimuladoScreen(
          questions: simuladoQuestions,
          numberOfQuestions: simuladoQuestions.length,
          timeInMinutes: 10,
        ),
      ),
    );
  }
}
