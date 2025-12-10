import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ecrivain.dart';

class EcrivainService {
  final CollectionReference _ecrivainsCollection =
      FirebaseFirestore.instance.collection('ecrivains');

  // Obtenir tous les écrivains (Stream)
  Stream<List<Ecrivain>> getEcrivains() {
    return _ecrivainsCollection
        .orderBy('nom')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Ecrivain.fromFirestore(doc))
            .toList());
  }

  // Obtenir un écrivain par ID
  Future<Ecrivain?> getEcrivainById(String id) async {
    final doc = await _ecrivainsCollection.doc(id).get();
    if (doc.exists) {
      return Ecrivain.fromFirestore(doc);
    }
    return null;
  }

  // Ajouter un écrivain
  Future<String> addEcrivain(Ecrivain ecrivain) async {
    final docRef = await _ecrivainsCollection.add(ecrivain.toMap());
    return docRef.id;
  }

  // Modifier un écrivain
  Future<void> updateEcrivain(Ecrivain ecrivain) async {
    await _ecrivainsCollection.doc(ecrivain.id).update(ecrivain.toMap());
  }

  // Supprimer un écrivain
  Future<void> deleteEcrivain(String id) async {
    await _ecrivainsCollection.doc(id).delete();
  }

  // Rechercher des écrivains par nom, prénom ou téléphone
  Stream<List<Ecrivain>> searchEcrivains(String query) {
    final queryLower = query.toLowerCase();
    return _ecrivainsCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Ecrivain.fromFirestore(doc))
          .where((ecrivain) =>
              ecrivain.nom.toLowerCase().contains(queryLower) ||
              ecrivain.prenom.toLowerCase().contains(queryLower) ||
              ecrivain.tel.contains(query))
          .toList();
    });
  }
}
