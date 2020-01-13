import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/vs2015.dart';
import 'package:text_rest_client/models/models.dart';
import 'package:text_rest_client/utils.dart';
import 'package:dartz/dartz.dart';
import 'package:recase/recase.dart';

class RequestItem extends StatelessWidget {
  final Option<HttpRequest> request;
  final bool matchWindow;
  RequestItem({Key key, @required this.request, this.matchWindow = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final height = Util.isPhone(size.width)
        ? (size.height - 165) / 2
        : (size.height - 145) / 2;

    return request.cata(
        () => Container(
            height: height,
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: theme.dividerColor, width: 2.0))),
            padding: EdgeInsets.all(8),
            child: Center(
                child: RichText(
                    text: TextSpan(children: [
              TextSpan(text: 'Empty request\n', style: theme.textTheme.body1),
            ])))),
        (req) => Container(
            width: Util.isPhone(size.width)
                ? size.width
                : size.width / (matchWindow ? 1 : 2),
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: theme.dividerColor, width: 2.0))),
            padding: EdgeInsets.all(8),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: methodView(context, req.method)),
                          Text(req.url, style: theme.textTheme.body1),
                        ]),
                      ]),
                  padding: EdgeInsets.only(bottom: 8)),
              DefaultTabController(
                  length: 2,
                  child: Column(children: [
                    TabBar(
                      indicatorColor: theme.indicatorColor,
                      indicatorWeight: 3.0,
                      tabs: [
                        Padding(
                          child: Text("Body",
                              style:
                                  theme.textTheme.body1.copyWith(fontSize: 12)),
                          padding: const EdgeInsets.all(8),
                        ),
                        Padding(
                          child: Text("Headers",
                              style:
                                  theme.textTheme.body1.copyWith(fontSize: 12)),
                          padding: const EdgeInsets.all(8),
                        )
                      ],
                    ),
                    req.body.cata(() => Container(), (body) {
                      final text = body.containsKey("raw")
                          ? body["raw"]
                          : JsonEncoder.withIndent('  ').convert(body);
                      return Container(
                          height: max(100, Util.height(text)),
                          child: TabBarView(children: [
                            HighlightView(
                              text != '' ? text : 'None',
                              language: 'json',
                              theme: vs2015Theme,
                              padding: EdgeInsets.all(8),
                            ),
                            HighlightView(
                              JsonEncoder.withIndent('  ')
                                  .convert(req.headers.cata(
                                      () => {},
                                      (headers) => headers.map((key, value) {
                                            ReCase rc = ReCase(key);
                                            return MapEntry(
                                                rc.headerCase, value);
                                          }))),
                              language: 'json',
                              theme: vs2015Theme,
                              padding: EdgeInsets.all(8),
                            )
                          ]));
                    })
                  ])),
            ])));
  }

  Widget methodView(BuildContext context, HttpMethod method) {
    final theme = Theme.of(context);
    switch (method.method) {
      case Method.POST:
        return Text(
          'POST',
          style: theme.textTheme.body1.copyWith(
              background: Paint()..color = Colors.yellow, color: Colors.black),
        );
      case Method.PUT:
        return Text(
          'PUT',
          style: theme.textTheme.body1
              .copyWith(background: Paint()..color = Colors.blue),
        );
      case Method.PATCH:
        return Text(
          'PATCH',
          style: theme.textTheme.body1.copyWith(
              background: Paint()..color = Colors.grey, color: Colors.black),
        );
      case Method.DELETE:
        return Text(
          'DELETE',
          style: theme.textTheme.body1
              .copyWith(background: Paint()..color = Colors.red),
        );
      case Method.HEAD:
        return Text(
          'HEAD',
          style: theme.textTheme.body1.copyWith(
              background: Paint()..color = Colors.grey, color: Colors.black),
        );
      case Method.OPTIONS:
        return Text(
          'OPTIONS',
          style: theme.textTheme.body1.copyWith(
              background: Paint()..color = Colors.grey, color: Colors.black),
        );
      case Method.TRACE:
        return Text(
          'TRACE',
          style: theme.textTheme.body1.copyWith(
              background: Paint()..color = Colors.grey, color: Colors.black),
        );
      case Method.CONNECT:
        return Text(
          'CONNECT',
          style: theme.textTheme.body1.copyWith(
              background: Paint()..color = Colors.grey, color: Colors.black),
        );
      default:
        return Text(
          'GET',
          style: theme.textTheme.body1
              .copyWith(background: Paint()..color = Colors.green),
        );
    }
  }
}
