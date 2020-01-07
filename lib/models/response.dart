import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';

class HttpResponse {
  Either<String, Response> response;
  HttpResponse({this.response});
}
