import 'package:cloud_firestore/cloud_firestore.dart';

class Ecrivain {
  final String id;
  final String nom;
  final String prenom;
  final String tel;

  Ecrivain({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.tel,
  });

  // Créer un Ecrivain depuis un document Firestore
  factory Ecrivain.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Ecrivain(
      id: doc.id,
      nom: data['nom'] ?? '',
      prenom: data['prenom'] ?? '',
      tel: data['tel'] ?? '',
    );
  }

  // Convertir en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'prenom': prenom,
      'tel': tel,
    };
  }

  // Nom complet de l'écrivain
  String get nomComplet => '$prenom $nom';

  @override
  String toString() => 'Ecrivain(id: $id, nom: $nom, prenom: $prenom, tel: $tel)';
}
