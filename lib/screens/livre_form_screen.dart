import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:uuid/uuid.dart';
import '../models/livre.dart';
import '../models/ecrivain.dart';
import '../services/livre_service.dart';
import '../services/ecrivain_service.dart';

class LivreFormScreen extends StatefulWidget {
  final Livre? livre;

  const LivreFormScreen({super.key, this.livre});

  @override
  State<LivreFormScreen> createState() => _LivreFormScreenState();
}

class _LivreFormScreenState extends State<LivreFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final LivreService _livreService = LivreService();
  final EcrivainService _ecrivainService = EcrivainService();
  final ImagePicker _imagePicker = ImagePicker();

  late TextEditingController _titreController;
  late TextEditingController _isbnController;
  
  DateTime? _dateSortie;
  String? _photoUrl;
  File? _selectedImage;
  String? _selectedEcrivainId;
  
  bool _isLoading = false;
  bool _isUploading = false;

  bool get isEditing => widget.livre != null;

  @override
  void initState() {
    super.initState();
    _titreController = TextEditingController(text: widget.livre?.titre ?? '');
    _isbnController = TextEditingController(text: widget.livre?.isbn ?? '');
    _dateSortie = widget.livre?.dateSortie;
    _photoUrl = widget.livre?.photo;
    _selectedEcrivainId = widget.livre?.ecrivainId;
  }

  @override
  void dispose() {
    _titreController.dispose();
    _isbnController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return _photoUrl;

    setState(() => _isUploading = true);

    try {
      final String fileName = '${const Uuid().v4()}.jpg';
      final Reference storageRef =
          FirebaseStorage.instance.ref().child('livres/$fileName');

      await storageRef.putFile(_selectedImage!);
      final String downloadUrl = await storageRef.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur upload image: $e')),
        );
      }
      return _photoUrl;
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateSortie ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _dateSortie = picked);
    }
  }

  Future<void> _saveLivre() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedEcrivainId == null || _selectedEcrivainId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un écrivain')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Upload image si nécessaire
      final String? imageUrl = await _uploadImage();

      final livre = Livre(
        id: widget.livre?.id ?? '',
        titre: _titreController.text.trim(),
        isbn: _isbnController.text.trim(),
        dateSortie: _dateSortie,
        photo: imageUrl,
        ecrivainId: _selectedEcrivainId!,
      );

      if (isEditing) {
        await _livreService.updateLivre(livre);
      } else {
        await _livreService.addLivre(livre);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing
                ? 'Livre modifié avec succès'
                : 'Livre ajouté avec succès'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Sélectionner une date';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier le livre' : 'Nouveau livre'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image du livre
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        )
                      : _photoUrl != null && _photoUrl!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: _photoUrl!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                placeholder: (context, url) =>
                                    const Center(child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate,
                                    size: 48, color: Colors.grey[500]),
                                const SizedBox(height: 8),
                                Text(
                                  'Ajouter une photo',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                ),
              ),
              if (_isUploading)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: LinearProgressIndicator(),
                ),
              const SizedBox(height: 24),

              // Titre
              TextFormField(
                controller: _titreController,
                decoration: InputDecoration(
                  labelText: 'Titre',
                  prefixIcon: const Icon(Icons.book),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le titre est requis';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),

              // ISBN
              TextFormField(
                controller: _isbnController,
                decoration: InputDecoration(
                  labelText: 'ISBN',
                  prefixIcon: const Icon(Icons.numbers),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'L\'ISBN est requis';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Date de sortie
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Date de sortie',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _formatDate(_dateSortie),
                    style: TextStyle(
                      color: _dateSortie != null ? Colors.black : Colors.grey[600],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Sélection de l'écrivain
              StreamBuilder<List<Ecrivain>>(
                stream: _ecrivainService.getEcrivains(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final ecrivains = snapshot.data ?? [];

                  if (ecrivains.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.orange),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.warning, color: Colors.orange),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Aucun écrivain disponible. Veuillez d\'abord ajouter un écrivain.',
                              style: TextStyle(color: Colors.orange),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return DropdownButtonFormField<String>(
                    value: _selectedEcrivainId,
                    decoration: InputDecoration(
                      labelText: 'Écrivain',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: ecrivains.map((ecrivain) {
                      return DropdownMenuItem<String>(
                        value: ecrivain.id,
                        child: Text(ecrivain.nomComplet),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedEcrivainId = value);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez sélectionner un écrivain';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 32),

              // Bouton de sauvegarde
              ElevatedButton(
                onPressed: _isLoading ? null : _saveLivre,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        isEditing ? 'Modifier' : 'Ajouter',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
