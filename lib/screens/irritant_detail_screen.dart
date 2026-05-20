import 'package:flutter/material.dart';
import '../models/irritant.dart';
import '../models/app_user.dart';
import '../models/message.dart';
import '../services/message_service.dart';

class IrritantDetailScreen extends StatefulWidget {
  final Irritant irritant;
  final AppUser currentUser;

  const IrritantDetailScreen({
    super.key,
    required this.irritant,
    required this.currentUser,
  });

  @override
  State<IrritantDetailScreen> createState() => _IrritantDetailScreenState();
}

class _IrritantDetailScreenState extends State<IrritantDetailScreen> {
  final _messageController = TextEditingController();
  final _messageService = MessageService();
  final _scrollController = ScrollController();
  bool _envoi = false;

  Color _couleurStatut(String statut) {
    switch (statut) {
      case 'Ouvert':
        return const Color(0xFF9E9E9E);
      case 'En attente':
        return const Color(0xFF42A5F5);
      case 'En cours':
        return const Color(0xFFFFA726);
      case 'Fini':
        return const Color(0xFF66BB6A);
      case 'Annulé':
        return const Color(0xFFEF5350);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  Color _couleurPriorite(String priorite) {
    final int p = int.tryParse(priorite) ?? 5;
    if (p <= 3) return const Color(0xFF66BB6A);
    if (p <= 6) return const Color(0xFFFFA726);
    return const Color(0xFFEF5350);
  }

  Future<void> _envoyerMessage() async {
    final texte = _messageController.text.trim();
    if (texte.isEmpty) return;

    setState(() => _envoi = true);

    final message = Message(
      texte: texte,
      auteur: widget.currentUser.nom,
      uidAuteur: widget.currentUser.uid,
      role: widget.currentUser.role,
      date: DateTime.now(),
    );

    await _messageService.envoyerMessage(widget.irritant.id!, message);

    _messageController.clear();
    setState(() => _envoi = false);

    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _ligneInfo(IconData icone, String label, String valeur,
      {Color? couleurValeur}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 2),
              Text(
                valeur,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: couleurValeur ?? Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bulleMessage(Message message) {
    final bool estEmploye = message.role == 'employe';

    return Align(
      alignment: estEmploye ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: estEmploye ? Colors.deepPurple : Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(estEmploye ? 16 : 4),
            bottomRight: Radius.circular(estEmploye ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              estEmploye ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!estEmploye)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  message.auteur,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            Text(
              message.texte,
              style: TextStyle(
                color: estEmploye ? Colors.white : Colors.black87,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${message.date.hour.toString().padLeft(2, '0')}:'
              '${message.date.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 10,
                color: estEmploye ? Colors.white70 : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail du ticket'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Titre + badge statut
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.irritant.titre,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _couleurStatut(widget.irritant.statut),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.irritant.statut,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),

                  // Infos principales
                  _ligneInfo(Icons.person_outline, 'Signalé par',
                      widget.irritant.nom),
                  _ligneInfo(
                      Icons.location_on_outlined, 'Lieu', widget.irritant.lieu),
                  _ligneInfo(Icons.menu, 'Type', widget.irritant.type),
                  _ligneInfo(
                    Icons.flag_outlined,
                    'Priorité',
                    '${widget.irritant.priorite}/10',
                    couleurValeur: _couleurPriorite(widget.irritant.priorite),
                  ),
                  _ligneInfo(
                    Icons.calendar_today_outlined,
                    'Date',
                    '${widget.irritant.date.day.toString().padLeft(2, '0')}/'
                    '${widget.irritant.date.month.toString().padLeft(2, '0')}/'
                    '${widget.irritant.date.year} à '
                    '${widget.irritant.date.hour.toString().padLeft(2, '0')}:'
                    '${widget.irritant.date.minute.toString().padLeft(2, '0')}',
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),

                  // Description
                  const Text('Description',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 6),
                  Text(
                    widget.irritant.description,
                    style: const TextStyle(fontSize: 15, height: 1.5),
                  ),

                  // Photos
                  if (widget.irritant.photosUrls.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    Text(
                      'Photos (${widget.irritant.photosUrls.length})',
                      style:
                          const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: widget.irritant.photosUrls.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () =>
                              _ouvrirPhotoPleinEcran(context, index),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              widget.irritant.photosUrls[index],
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: Colors.grey.shade100,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                );
                              },
                              errorBuilder: (_, e, _) => Container(
                                color: Colors.grey.shade100,
                                child: const Icon(
                                    Icons.broken_image_outlined,
                                    color: Colors.grey),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],

                  // Section échange avec le support
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Icon(Icons.support_agent, color: Colors.deepPurple),
                      SizedBox(width: 8),
                      Text(
                        'Échange avec le support',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Messages en temps réel
                  StreamBuilder<List<Message>>(
                    stream:
                        _messageService.getMessages(widget.irritant.id!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }

                      final messages = snapshot.data ?? [];

                      if (messages.isEmpty) {
                        return Center(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              'Aucun message pour l\'instant',
                              style:
                                  TextStyle(color: Colors.grey.shade400),
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: messages
                            .map((msg) => _bulleMessage(msg))
                            .toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // Barre d'envoi de message
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border:
                  Border(top: BorderSide(color: Colors.grey.shade200)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Ajouter une information...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                const SizedBox(width: 8),
                _envoi
                    ? const SizedBox(
                        width: 40,
                        height: 40,
                        child:
                            CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        onPressed: _envoyerMessage,
                        icon: const Icon(Icons.send),
                        color: Colors.deepPurple,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.deepPurple.shade50,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _ouvrirPhotoPleinEcran(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              child:
                  Image.network(widget.irritant.photosUrls[index]),
            ),
          ),
        ),
      ),
    );
  }
}