import 'package:flutter/material.dart';
import '../models/filtre_options.dart';

class FiltreBottomSheet extends StatefulWidget {
  final FiltreOptions filtreInitial;
  final List<String> lieux;
  final List<String> types;
  final List<String> statuts;

  const FiltreBottomSheet({
    super.key,
    required this.filtreInitial,
    required this.lieux,
    required this.types,
    required this.statuts,
  });

  @override
  State<FiltreBottomSheet> createState() => _FiltreBottomSheetState();
}

class _FiltreBottomSheetState extends State<FiltreBottomSheet> {
  late FiltreOptions _filtre;

  @override
  void initState() {
    super.initState();
    _filtre = widget.filtreInitial.copyWith();
  }

  List<String> _toggleItem(List<String> liste, String item) {
    final copie = List<String>.from(liste);
    if (copie.contains(item)) {
      copie.remove(item);
    } else {
      copie.add(item);
    }
    return copie;
  }

  Widget _chip(String label, bool selectionne, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(right: 8, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selectionne ? Colors.deepPurple : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selectionne ? Colors.deepPurple : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selectionne ? Colors.white : Colors.black87,
            fontSize: 13,
            fontWeight: selectionne ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _boutonTri(
    String valeurActuelle,
    String champAsc,
    String champDesc,
    VoidCallback onAsc,
    VoidCallback onDesc,
    VoidCallback onClear,
  ) {
    return Row(
      children: [
        // Bouton croissant
        GestureDetector(
          onTap: valeurActuelle == champAsc ? onClear : onAsc,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: valeurActuelle == champAsc
                  ? Colors.deepPurple
                  : Colors.grey.shade100,
              borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(20)),
              border: Border.all(
                color: valeurActuelle == champAsc
                    ? Colors.deepPurple
                    : Colors.grey.shade300,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.arrow_upward,
                    size: 14,
                    color: valeurActuelle == champAsc
                        ? Colors.white
                        : Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Croissant',
                  style: TextStyle(
                    color: valeurActuelle == champAsc
                        ? Colors.white
                        : Colors.black87,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Bouton décroissant
        GestureDetector(
          onTap: valeurActuelle == champDesc ? onClear : onDesc,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: valeurActuelle == champDesc
                  ? Colors.deepPurple
                  : Colors.grey.shade100,
              borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(20)),
              border: Border.all(
                color: valeurActuelle == champDesc
                    ? Colors.deepPurple
                    : Colors.grey.shade300,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.arrow_downward,
                    size: 14,
                    color: valeurActuelle == champDesc
                        ? Colors.white
                        : Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Décroissant',
                  style: TextStyle(
                    color: valeurActuelle == champDesc
                        ? Colors.white
                        : Colors.black87,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [

            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filtres & Tri',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => setState(() => _filtre = _filtre.reset()),
                  child: const Text('Réinitialiser',
                      style: TextStyle(color: Colors.deepPurple)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tri par date
            const Text('Tri par date',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            _boutonTri(
              _filtre.triDate,
              'asc',
              'desc',
              () => setState(() => _filtre = _filtre.copyWith(triDate: 'asc')),
              () => setState(() => _filtre = _filtre.copyWith(triDate: 'desc')),
              () => setState(() => _filtre = _filtre.copyWith(triDate: 'desc')),
            ),
            const SizedBox(height: 16),

            // Tri par priorité
            const Text('Tri par priorité',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            _boutonTri(
              _filtre.triPriorite ?? '',
              'asc',
              'desc',
              () => setState(() => _filtre = _filtre.copyWith(triPriorite: 'asc')),
              () => setState(() => _filtre = _filtre.copyWith(triPriorite: 'desc')),
              () => setState(() => _filtre = _filtre.copyWith(clearPriorite: true)),
            ),
            const SizedBox(height: 16),

            // Filtrer par statut
            const Text('Statut',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            Wrap(
              children: widget.statuts
                  .map((s) => _chip(
                        s,
                        _filtre.statuts.contains(s),
                        () => setState(() => _filtre = _filtre.copyWith(
                            statuts: _toggleItem(_filtre.statuts, s))),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),

            // Filtrer par lieu
            const Text('Lieu',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            Wrap(
              children: widget.lieux
                  .map((l) => _chip(
                        l,
                        _filtre.lieux.contains(l),
                        () => setState(() => _filtre = _filtre.copyWith(
                            lieux: _toggleItem(_filtre.lieux, l))),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),

            // Filtrer par type
            const Text("Type d'anomalie",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            Wrap(
              children: widget.types
                  .map((t) => _chip(
                        t,
                        _filtre.types.contains(t),
                        () => setState(() => _filtre = _filtre.copyWith(
                            types: _toggleItem(_filtre.types, t))),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 24),

            // Bouton appliquer
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, _filtre),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Appliquer',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}