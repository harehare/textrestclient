import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';

class ReplResponse {
  Either<String, Response> response;
  ReplResponse({this.response});
}
