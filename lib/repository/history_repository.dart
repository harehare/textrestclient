import 'dart:async';
import 'dart:collection';
import 'package:dartz/dartz.dart';
import 'package:text_rest_client/models/models.dart';
import 'package:idb_shim/idb.dart';
import 'package:idb_shim/idb_browser.dart';

abstract class HistoryRepository {
  Future<History> addHistory(History history);
  Future<void> deleteHistory(History history);
  Future<List<History>> histories();
}

abstract class Connection {
  String storeName;
  IdbFactory idbFactory = getIdbFactory();
  Future<Database> db;
  void init() async {
    db = idbFactory.open('textrestclient', version: 1,
        onUpgradeNeeded: (VersionChangeEvent event) {
      Database db = event.database;
      db.createObjectStore(storeName, autoIncrement: true);
    });
  }

  Future<ObjectStore> get readableTxn async {
    final txn = (await db).transaction(storeName, idbModeReadOnly);
    return txn.objectStore(storeName);
  }

  Future<ObjectStore> get writableTxn async {
    final txn = (await db).transaction(storeName, idbModeReadWrite);
    return txn.objectStore(storeName);
  }
}

class WebHistoryRepositoryImpl with Connection implements HistoryRepository {
  WebHistoryRepositoryImpl() {
    this.storeName = 'history';
    init();
  }

  @override
  Future<History> addHistory(History history) async {
    final store = await writableTxn;
    await store.put({"data": history.toJson()});

    return history;
  }

  @override
  Future<void> deleteHistory(History history) async {
    return await (await writableTxn).delete(history.id);
  }

  @override
  Future<List<History>> histories() async {
    final list = <History>[];
    final store = await readableTxn;
    //ignore: cancel_subscriptions
    StreamSubscription subscription;
    subscription = store
        .openCursor(direction: idbDirectionPrev, autoAdvance: true)
        .listen((cursor) {
      try {
        if (cursor.value is Map) {
          list.add(History.fromJson(
              cursor.primaryKey as int, (cursor.value as Map)['data']));
        }
      } catch (e, stackTrace) {
        print(stackTrace);
        print(e);
      }
    });
    await subscription.asFuture();
    return list;
  }

  Map<K, V> asMap<K, V>(dynamic value) {
    return value as Map<K, V>;
  }
}
