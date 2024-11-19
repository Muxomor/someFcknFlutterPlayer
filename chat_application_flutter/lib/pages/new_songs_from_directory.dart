import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as p;
import 'package:audiotags/audiotags.dart';
import 'package:chat_application_flutter/components/Song.dart';
import 'package:chat_application_flutter/pages/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:toast/toast.dart';

class PathSelectionPage extends StatefulWidget {
  const PathSelectionPage({super.key});

  @override
  State<PathSelectionPage> createState() => _PathSelectionPageState();
}

class _PathSelectionPageState extends State<PathSelectionPage> {
  String _selectedFile = '';
  String filePath = '';

  void _onFileSelected(String result) {
    setState(() {
      _selectedFile = result;
      filePath = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ignore: deprecated_member_use
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        actions: [
          IconButton(onPressed: (){Navigator.of(context).push(MaterialPageRoute(builder: (context)=>PathSelectionPage(),),);}, icon: Icon(Icons.folder))
        ],
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text('Загрузка файла'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              height: MediaQuery.of(context).size.height * 0.15,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  final result = await FilePicker.platform.getDirectoryPath(
                      dialogTitle: "Выберите директорию альбома",
                      initialDirectory: _selectedFile,
                  );

                  if (result != null) {
                    _onFileSelected(result);
                  } else {
                    Toast.show('Файл не выбран');
                  }
                },
                child: Icon(Icons.upload),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Text(
                _selectedFile.isEmpty ? 'Выберите файл' : _selectedFile,
                style: TextStyle(fontSize: 24),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_selectedFile.isEmpty) {
            Toast.show('Для продолжения выберите файл!');
          } else {
            try {
              var dir = Directory(_selectedFile);
              var dirList = dir.list();
              List<String> songsPathList = new List.empty();
              List<String> songsLogoPathList = new List.empty();
              await for (final FileSystemEntity currentFile in dirList){
                if(currentFile is File){
                  if(p.extension(currentFile.path)=='.mp3'||p.extension(currentFile.path)=='.flac'|| p.extension(_selectedFile)=='.wav'|| p.extension(_selectedFile)=='.ogg'|| p.extension(_selectedFile)=='aac'){
                    songsPathList.add(currentFile.path);
                  }
                  else if(p.extension(currentFile.path)=='.jpg'|| p.extension(_selectedFile)=='.png'){
                    songsLogoPathList.add(currentFile.path);
                  }
                }
              }
              bool hasImage = await hasImageInFile(filePath);
              Tag? tag = await AudioTags.read(filePath);
              if (!hasImage) {
                Toast.show(
                    'Изображение в файле отсутствует! Выберите свое изобраение на следующей странице!',
                    duration: 5);
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ImagePickerForm(
                          filePath: filePath,
                          tags: tag,
                        )));
              } else {
                if (tag != null && tag.pictures.isNotEmpty) {
                  File file = await convertUint8ListToFile(
                      tag.pictures.first.bytes, _selectedFile);

                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ImagePickerForm(
                      filePath: filePath,
                      tags: tag,
                      imageFileFromMetadata: file,
                    ),
                  ));
                } else {
                  Toast.show('Ошибка при чтении метаданных');
                }
              }
            } catch (e) {
              Toast.show('Ошибка: $e');
            }
          }
        },
        tooltip: 'Вперёд',
        child: Icon(Icons.arrow_forward),
      ),
    );
  }
}

Future<bool> hasImageInFile(String filePath) async {
  try {
    // Читаем метаданные аудиофайла
    Tag? tag = await AudioTags.read(filePath);

    // Проверяем, есть ли изображения в метаданных
    if (tag != null && tag.pictures.isNotEmpty) {
      return true; // Изображение присутствует
    } else {
      return false; // Изображение отсутствует
    }
  } catch (e) {
    Toast.show('Ошибка при чтении изображения из метаданных: $e');
    //при ошибке считаем что изображения нет
    return false;
  }
}

Future<File> convertUint8ListToFile(Uint8List? data, String? fileName) async {
  await requestStoragePermission();

  try {
    final tempDirectory = await getTemporaryDirectory();
    final tempPath = '${tempDirectory.path}/photoFor$fileName';
    final file = File(tempPath);
    await file.writeAsBytes(data!);

    return file;
  } catch (e) {
    Toast.show('Ошибка при загрузке файла из метаданных: $e');

    rethrow;
  }
}

