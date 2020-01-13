import 'package:text_rest_client/models/models.dart';
import 'package:meta/meta.dart';

abstract class HistoryEvent {}

class AddEvent extends HistoryEvent {
  final List<HttpRequest> requests;
  AddEvent({@required this.requests});
}

class DeleteEvent extends HistoryEvent {
  final History history;
  DeleteEvent({@required this.history});
}

class LoadEvent extends HistoryEvent {}

class LoadCompleteEvent extends HistoryEvent {}
