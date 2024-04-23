class QuestionModel {
  final List<Map<String, dynamic>> alternativas;
  final String enunciado;
  final String id;

  QuestionModel({
    required this.alternativas,
    required this.enunciado,
    required this.id,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      alternativas: json['alternativas'] != null
          ? List<Map<String, dynamic>>.from(json['alternativas'].map(
              (alternative) => {
                'text': alternative['opcao'] ?? '',
                'isCorrect': alternative['opcaoCorreta'] ?? false,
              },
            ))
          : [],
      enunciado: json['enunciado'] ?? '',
      id: json['id'] ?? '', // Adicionando o ID como parte dos dados da questão
    );
  }
}