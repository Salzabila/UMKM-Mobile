import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class FotoService {
  static final FotoService _instance = FotoService._internal();
  factory FotoService() => _instance;
  FotoService._internal();

  // Pick an image from the gallery
  Future<File?> pilihDariGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  // Capture an image from the camera
  Future<File?> ambilDariKamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  // Save photo locally (temporary until backend is ready)
  // TODO: Replace with API upload to Laravel backend
  Future<String?> uploadFoto(File fotoFile, String barangId) async {
    try {
      // Get application documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final fotosDir = Directory('${appDir.path}/fotos');
      
      // Create directory if it doesn't exist
      if (!await fotosDir.exists()) {
        await fotosDir.create(recursive: true);
      }
      
      // Create unique filename
      final fileName = '${barangId}-${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedPath = path.join(fotosDir.path, fileName);
      
      // Copy file to app directory
      await fotoFile.copy(savedPath);
      
      return savedPath;
      
      // TODO: Implement API upload to Laravel backend
      // Example:
      // final request = http.MultipartRequest('POST', Uri.parse('${API_URL}/upload-foto'));
      // request.files.add(await http.MultipartFile.fromPath('foto', fotoFile.path));
      // final response = await request.send();
      // return response data (URL from server)
    } catch (e) {
      throw Exception('Gagal menyimpan foto: $e');
    }
  }

  // Delete a photo from local storage
  // TODO: Replace with API delete from Laravel backend
  Future<void> hapusFoto(String fotoPath) async {
    try {
      final file = File(fotoPath);
      if (await file.exists()) {
        await file.delete();
      }
      
      // TODO: Implement API delete from Laravel backend
      // Example:
      // await http.delete(Uri.parse('${API_URL}/delete-foto'), body: {'path': fotoPath});
    } catch (e) {
      throw Exception('Gagal menghapus foto: $e');
    }
  }
}
