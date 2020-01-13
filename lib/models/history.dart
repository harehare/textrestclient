import 'package:meta/meta.dart';
import 'package:text_rest_client/models/request.dart';

class History {
  int id;
  DateTime date;
  List<HttpRequest> requests;

  History({this.id, @required this.date, @required this.requests});

  factory History.empty() => History(id: null, date: null, requests: []);

  factory History.fromJson(int id, Map data) => History(
      id: id,
      date: DateTime.parse(data['date']),
      requests: (data['requests'] as List)
          .map((r) => HttpRequest.fromJson(r))
          .toList());

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'requests': requests.map((r) => r.toJson()).toList()
      };
}
