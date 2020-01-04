import 'package:flutter_test/flutter_test.dart';
import 'package:text_rest_client/models/models.dart';

void main() {
  test("Get Request", () {
    final req = HttpRequest.fromString("get https://httpbin.org/get")
        .getOrElse(() => HttpRequest());
    expect(
        req.url,
        equals(
          "https://httpbin.org/get",
        ));
    expect(
        req.method,
        equals(
          HttpMethod(method: Method.GET),
        ));
  });

  test("Post Request", () {
    final req = HttpRequest.fromString(
            'post https://httpbin.org/post\n{"Content-Type": "application/json"}\n{"data": "test"}')
        .getOrElse(() => HttpRequest());
    expect(
        req.url,
        equals(
          "https://httpbin.org/post",
        ));
    expect(
        req.method,
        equals(
          HttpMethod(method: Method.POST),
        ));
    expect(
        req.headers.getOrElse(() => {}),
        equals(
          {"Content-Type": "application/json"},
        ));
    expect(
        req.body.getOrElse(() => {}),
        equals(
          {"data": "test"},
        ));
  });

  test("Error Request", () {
    final req = HttpRequest.fromString('test');
    expect(req.isNone(), true);
  });
}
