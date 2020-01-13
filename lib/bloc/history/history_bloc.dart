import 'package:text_rest_client/bloc/history/history_event.dart';
import 'package:text_rest_client/bloc/history/history_state.dart';
import 'package:text_rest_client/repository/repository.dart';
import 'package:text_rest_client/models/models.dart';
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final HistoryRepository historyRepository;
  HistoryBloc({this.historyRepository});

  @override
  HistoryState get initialState => HistoryState.initial();

  @override
  Stream<HistoryState> mapEventToState(HistoryEvent event) async* {
    if (event is LoadEvent) {
      yield* _mapLoadToState();
      final histories = await historyRepository.histories();
      yield HistoryState.successful(some(histories));
    } else if (event is AddEvent) {
      final history = await historyRepository
          .addHistory(History(date: DateTime.now(), requests: event.requests))
          .catchError((err) => print(err));
      yield HistoryState(histories: state.histories.bind((histories) {
        return some(histories + [history]);
      }));
    } else if (event is DeleteEvent) {
      await historyRepository.deleteHistory(event.history);
      yield HistoryState(
          histories: state.histories.bind((histories) =>
              some(histories.where((h) => h.id != event.history.id))));
    }
  }

  Stream<HistoryState> _mapLoadToState() async* {
    yield HistoryState.load();
  }
}
