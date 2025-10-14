// import 'package:firebase_storage/firebase_storage.dart';

// class FotoService {
//   static final FotoService _instance = FotoService._internal();
//   factory FotoService() => _instance;
//   FotoService._internal();

//   // Pick an image from the gallery
//   Future<File?> pilihDariGallery() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       return File(pickedFile.path);
//     }
//     return null;
//   }

//   // Capture an image from the camera
//   Future<File?> ambilDariKamera() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.camera);
//     if (pickedFile != null) {
//       return File(pickedFile.path);
//     }
//     return null;
//   }

//   // Upload a photo to Firebase Storage
//   Future<String?> uploadFoto(File fotoFile, String barangId) async {
//     try {
//       String fileName = 'photos/$barangId-${DateTime.now().millisecondsSinceEpoch}.jpg';
//       Reference ref = FirebaseStorage.instance.ref(fileName);
//       await ref.putFile(fotoFile);
//       String url = await ref.getDownloadURL();
//       return url;
//     } catch (e) {
//       throw Exception('Gagal mengunggah foto: $e');
//     }
//   }

//   // Delete a photo from Firebase Storage
//   Future<void> hapusFoto(String fotoUrl) async {
//     try {
//       await FirebaseStorage.instance.refFromURL(fotoUrl).delete();
//     } catch (e) {
//       throw Exception('Gagal menghapus foto: $e');
//     }
//   }
// }