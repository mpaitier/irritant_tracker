import 'package:flutter/material.dart';
import '../models/irritant.dart';
import '../services/irritant_service.dart';

class AddIrritantScreen extends StatefulWidget {
  const AddIrritantScreen({super.key});

  @override
  State<AddIrritantScreen> createState() => _AddIrritantScreenState();
}

class _AddIrritantScreenState extends State<AddIrritantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _irritantService = IrritantService();

  bool _anonyme = false;
  final _nomController = TextEditingController();
  final _titreController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _lieu;
  String? _type;
  String? _priorite;

  final List<String> _lieux = [
    'Salle de réunion A',
    'Salle de réunion B',
    'Open space',
    'Cuisine',
    'Couloir',
    'Accueil',
    'Autre',
  ];

  final List<String> _types = [
    'Équipement',
    'Climatisation',
    'Bruit',
    'Éclairage',
    'Propreté',
    'Autre',
  ];

  final List<String> _priorites = [
    'Basse',
    'Normale',
    'Haute',
  ];

  Future<void> _soumettre() async {
    if (!_formKey.currentState!.validate()) return;

    final irritant = Irritant(
      nom: _anonyme ? 'Anonyme' : _nomController.text.trim(),
      titre: _titreController.text.trim(),
      lieu: _lieu!,
      type: _type!,
      description: _descriptionController.text.trim(),
      priorite: _priorite!,
    );

    await _irritantService.ajouterIrritant(irritant);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Irritant signalé avec succès !')),
      );
      _formKey.currentState!.reset();
      setState(() {
        _anonyme = false;
        _lieu = null;
        _type = null;
        _priorite = null;
      });
      _nomController.clear();
      _titreController.clear();
      _descriptionController.clear();
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
                Icon(
                  _anonyme ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _nomController,
                    enabled: !_anonyme,
                    decoration: const InputDecoration(
                      hintText: 'Nom / Anonyme',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (!_anonyme && (value == null || value.isEmpty)) {
                        return 'Entrez un nom ou cochez Anonyme';
                      }
                      return null;
                    },
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
                    initialValue: _lieu,
                    hint: const Text('Lieu'),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
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
                    initialValue: _type,
                    hint: const Text("Type d'anomalie"),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
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

            // Priorité
            Row(
              children: [
                const Icon(Icons.flag_outlined, color: Colors.grey),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _priorite,
                    hint: const Text('Priorité'),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: _priorites
                        .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                    onChanged: (val) => setState(() => _priorite = val),
                    validator: (value) =>
                        value == null ? 'Sélectionnez une priorité' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Boutons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    _formKey.currentState!.reset();
                    setState(() {
                      _anonyme = false;
                      _lieu = null;
                      _type = null;
                      _priorite = null;
                    });
                    _nomController.clear();
                    _titreController.clear();
                    _descriptionController.clear();
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.grey),
                ),
                ElevatedButton(
                  onPressed: _soumettre,
                  child: const Text('Submit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
