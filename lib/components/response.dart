import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/vs2015.dart';
import 'package:text_rest_client/models/models.dart';
import 'package:text_rest_client/utils.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flushbar/flushbar.dart';
import 'package:recase/recase.dart';

class ResponseItem extends StatelessWidget {
  final HttpResponse response;
  ResponseItem({
    Key key,
    @required this.response,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return response.response.toOption().cata(
        () => Container(
              height: 250,
              decoration: BoxDecoration(
                  border: Border(
                      bottom:
                          BorderSide(color: theme.dividerColor, width: 2.0))),
              padding: EdgeInsets.all(8),
              child: Center(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                          text: 'Could not get any response\n',
                          style: theme.textTheme.body1),
                      TextSpan(
                          text: (response.response
                                  as Left<String, Response<dynamic>>)
                              .value,
                          style: theme.textTheme.body1
                              .copyWith(color: theme.errorColor)),
                    ],
                  ),
                ),
              ),
            ), (res) {
      final body = JsonEncoder.withIndent('  ')
          .convert(json.decode(res.data.toString()));
      final width = Util.isPhone(size.width) ? size.width : size.width / 2;
      final richTextWidget =
          Text.rich(TextSpan(text: body)).build(context) as RichText;
      final renderObject = richTextWidget.createRenderObject(context);
      renderObject.layout(BoxConstraints(minWidth: 0, maxWidth: width / 3));

      final responseSize = renderObject.size;

      return Container(
          width: width,
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: theme.dividerColor, width: 2.0))),
          padding: EdgeInsets.all(8),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
                child: Text("URL", style: theme.textTheme.body2),
                padding: EdgeInsets.only(bottom: 8)),
            Padding(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: methodView(context,
                                HttpMethod.fromString(res.request.method))),
                        Text(res.request.uri.toString(),
                            style: theme.textTheme.body1),
                      ]),
                      responseTimeView(
                          context,
                          DateTime.now().millisecondsSinceEpoch -
                              res.request.extra['request_time']),
                    ]),
                padding: EdgeInsets.only(bottom: 8)),
            Padding(
                child: Text("Status", style: theme.textTheme.body2),
                padding: EdgeInsets.only(bottom: 8)),
            Padding(
                child: statusView(context, res.statusCode),
                padding: EdgeInsets.only(bottom: 8)),
            Padding(
                child: Text("Content-Type", style: theme.textTheme.body2),
                padding: EdgeInsets.only(bottom: 8)),
            Padding(
                child: Text(
                    catching(() => res.headers.value("Content-Type"))
                        .toOption()
                        .cata(() => "none", (contentType) => contentType),
                    style: theme.textTheme.body1),
                padding: EdgeInsets.only(bottom: 8)),
            Padding(
                child: Text("Content-Length", style: theme.textTheme.body2),
                padding: EdgeInsets.only(bottom: 8)),
            Padding(
                child: Text(
                    catching(() => res.headers.value("Content-Length"))
                        .toOption()
                        .cata(
                            () => "none",
                            (contentType) =>
                                contentType == null ? "none" : contentType),
                    style: theme.textTheme.body1),
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
                  Container(
                      height: max(250, responseSize.height),
                      child: TabBarView(children: [
                        Stack(children: [
                          HighlightView(
                            body,
                            language: catching(() =>
                                    res.headers.value('Content-Type') ==
                                            'application/json'
                                        ? 'json'
                                        : res.headers.value("Content-Type") ==
                                                'text/html'
                                            ? 'html'
                                            : 'json')
                                .toOption()
                                .cata(() => 'html', (type) => type),
                            theme: vs2015Theme,
                            padding: EdgeInsets.all(8),
                          ),
                          Positioned(
                            top: 0.0,
                            right: 0.0,
                            child: IconButton(
                              iconSize: 20,
                              icon: Icon(Icons.content_copy),
                              onPressed: () async {
                                await Clip().setData(res.data.toString());
                                Flushbar(
                                  message: "Copied to clipboard",
                                  duration: Duration(seconds: 3),
                                )..show(context);
                              },
                            ),
                          ),
                        ]),
                        HighlightView(
                          JsonEncoder.withIndent('  ')
                              .convert(res.headers.map.map((key, value) {
                            ReCase rc = ReCase(key);
                            return MapEntry(rc.headerCase,
                                value.length == 1 ? value.first : value);
                          })),
                          language: 'json',
                          theme: vs2015Theme,
                          padding: EdgeInsets.all(8),
                        )
                      ]))
                ])),
          ]));
    });
  }

  Widget responseTimeView(BuildContext context, int responseTime) {
    final text =
        responseTime > 1000 ? "${responseTime / 1000}s" : "${responseTime}ms";
    return Text(text, style: Theme.of(context).textTheme.body2);
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

  Widget statusView(BuildContext context, int statusCode) {
    if (statusCode >= 200 && statusCode < 400) {
      return Text(statusCode.toString(),
          style:
              Theme.of(context).textTheme.body1.copyWith(color: Colors.green));
    } else if (statusCode >= 400 && statusCode < 500) {
      return Text(statusCode.toString(),
          style:
              Theme.of(context).textTheme.body1.copyWith(color: Colors.yellow));
    } else {
      return Text(statusCode.toString(),
          style: Theme.of(context).textTheme.body1.copyWith(color: Colors.red));
    }
  }
}
