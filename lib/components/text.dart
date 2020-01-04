// import 'package:dartz/dartz.dart';
// import 'package:flutter/material.dart';
// import 'package:extended_text_field/extended_text_field.dart';

// class MethodText extends SpecialText {
//   final String flag;
//   final int start;
//   final Map<String, Color> colorMap = {
//     "GET": Colors.green,
//     "POST": Colors.yellow,
//     "PUT": Colors.blue,
//     "PATCH": Colors.grey,
//     "DELETE": Colors.red,
//   };

//   MethodText(TextStyle textStyle, SpecialTextGestureTapCallback onTap,
//       {this.start, this.flag})
//       : super(
//           flag,
//           flag,
//           textStyle,
//         );

//   @override
//   InlineSpan finishText() {
//     final originalText = toString();
//     final String text = toString().toUpperCase();
//     final String trimText = text.trim();
//     print("!!!!!!!!!!!!!!!!");
//     print(trimText);
//     print(colorMap.containsKey(trimText));

//     return colorMap.containsKey(trimText)
//         ? BackgroundTextSpan(
//             background: Paint()..color = colorMap[trimText],
//             text: trimText,
//             actualText: originalText,
//             start: start,
//           )
//         : SpecialTextSpan(
//             text: originalText,
//             start: start,
//             actualText: originalText,
//           );
//   }
// }

// class RequestSpanBuilder extends SpecialTextSpanBuilder {
//   final BuildContext context;
//   final flags = Set.from(["get", "post", "put", "patch", "delete", "head"]);
//   RequestSpanBuilder({this.context});
//   @override
//   SpecialText createSpecialText(String flag,
//       {TextStyle textStyle, onTap, int index}) {
//     if (flag == null || flag == "") return null;
//     final target = catching(() {
//       if (!flag.endsWith(" ")) {
//         return null;
//       }
//       final newLineIndex = flag.lastIndexOf("\n");
//       final token = flag.substring(newLineIndex == -1 ? 0 : newLineIndex);

//       if (flags.contains(token.trim())) {
//         return token.toUpperCase().trim();
//       }

//       return null;
//     }).toOption();

//     final method = target.getOrElse(() => null);
//     if (method != null) {
//       print(method);
//       return MethodText(textStyle, onTap,
//           start: index - method.length - 1, flag: method);
//     }

//     return null;
//   }
// }
