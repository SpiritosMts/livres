import 'package:flutter/material.dart';
import '../models/ecrivain.dart';
import '../services/ecrivain_service.dart';

class EcrivainFormScreen extends StatefulWidget {
  final Ecrivain? ecrivain;

  const EcrivainFormScreen({super.key, this.ecrivain});

  @override
  State<EcrivainFormScreen> createState() => _EcrivainFormScreenState();
}

class _EcrivainFormScreenState extends State<EcrivainFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final EcrivainService _ecrivainService = EcrivainService();
  
  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _telController;
  
  bool _isLoading = false;

  bool get isEditing => widget.ecrivain != null;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.ecrivain?.nom ?? '');
    _prenomController = TextEditingController(text: widget.ecrivain?.prenom ?? '');
    _telController = TextEditingController(text: widget.ecrivain?.tel ?? '');
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _telController.dispose();
    super.dispose();
  }

  Future<void> _saveEcrivain() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final ecrivain = Ecrivain(
        id: widget.ecrivain?.id ?? '',
        nom: _nomController.text.trim(),
        prenom: _prenomController.text.trim(),
        tel: _telController.text.trim(),
      );

      if (isEditing) {
        await _ecrivainService.updateEcrivain(ecrivain);
      } else {
        await _ecrivainService.addEcrivain(ecrivain);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing
                ? 'Écrivain modifié avec succès'
                : 'Écrivain ajouté avec succès'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier l\'écrivain' : 'Nouvel écrivain'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Prénom
              TextFormField(
                controller: _prenomController,
                decoration: InputDecoration(
                  labelText: 'Prénom',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le prénom est requis';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),

              // Nom
              TextFormField(
                controller: _nomController,
                decoration: InputDecoration(
                  labelText: 'Nom',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le nom est requis';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),

              // Téléphone
              TextFormField(
                controller: _telController,
                decoration: InputDecoration(
                  labelText: 'Téléphone',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le téléphone est requis';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Bouton de sauvegarde
              ElevatedButton(
                onPressed: _isLoading ? null : _saveEcrivain,
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
