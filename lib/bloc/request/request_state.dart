import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:text_rest_client/models/models.dart';

class RequestState {
  final Option<List<ReplResponse>> responses;
  final bool isFetching;
  final Option<CancelToken> token;

  RequestState({this.responses, this.isFetching, this.token});

  factory RequestState.initial() {
    return RequestState(responses: none(), isFetching: false, token: none());
  }

  factory RequestState.fetching(Option<String> text, CancelToken token) {
    return RequestState(
        responses: none(), isFetching: true, token: some(token));
  }
}
