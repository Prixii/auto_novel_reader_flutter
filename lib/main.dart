import 'package:auto_novel_reader_flutter/bloc/config/config_cubit.dart';
import 'package:auto_novel_reader_flutter/bloc/epub_viewer/epub_viewer_bloc.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:auto_novel_reader_flutter/ui/view/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHydratedStorage();
  runApp(const MainApp());
}

Future<void> initHydratedStorage() async {
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => globalBloc),
        BlocProvider(create: (context) => EpubViewerBloc()),
        BlocProvider(create: (context) => localFileCubit),
        BlocProvider(create: (context) => ConfigCubit()),
      ],
      child: const MaterialApp(
        home: SplashView(),
      ),
    );
  }
}
