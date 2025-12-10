import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/livre.dart';

class LivreService {
  final CollectionReference _livresCollection =
      FirebaseFirestore.instance.collection('livres');

  // Obtenir tous les livres (Stream)
  Stream<List<Livre>> getLivres() {
    return _livresCollection
        .orderBy('titre')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Livre.fromFirestore(doc))
            .toList());
  }

  // Obtenir un livre par ID
  Future<Livre?> getLivreById(String id) async {
    final doc = await _livresCollection.doc(id).get();
    if (doc.exists) {
      return Livre.fromFirestore(doc);
    }
    return null;
  }

  // Obtenir les livres d'un écrivain
  Stream<List<Livre>> getLivresByEcrivain(String ecrivainId) {
    return _livresCollection
        .where('ecrivainId', isEqualTo: ecrivainId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Livre.fromFirestore(doc))
            .toList());
  }

  // Ajouter un livre
  Future<String> addLivre(Livre livre) async {
    final docRef = await _livresCollection.add(livre.toMap());
    return docRef.id;
  }

  // Modifier un livre
  Future<void> updateLivre(Livre livre) async {
    await _livresCollection.doc(livre.id).update(livre.toMap());
  }

  // Supprimer un livre
  Future<void> deleteLivre(String id) async {
    await _livresCollection.doc(id).delete();
  }
}
