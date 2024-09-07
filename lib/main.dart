import 'package:animations/animations.dart';
import 'package:auto_novel_reader_flutter/manager/style_manager.dart';
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
    initScreenSize(context);
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => globalBloc),
        BlocProvider(create: (context) => epubViewerBloc),
        BlocProvider(create: (context) => localFileCubit),
        BlocProvider(create: (context) => configCubit),
        BlocProvider(create: (context) => userCubit),
        BlocProvider(create: (context) => webHomeBloc),
        BlocProvider(create: (context) => wenkuHomeBloc),
        BlocProvider(create: (context) => webCacheCubit),
        BlocProvider(create: (context) => downloadCubit),
        BlocProvider(create: (context) => novelRankBloc),
        BlocProvider(create: (context) => favoredCubit),
      ],
      child: MaterialApp(
        theme: styleManager.lightTheme,
        darkTheme: styleManager.darkTheme,
        themeMode: configCubit.state.themeMode,
        home: const SplashView(),
      ),
    );
  }
}