Future<void> requestStoragePermission() async {
  PermissionStatus status = await Permission.storage.request();

  if (status.isGranted) {
    Toast.show('Разрешение предоставлено!');
  } else if (status.isDenied) {
    Toast.show('Разрешение не предоставлено! Необходимо разрешение для работы');
  } else if (status.isPermanentlyDenied) {
    Toast.show(
        'Разрешение заблокировано! Перейдите в настройки, чтобы предоставить его');
    openAppSettings();
  }
}

class ImagePickerForm extends StatefulWidget {
  final String filePath;
  final Tag? tags;
  final File? imageFileFromMetadata;
  const ImagePickerForm(
      {super.key,
      required this.filePath,
      this.tags,
      this.imageFileFromMetadata});

  @override
  _ImagePickerFormState createState() => _ImagePickerFormState();
}

class _ImagePickerFormState extends State<ImagePickerForm> {
  File? _selectedImage;
  final _songNameController = TextEditingController();
  final _songAuthorController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _songNameController.text = widget.tags?.title ?? '';
    _songAuthorController.text = widget.tags?.trackArtist ?? '';
    _selectedImage = widget.imageFileFromMetadata ?? _selectedImage;
  }

  Future<String> pushFileToStorage(XFile file) async {
    try {
      final path = 'songsData/${file.name}';
      Reference storageRef = FirebaseStorage.instance.ref().child(path);
      UploadTask task = storageRef.putFile(File(file.path));
      //some bullshit happens here
      TaskSnapshot taskSnapshot = await task.whenComplete(() => null);
      String url = await taskSnapshot.ref.getDownloadURL();
      return url;
    } catch (e) {
      Toast.show(
          'Произошла ошибка при загрузке файлов! Проверьте подключение к интернету и/или попробуйте позже! $e');
      return 'error';
    }
  }

  Future<bool> pushSongToFirestore(Song song) async {
    try {
      await FirebaseFirestore.instance.collection('Songs').add({
        'Author': song.author,
        'File': song.file,
        'Logo': song.logo,
        'Name': song.name,
      });

      Toast.show('Успех! Трек загружен');
      return true;
    } catch (e) {
      Toast.show('Произошла ошибка при загрузке! $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Информация о треке'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8.0),
                  image: _selectedImage != null
                      ? DecorationImage(
                          image: FileImage(_selectedImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _selectedImage == null
                    ? Center(
                        child: Icon(
                          Icons.image,
                          size: 50,
                          color: Colors.grey[700],
                        ),
                      )
                    : null,
              ),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _songNameController,
              decoration: InputDecoration(
                labelText: 'Название',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _songAuthorController,
              decoration: InputDecoration(
                labelText: 'Автор',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: FloatingActionButton.extended(
                onPressed: () {
                  Navigator.pop(context);
                },
                label: Text('Назад'),
                icon: Icon(Icons.arrow_back),
                heroTag: 'backButton',
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(width: 16.0),
            Expanded(
              child: FloatingActionButton.extended(
                onPressed: () async {
                  // Логика сохранения
                  if (_songNameController.text.isEmpty &&
                      _songAuthorController.text.isEmpty) {
                    Toast.show('Заполните необходимые текстовые поля!');
                  } else {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        });
                    Song newSong = Song();
                    newSong.author = _songAuthorController.text;
                    newSong.name = _songNameController.text;

                    newSong.file =
                        await pushFileToStorage(XFile(widget.filePath));
                    if (_selectedImage?.path != null) {
                      newSong.logo = await pushFileToStorage(
                          XFile(_selectedImage!.path.toString()));
                    } else {
                      newSong.logo =
                          'https://firebasestorage.googleapis.com/v0/b/some-shitty-chat-app.appspot.com/o/placeholder.png?alt=media&token=8f51613b-9f4f-4630-b571-6ab9834075ec';
                    }
                    if (newSong.file == 'error') {
                      //Toast.show('Произошла ошибка при загрузке файлов');
                    } else {
                      if (await pushSongToFirestore(newSong)) {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => HomePage()),
                            (Route<dynamic> route) => false);
                      }
                    }
                  }
                },
                label: Text('Сохранить'),
                icon: Icon(Icons.save),
                heroTag: 'saveButton',
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
