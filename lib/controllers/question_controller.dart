import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aprova_questoes/models/question_model.dart';

class QuestionController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<QuestionModel> getQuestionById(String questionId) async {
    try {
      DocumentSnapshot questionSnapshot = await _firestore.collection('questions').doc(questionId).get();
      
      if (!questionSnapshot.exists) {
        throw Exception('Question not found');
      }

      Map<String, dynamic> questionData = questionSnapshot.data() as Map<String, dynamic>;
      
      // Mapeando os dados das alternativas
      List<Map<String, dynamic>> parsedAlternativas = [];
      if (questionData['alternativas'] != null) {
        for (var alternativeKey in questionData['alternativas'].keys) {
          var alternative = questionData['alternativas'][alternativeKey];
          parsedAlternativas.add({
            'opcao': alternative['opcao'] ?? '',
            'isCorrect': alternative['opcaoCorreta'] ?? false,
          });
        }
      }

      return QuestionModel(
        alternativas: parsedAlternativas,
        enunciado: questionData['enunciado'] ?? '',
        id: questionSnapshot.id,
      );
    } catch (e) {
      rethrow; // Rethrow para propagar o erro para quem chama este método
    }
  }

  Future<List<QuestionModel>> getQuestionsForDiscipline(String disciplineId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('disciplines').doc(disciplineId).collection('questions').get();
      List<QuestionModel> questions = [];
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>; // Convertendo para Map<String, dynamic>
        questions.add(QuestionModel.fromJson({
          ...data,
          'id': doc.id, // Adicionando o ID do documento como parte dos dados da questão
        }));
      }
      return questions;
    } catch (e) {
      return [];
    }
  }

  Future<List<QuestionModel>> getRandomQuestionsForDiscipline(String disciplineId, int numberOfQuestions) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('disciplines').doc(disciplineId).collection('questions').get();
      List<QuestionModel> allQuestions = [];
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>; 
        allQuestions.add(QuestionModel.fromJson({
          ...data,
          'id': doc.id, 
        }));
      }
      // Selecionar aleatoriamente as questões
      allQuestions.shuffle();
      return allQuestions.sublist(0, min(numberOfQuestions, allQuestions.length));
    } catch (e) {
      return [];
    }
  }

  Future<List<QuestionModel>> getRandomQuestionsFromAllDisciplines(List<String> disciplineIds, int numberOfQuestionsPerDiscipline) async {
    try {
      List<QuestionModel> allRandomQuestions = [];
      for (var disciplineId in disciplineIds) {
        List<QuestionModel> randomQuestions = await getRandomQuestionsForDiscipline(disciplineId, numberOfQuestionsPerDiscipline);
        allRandomQuestions.addAll(randomQuestions);
      }
      return allRandomQuestions;
    } catch (e) {
      return [];
    }
  }
}
