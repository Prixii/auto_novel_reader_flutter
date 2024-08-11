import 'package:auto_novel_reader_flutter/bloc/epub_viewer/epub_viewer_bloc.dart';
import 'package:auto_novel_reader_flutter/ui/view/reader/epub_reader.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:auto_novel_reader_flutter/ui/view/splash.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => globalBloc),
        BlocProvider(create: (context) => EpubViewerBloc()),
      ],
      child: const MaterialApp(
        home: SplashView(),
        // home: Tester(),
      ),
    );
  }
}

class Tester extends StatefulWidget {
  const Tester({super.key});

  @override
  State<Tester> createState() => _TesterState();
}

class _TesterState extends State<Tester> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: ElevatedButton(
              onPressed: () async {
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['epub'],
                );
                if (result == null) return;
                final path = result.files.single.path;
                if (path == null) return;
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const EpubReaderView(),
                ));
              },
              child: const Text('open epub'))),
    );
  }
}
