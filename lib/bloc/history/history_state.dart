import 'package:dartz/dartz.dart';
import 'package:text_rest_client/models/models.dart';

class HistoryState {
  final bool isFetching;
  final Option<List<History>> histories;

  HistoryState({this.histories, this.isFetching});

  factory HistoryState.initial() {
    return HistoryState(histories: none(), isFetching: false);
  }

  factory HistoryState.load() {
    return HistoryState(histories: none(), isFetching: true);
  }

  factory HistoryState.successful(Option<List<History>> histories) {
    return HistoryState(histories: histories, isFetching: false);
  }
}
