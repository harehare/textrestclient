import 'package:meta/meta.dart';
import 'package:text_rest_client/models/request.dart';

class History {
  DateTime date;
  HttpRequest request;

  History({@required this.date, @required this.request});
}
