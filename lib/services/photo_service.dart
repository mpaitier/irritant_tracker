import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PhotoService {
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Prend une seule photo avec la caméra
  Future<File?> prendrePhoto() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 40,
    );
    return image != null ? File(image.path) : null;
  }

  // Choisit une seule photo depuis la galerie
  Future<File?> choisirDansGalerie() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 40,
    );
    return image != null ? File(image.path) : null;
  }

  // Choisit plusieurs photos depuis la galerie
  Future<List<File>> choisirPlusieursPhotos() async {
    final List<XFile> images = await _picker.pickMultiImage(
      imageQuality: 40,
    );
    return images.map((img) => File(img.path)).toList();
  }

  // Upload une seule photo dans Firebase Storage et retourne son URL
  Future<String?> uploadPhoto(File photo, {String dossier = 'irritants'}) async {
    try {
      final String fileName = '$dossier/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = _storage.ref().child(fileName);
      await ref.putFile(photo);
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      return null;
    }
  }

  // Upload plusieurs photos et retourne la liste des URLs
  Future<List<String>> uploadPhotos(List<File> photos, {String dossier = 'irritants'}) async {
    final List<String> urls = [];
    for (final photo in photos) {
      final url = await uploadPhoto(photo, dossier: dossier);
      if (url != null) urls.add(url);
    }
    return urls;
  }

  // Supprime une photo de Firebase Storage à partir de son URL
  Future<void> supprimerPhoto(String url) async {
    try {
      await _storage.refFromURL(url).delete();
    } catch (e) {
      // Silencieux si la photo n'existe plus
    }
  }
}