import 'package:text_rest_client/models/models.dart';
import 'package:text_rest_client/bloc/request/request_event.dart';
import 'package:text_rest_client/bloc/request/request_state.dart';
import 'package:text_rest_client/utils.dart';
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:dio_http2_adapter/dio_http2_adapter.dart';
import 'package:flutter/foundation.dart';

class RequestBloc extends Bloc<RequestEvent, RequestState> {
  final blankLine = RegExp(r'^\n', multiLine: true);
  final List<String> mapContentType = [
    "application/json",
    "application/x-www-form-urlencoded"
  ];

  @override
  RequestState get initialState => RequestState.initial();

  @override
  Stream<RequestState> mapEventToState(RequestEvent event) async* {
    if (event is InputEvent) {
      yield RequestState(
        isFetching: false,
        responses: state.responses,
      );
    } else if (event is SendEvent) {
      yield* _mapSendToState(event.text);
    } else if (event is SendCancelEvent) {
      state.token.bind((token) => some(token.cancel("canceled by user")));
      yield RequestState(
          responses: state.responses, isFetching: false, token: none());
    }
  }

  Stream<RequestState> _mapSendToState(String text) async* {
    final dio = Dio()
      ..interceptors.add(LogInterceptor())
      ..interceptors.add(ResponseTimeInterceptors());
    final CancelToken token = CancelToken();
    yield RequestState.fetching(some(text), token);

    final results = Util.parseText(text)
        .map((req) => req.bind((r) {
              if (!kIsWeb && r.protocol.protocol == Protocol.Http2) {
                dio.httpClientAdapter = Http2Adapter(
                  ConnectionManager(
                    idleTimeout: 10000,
                  ),
                );
              }

              final headers = r.headers.getOrElse(() => {});
              final body = r.body.bind((body) {
                if (!headers.containsKey("Content-Type")) {
                  return some(body.containsKey("raw") ? body["raw"] : "");
                }

                return some(headers.containsKey("Content-Type") &&
                        mapContentType.contains(headers["Content-Type"])
                    ? body
                    : headers["Content-Type"] == "multipart/form-data"
                        ? some(FormData.fromMap(body))
                        : some(""));
              }).getOrElse(() => "");

              return catching(() {
                switch (r.method.method) {
                  case Method.GET:
                    return dio.get<String>(r.url,
                        options: Options(headers: headers), cancelToken: token);
                  case Method.POST:
                    return dio.post<String>(r.url,
                        options: Options(headers: headers),
                        data: body,
                        cancelToken: token);
                  case Method.PUT:
                    return dio.put<String>(r.url,
                        options: Options(headers: headers),
                        data: body,
                        cancelToken: token);
                  case Method.PATCH:
                    return dio.patch<String>(r.url,
                        options: Options(headers: headers),
                        data: body,
                        cancelToken: token);
                  case Method.DELETE:
                    return dio.delete<String>(r.url,
                        options: Options(headers: headers), cancelToken: token);
                  case Method.HEAD:
                    return dio.head<String>(r.url,
                        options: Options(headers: headers), cancelToken: token);
                  case Method.OPTIONS:
                    return dio.request(r.url,
                        data: body,
                        options: Options(headers: headers, method: 'OPTIONS'),
                        cancelToken: token);
                  case Method.TRACE:
                    return dio.request(r.url,
                        data: body,
                        options: Options(headers: headers, method: 'TRACE'),
                        cancelToken: token);
                  case Method.CONNECT:
                    return dio.request(r.url,
                        data: body,
                        options: Options(headers: headers, method: 'CONNECT'),
                        cancelToken: token);
                  default:
                    return dio.get<String>(r.url,
                        options: Options(headers: headers), cancelToken: token);
                }
              }).toOption();
            }))
        .map((v) {
      return v.cata(
          () => Future.value(
              HttpResponse(response: Left("Could not get any response"))),
          (vv) => vv
              .then((r) => HttpResponse(response: Right(r)))
              .catchError((e) => HttpResponse(response: Left(e.toString()))));
    }).toList();

    try {
      final response = await Future.wait(results);

      yield RequestState(
        isFetching: false,
        responses: some(response),
      );
    } on Exception catch (_) {
      yield RequestState(
        isFetching: false,
        responses: none(),
      );
    }
  }
}

class ResponseTimeInterceptors extends InterceptorsWrapper {
  @override
  Future onRequest(RequestOptions options) {
    options.extra['request_time'] = DateTime.now().millisecondsSinceEpoch;
    return super.onRequest(options);
  }
}
