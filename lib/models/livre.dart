import 'package:cloud_firestore/cloud_firestore.dart';

class Livre {
  final String id;
  final String titre;
  final String isbn;
  final DateTime? dateSortie;
  final String? photo;
  final String ecrivainId;

  Livre({
    required this.id,
    required this.titre,
    required this.isbn,
    this.dateSortie,
    this.photo,
    required this.ecrivainId,
  });

  // Créer un Livre depuis un document Firestore
  factory Livre.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Livre(
      id: doc.id,
      titre: data['titre'] ?? '',
      isbn: data['isbn'] ?? '',
      dateSortie: data['dateSortie'] != null
          ? (data['dateSortie'] as Timestamp).toDate()
          : null,
      photo: data['photo'],
      ecrivainId: data['ecrivainId'] ?? '',
    );
  }

  // Convertir en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'titre': titre,
      'isbn': isbn,
      'dateSortie': dateSortie != null ? Timestamp.fromDate(dateSortie!) : null,
      'photo': photo,
      'ecrivainId': ecrivainId,
    };
  }

  @override
  String toString() => 'Livre(id: $id, titre: $titre, isbn: $isbn)';
}
