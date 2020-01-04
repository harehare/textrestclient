import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import 'package:text_rest_client/pages/pages.dart';
import 'package:text_rest_client/theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:text_rest_client/bloc/bloc.dart';

void main() {
  final router = Router();

  router.define('histories', handler: Handler(
    handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      // TODO:
      return Container();
    },
  ), transitionType: TransitionType.material);

  router.define('home', handler:
      Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
    return BlocProvider<RequestBloc>(
        create: (context) {
          return RequestBloc();
        },
        child: MainPage());
    ;
  }), transitionType: TransitionType.material);

  runApp(MyApp(router));
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
      initialRoute: 'home',
    );
  }
}
