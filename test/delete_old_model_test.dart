import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

void main() {
  test('Delete old ML model', () async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'jobtracker_ml_model.json'));
    
    print('Looking for file at: \${file.path}');
    
    if (file.existsSync()) {
      file.deleteSync();
      print('File deleted successfully!');
    } else {
      print('File does not exist.');
    }
  });
}
