import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:clippy/browser.dart' as clippy;
import 'package:text_rest_client/models/models.dart';
import 'package:dartz/dartz.dart';
import 'package:url_launcher/url_launcher.dart';

class Clip {
  Future<dynamic> setData(String text) async {
    if (kIsWeb) {
      return clippy.write(text);
    } else {
      return Clipboard.setData(ClipboardData(text: text));
    }
  }
}

class Util {
  static final blankLine = RegExp(r'^\n', multiLine: true);

  static Iterable<Option<HttpRequest>> parseText(String text) {
    return text.split(blankLine).map((lines) => HttpRequest.fromString(lines));
  }

  static double height(String text) {
    return text.split('\n').length * 23.0;
  }

  static bool isPhone(double width) {
    return width <= 480;
  }

  static void openURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }
}
