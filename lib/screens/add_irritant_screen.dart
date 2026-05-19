import 'dart:io';
import 'package:flutter/material.dart';
import '../models/irritant.dart';
import '../services/irritant_service.dart';
import '../services/photo_service.dart'; // Import du service photo

class AddIrritantScreen extends StatefulWidget {
  const AddIrritantScreen({super.key});

  @override
  State<AddIrritantScreen> createState() => _AddIrritantScreenState();
}

class _AddIrritantScreenState extends State<AddIrritantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _irritantService = IrritantService();
  final _photoService = PhotoService(); // Service photo dédié

  final _nomController = TextEditingController();
  final _titreController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _anonyme = false;
  String? _lieu;
  String? _type;
  String? _priorite;
  List<File> _photos = []; // Liste de photos au lieu d'une seule
  bool _chargement = false;

  final List<String> _lieux = [
    'Salle de réunion A', 'Salle de réunion B', 'Open space',
    'Cuisine', 'Couloir', 'Accueil', 'Autre',
  ];
  final List<String> _types = [
    'Équipement', 'Climatisation', 'Bruit', 'Éclairage', 'Propreté', 'Autre',
  ];
  final List<String> _priorites = ['Basse', 'Normale', 'Haute'];

  // Affiche le choix caméra / galerie / plusieurs photos
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
      _priorite = null;
      _photos = [];
    });
    _nomController.clear();
    _titreController.clear();
    _descriptionController.clear();
  }

  Future<void> _soumettre() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _chargement = true);

    final irritant = Irritant(
      nom: _anonyme ? 'Anonyme' : _nomController.text.trim(),
      titre: _titreController.text.trim(),
      lieu: _lieu!,
      type: _type!,
      description: _descriptionController.text.trim(),
      priorite: _priorite!,
    );

    // Envoie l'irritant avec toutes les photos
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
    _nomController.dispose();
    _titreController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('IrritantsTracker')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [

            // Nom / Anonyme
            Row(
              children: [
                Icon(_anonyme ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _nomController,
                    enabled: !_anonyme,
                    decoration: const InputDecoration(hintText: 'Nom / Anonyme', border: OutlineInputBorder()),
                    validator: (value) {
                      if (!_anonyme && (value == null || value.isEmpty)) {
                        return 'Entrez un nom ou cochez Anonyme';
                      }
                      return null;
                    },
                  ),
                ),
                Checkbox(value: _anonyme, onChanged: (val) => setState(() => _anonyme = val!)),
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
                    decoration: const InputDecoration(hintText: 'Titre', border: OutlineInputBorder()),
                    validator: (value) => value == null || value.isEmpty ? 'Titre requis' : null,
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
                    items: _lieux.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                    onChanged: (val) => setState(() => _lieu = val),
                    validator: (value) => value == null ? 'Sélectionnez un lieu' : null,
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
                    items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (val) => setState(() => _type = val),
                    validator: (value) => value == null ? 'Sélectionnez un type' : null,
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
                    decoration: const InputDecoration(hintText: 'Description', border: OutlineInputBorder()),
                    validator: (value) => value == null || value.isEmpty ? 'Description requise' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Priorité
            Row(
              children: [
                const Icon(Icons.flag_outlined, color: Colors.grey),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _priorite,
                    hint: const Text('Priorité'),
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: _priorites.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                    onChanged: (val) => setState(() => _priorite = val),
                    validator: (value) => value == null ? 'Sélectionnez une priorité' : null,
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

            // Grille d'aperçu des photos sélectionnées
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
                      // Aperçu de la photo
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _photos[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                      // Bouton supprimer la photo
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
                            child: const Icon(Icons.close, color: Colors.white, size: 18),
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