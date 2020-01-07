import 'package:meta/meta.dart';
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:recase/recase.dart';
import 'dart:ui';

enum Protocol { Http11, Http2 }

class HttpProtocol {
  Protocol protocol;
  HttpProtocol({@required this.protocol});

  String toString() {
    return protocol.toString().split(".")[1];
  }

  factory HttpProtocol.fromString(String protocolString) {
    switch (protocolString.toUpperCase()) {
      case "HTTP2":
        return HttpProtocol(protocol: Protocol.Http2);
      default:
        return HttpProtocol(protocol: Protocol.Http11);
    }
  }

  @override
  bool operator ==(other) =>
      other is HttpProtocol && other.protocol == protocol;

  @override
  int get hashCode => hashValues(protocol.toString(), "");
}

enum Method { GET, HEAD, POST, PUT, DELETE, CONNECT, OPTIONS, TRACE, PATCH }

class HttpMethod {
  Method method;
  HttpMethod({@required this.method});

  String toString() {
    return method.toString().split(".")[1];
  }

  factory HttpMethod.fromString(String methodString) {
    switch (methodString.toUpperCase()) {
      case "GET":
        return HttpMethod(method: Method.GET);
      case "HEAD":
        return HttpMethod(method: Method.HEAD);
      case "POST":
        return HttpMethod(method: Method.POST);
      case "PUT":
        return HttpMethod(method: Method.PUT);
      case "DELETE":
        return HttpMethod(method: Method.DELETE);
      case "CONNECT":
        return HttpMethod(method: Method.CONNECT);
      case "OPTIONS":
        return HttpMethod(method: Method.OPTIONS);
      case "TRACE":
        return HttpMethod(method: Method.TRACE);
      case "PATCH":
        return HttpMethod(method: Method.PATCH);
      default:
        return HttpMethod(method: Method.GET);
    }
  }

  @override
  bool operator ==(other) => other is HttpMethod && other.method == method;

  @override
  int get hashCode => hashValues(method.toString(), "");
}

class HttpRequest {
  String url;
  HttpMethod method = HttpMethod(method: Method.GET);
  HttpProtocol protocol = HttpProtocol(protocol: Protocol.Http11);
  Option<Map<String, String>> headers = none();
  Option<Map<String, dynamic>> body = none();
  HttpRequest(
      {@required this.url,
      @required this.protocol,
      @required this.method,
      this.headers,
      this.body});

  static Option<HttpRequest> fromString(String text) {
    final lines = text.split("\n").where((line) {
      return line != "" && !line.startsWith("#");
    }).toList();

    final method = catching(() {
      final tokens = lines.first.split(" ");
      return HttpMethod.fromString(tokens.first);
    }).toOption().getOrElse(() => HttpMethod(method: Method.GET));

    final protocol = catching(() {
      final tokens = lines.first.split(" ");
      return HttpProtocol.fromString(tokens.last);
    }).toOption().getOrElse(() => HttpProtocol(protocol: Protocol.Http11));

    final url = catching(() {
      final tokens = lines.first.split(" ");
      return tokens[1];
    }).toOption();

    final headers = catching(() {
      final headerString = lines[1];
      Map<String, dynamic> jsonValues = json.decode(headerString);

      return jsonValues.map((key, value) {
        ReCase rc = ReCase(key);
        return MapEntry(rc.headerCase, value.toString());
      });
    }).toOption();

    final body = catching(() {
      final bodyString = lines.sublist(2).join('\n');
      if (headers
          .getOrElse(() => <String, String>{})
          .containsKey("Content-Type")) {
        return json.decode(bodyString) as Map<String, dynamic>;
      } else {
        return {"raw": bodyString};
      }
    }).toOption();

    return url.bind((v) {
      return some(HttpRequest(
          body: body,
          protocol: protocol,
          method: method,
          headers: headers,
          url: v));
    });
  }

  String toCurlString() {
    final httpMethod = method?.toString();
    final headersString =
        headers?.getOrElse(() => <String, String>{})?.entries?.map((entry) {
      return '-H "${entry.key}: ${entry.value}"';
    })?.join(' ');

    final bodyString = headers.bind((h) {
      return body.bind((b) {
        switch (h["Content-Type"]) {
          case "application/json":
            return some("-d '${json.encode(b)}'");
          case "multipart/form-data":
            return some(b.entries
                .map((entry) => '-F "${entry.key}=${entry.value}"')
                .join(' '));
          case "application/x-www-form-urlencoded":
            return some(b.entries
                .map((entry) => "-d '${entry.key}=${entry.value}'")
                .join(' '));
          default:
            final raw = b['raw'].toString();
            return some(
                b.containsKey("raw") && b['raw'] != '' ? "-d '$raw'" : "");
        }
      });
    }).cata(() => '', (body) => body);

    return "curl -X $httpMethod $headersString $url $bodyString";
  }

  String toString() {
    final httpMethod = method?.toString();
    final headersString =
        json.encode(headers?.getOrElse(() => <String, String>{}));
    // TODO:
    final bodyString = headers?.bind((h) {
      return body?.bind((b) {
        switch (h["Content-Type"]) {
          case "application/json":
            return some(json.encode(b));
          case "multipart/form-data":
            return some(json.encode(b));
          default:
            return some(json.encode(b));
        }
      });
    });
    return "$httpMethod $url\n$headersString\n${bodyString?.getOrElse(() => '')}";
  }

  @override
  bool operator ==(other) =>
      other is HttpRequest &&
      other.url == url &&
      other.method == method &&
      other.headers?.getOrElse(() => {}) == headers?.getOrElse(() => {}) &&
      other.body?.getOrElse(() => {}) == body?.getOrElse(() => {});

  @override
  int get hashCode => hashValues(
      url, method, headers?.getOrElse(() => {}), body?.getOrElse(() => {}));
}
