import 'dart:io';
import 'package:flutter/material.dart';
import '../models/irritant.dart';
import '../models/app_user.dart';
import '../services/irritant_service.dart';
import '../services/photo_service.dart';
import '../services/auth_service.dart';

class AddIrritantScreen extends StatefulWidget {
  final AppUser currentUser;

  const AddIrritantScreen({super.key, required this.currentUser});

  @override
  State<AddIrritantScreen> createState() => _AddIrritantScreenState();
}

class _AddIrritantScreenState extends State<AddIrritantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _irritantService = IrritantService();
  final _photoService = PhotoService();

  final _titreController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _anonyme = false;
  String? _lieu;
  String? _type;
  double _priorite = 5; // Valeur entre 0 et 10
  List<File> _photos = [];
  bool _chargement = false;

  final List<String> _lieux = [
    'Petite salle de réunion', 'Grande salle de réunion', 'Zone A', 'Zone B', 'Zone C',
    'Toilettes', 'Couloir', 'Entrée', 'Autre',
  ];
  final List<String> _types = [
    'Équipement', 'Climatisation', 'Bruit', 'Éclairage', 'Propreté', 'Autre',
  ];

  void _afficherChoixPhoto() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Prendre une photo'),
              onTap: () async {
                Navigator.pop(context);
                final photo = await _photoService.prendrePhoto();
                if (photo != null) setState(() => _photos.add(photo));
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choisir une photo'),
              onTap: () async {
                Navigator.pop(context);
                final photo = await _photoService.choisirDansGalerie();
                if (photo != null) setState(() => _photos.add(photo));
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choisir plusieurs photos'),
              onTap: () async {
                Navigator.pop(context);
                final photos = await _photoService.choisirPlusieursPhotos();
                setState(() => _photos.addAll(photos));
              },
            ),
          ],
        ),
      ),
    );
  }

  void _reinitialiser() {
    _formKey.currentState!.reset();
    setState(() {
      _anonyme = false;
      _lieu = null;
      _type = null;
      _priorite = 5; // Remet la valeur par défaut
      _photos = [];
    });
    _titreController.clear();
    _descriptionController.clear();
  }

  Future<void> _soumettre() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _chargement = true);

    final irritant = Irritant(
      nom: _anonyme ? 'Anonyme' : widget.currentUser.nom,
      nomReel: widget.currentUser.nom,
      uidAuteur: widget.currentUser.uid,
      titre: _titreController.text.trim(),
      lieu: _lieu!,
      type: _type!,
      description: _descriptionController.text.trim(),
      priorite: _priorite.round().toString(), // Convertit le double en String
    );

    await _irritantService.ajouterIrritant(irritant, photos: _photos);

    setState(() => _chargement = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Irritant signalé avec succès !')),
      );
      _reinitialiser();
    }
  }

  @override
  void dispose() {
    _titreController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IrritantsTracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().deconnecter();
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [

            // Nom (prérempli, non modifiable) + case anonyme
            Row(
              children: [
                Icon(
                  _anonyme ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                      color: Colors.grey.shade100,
                    ),
                    child: Text(
                      _anonyme ? 'Anonyme' : widget.currentUser.nom,
                      style: TextStyle(
                        color: _anonyme ? Colors.grey : Colors.black87,
                      ),
                    ),
                  ),
                ),
                Checkbox(
                  value: _anonyme,
                  onChanged: (val) => setState(() => _anonyme = val!),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Titre
            Row(
              children: [
                const Icon(Icons.label_outline, color: Colors.grey),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _titreController,
                    decoration: const InputDecoration(
                      hintText: 'Titre',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Titre requis' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Lieu
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.grey),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _lieu,
                    hint: const Text('Lieu'),
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: _lieux
                        .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                        .toList(),
                    onChanged: (val) => setState(() => _lieu = val),
                    validator: (value) =>
                        value == null ? 'Sélectionnez un lieu' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Type d'anomalie
            Row(
              children: [
                const Icon(Icons.menu, color: Colors.grey),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _type,
                    hint: const Text("Type d'anomalie"),
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: _types
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (val) => setState(() => _type = val),
                    validator: (value) =>
                        value == null ? 'Sélectionnez un type' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Description
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Icon(Icons.chat_bubble_outline, color: Colors.grey),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Description requise'
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Priorité (slider de 0 à 10)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.flag_outlined, color: Colors.grey),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Faible', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          Text(
                            _priorite.round().toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Text('Important', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                      Slider(
                        value: _priorite,
                        min: 0,
                        max: 10,
                        divisions: 10,
                        onChanged: (val) => setState(() => _priorite = val),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Bouton ajouter photo
            Row(
              children: [
                const Icon(Icons.image_outlined, color: Colors.grey),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _afficherChoixPhoto,
                    icon: const Icon(Icons.add_a_photo),
                    label: Text(_photos.isEmpty
                        ? 'Ajouter des photos'
                        : 'Ajouter une photo (${_photos.length} sélectionnée(s))'),
                  ),
                ),
              ],
            ),

            // Grille d'aperçu des photos
            if (_photos.isNotEmpty) ...[
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _photos.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _photos[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => setState(() => _photos.removeAt(index)),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],

            const SizedBox(height: 24),

            // Boutons Reset et Submit
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _reinitialiser,
                  icon: const Icon(Icons.delete_outline, color: Colors.grey),
                ),
                ElevatedButton(
                  onPressed: _chargement ? null : _soumettre,
                  child: _chargement
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Submit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}