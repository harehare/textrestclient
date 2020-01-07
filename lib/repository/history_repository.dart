import 'package:text_rest_client/models/models.dart';
import 'package:dartz/dartz.dart';

abstract class HistoryRepository {
  Either<String, bool> addHistory(History history);
  Either<String, bool> deleteHistory(History history);
  Either<String, List<History>> histories();
}

class WebHistoryRepositoryImpl implements HistoryRepository {
  @override
  Either<String, bool> addHistory(History history) {
    // TODO: implement addHistory
    return null;
  }

  @override
  Either<String, bool> deleteHistory(History history) {
    // TODO: implement deleteHistory
    return null;
  }

  @override
  Either<String, List<History>> histories() {
    // TODO: implement histories
    return null;
  }
}

class AndroidHistoryRepositoryImpl implements HistoryRepository {
  @override
  Either<String, bool> addHistory(History history) {
    // TODO: implement addHistory
    return null;
  }

  @override
  Either<String, bool> deleteHistory(History history) {
    // TODO: implement deleteHistory
    return null;
  }

  @override
  Either<String, List<History>> histories() {
    // TODO: implement histories
    return null;
  }
}
