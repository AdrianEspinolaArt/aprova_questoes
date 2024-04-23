import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aprova_questoes/models/discipline_model.dart';

class DisciplineController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Discipline>> getDisciplines() async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore.collection('disciplines').get();
    List<Discipline> disciplines = [];
    for (var doc in snapshot.docs) {
      disciplines.add(Discipline(id: doc.id, name: doc['name']));
    }
    return disciplines;
  }
  
}