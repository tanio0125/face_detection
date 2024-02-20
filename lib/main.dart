import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const FaceDetectionScreen(),
    );
  }
}

class FaceDetectionScreen extends StatefulWidget {
  const FaceDetectionScreen({super.key});

  @override
  FaceDetectionScreenState createState() => FaceDetectionScreenState();
}

class FaceDetectionScreenState extends State<FaceDetectionScreen> {
  File? _image;
  int? _imageWidth;
  int? _imageHeight;
  ui.Image? _uiImage;
  List<Face> _faces = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final image = File(pickedFile.path);
      final faces = await detectFaces(image);
      _uiImage = await decodeImageFromList(await image.readAsBytes());
      setState(() {
        _imageWidth = _uiImage?.height;
        _imageHeight = _uiImage?.width;
        _image = image;
        _faces = faces;
      });
    }
  }

  Future<List<Face>> detectFaces(File image) async {
    final inputImage = InputImage.fromFile(image);
    final faceDetector = GoogleMlKit.vision.faceDetector();
    final List<Face> faces = await faceDetector.processImage(inputImage);
    faceDetector.close();
    return faces;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Detection App'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _image == null
              ? const Center(child: Text('No image selected.'))
              : SizedBox(
                  width: 300,
                  child: FittedBox(
                    child: SizedBox(
                      width: _imageWidth?.toDouble(),
                      height: _imageHeight?.toDouble(),
                      child: CustomPaint(
                        painter: FacePainter(_uiImage, _faces),
                      ),
                    ),
                  ),
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        tooltip: 'Pick Image',
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
}

class FacePainter extends CustomPainter {
  final ui.Image? image;
  final List<Face> faces;

  FacePainter(this.image, this.faces);

  @override
  void paint(Canvas canvas, Size size) {
    if (image == null) return;
    // Draw the image
    var paint = Paint();

    canvas.drawImage(image!, Offset.zero, paint);

    // Draw black rectangles over the faces
    for (var face in faces) {
      final rect = face.boundingBox;
      canvas.drawRect(rect, Paint()..color = Colors.blue);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
