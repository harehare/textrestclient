import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import 'package:text_rest_client/pages/pages.dart';
import 'package:text_rest_client/theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:text_rest_client/bloc/bloc.dart';
import 'package:text_rest_client/repository/repository.dart';
import 'package:easy_alert/easy_alert.dart';

void main() {
  final router = Router();
  //ignore: close_sinks
  final historyBloc =
      HistoryBloc(historyRepository: WebHistoryRepositoryImpl());

  router.define('/histories',
      handler: Handler(
          handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
              MultiBlocProvider(providers: [
                BlocProvider<HistoryBloc>(
                    create: (context) => historyBloc..add(LoadEvent()))
              ], child: HistoryPage())),
      transitionType: TransitionType.material);

  router.define('/',
      handler: Handler(
          handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
              MultiBlocProvider(providers: [
                BlocProvider<RequestBloc>(create: (context) => RequestBloc()),
                BlocProvider<HistoryBloc>(create: (context) => historyBloc)
              ], child: MainPage())),
      transitionType: TransitionType.material);

  runApp(AlertProvider(
    child: MyApp(router),
    config: AlertConfig(ok: "OK", cancel: "Cancel"),
  ));
}

class MyApp extends StatelessWidget {
  MyApp(this.router);
  final Router router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Text Rest Client',
      theme: themeData,
      onGenerateRoute: router.generator,
      initialRoute: '/',
    );
  }
}
