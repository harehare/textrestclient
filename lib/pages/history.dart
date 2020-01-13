import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:text_rest_client/bloc/bloc.dart';
import 'package:text_rest_client/models/models.dart';
import 'package:text_rest_client/components/components.dart';
import 'package:dartz/dartz.dart';
import 'package:expandable/expandable.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:easy_alert/easy_alert.dart';

class HistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
          titleSpacing: 0.0,
          leading: IconButton(
              iconSize: 24,
              icon: Image.asset('assets/icon_64.png'),
              onPressed: () => Navigator.of(context).pushNamed("/")),
          title: Text(
            "History",
            style: theme.textTheme.subhead,
          ),
          backgroundColor: theme.backgroundColor,
          elevation: 0.0,
          actions: []),
      body: BlocBuilder<HistoryBloc, HistoryState>(builder: (context, state) {
        if (state.isFetching) {
          return Center(
              child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(theme.indicatorColor),
          ));
        }

        if (state.histories.cata(() => 0, (h) => h.length) == 0) {
          return Center(
            child: Text("None"),
          );
        }

        return ListView.builder(
          itemBuilder: (BuildContext context, int index) => HistoryItem(
              history:
                  state.histories.cata(() => History.empty(), (h) => h[index])),
          itemCount: state.histories.cata(() => 0, (h) => h.length),
        );
      }),
      backgroundColor: theme.backgroundColor,
    );
  }
}

class HistoryItem extends StatelessWidget {
  final History history;
  final LocalStorage storage = LocalStorage('textrestclient');

  HistoryItem({@required this.history});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final format = DateFormat.yMMMEd();

    return ExpandableNotifier(
      child: Panel(
        child: Column(
          children: [
            ScrollOnExpand(
              scrollOnExpand: true,
              scrollOnCollapse: false,
              child: ExpandablePanel(
                tapHeaderToExpand: true,
                tapBodyToCollapse: true,
                theme: ExpandableThemeData(
                    headerAlignment: ExpandablePanelHeaderAlignment.center,
                    iconColor: theme.primaryColor),
                header: Padding(
                    padding: EdgeInsets.all(8),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(children: [
                            Text(
                              format.format(history.date),
                              style: theme.textTheme.body1,
                            ),
                            Text(
                              history.requests.first.comment == null
                                  ? ''
                                  : history.requests.first?.comment,
                              style: theme.textTheme.body1
                                  .copyWith(color: const Color(0xFF008800)),
                            ),
                          ]),
                          Row(children: [
                            IconButton(
                              tooltip: "Restore",
                              color: theme.iconTheme.color,
                              icon: Icon(Icons.restore),
                              iconSize: 24,
                              onPressed: () async {
                                await storage.setItem(
                                    "text",
                                    history.requests
                                        .map((req) => req.toString())
                                        .join('\n\n'));
                                Navigator.of(context).pushNamed("/");
                              },
                            ),
                            IconButton(
                              tooltip: "Delete",
                              color: theme.iconTheme.color,
                              icon: Icon(Icons.delete),
                              iconSize: 24,
                              onPressed: () async {
                                final ret = await Alert.confirm(context,
                                    title:
                                        "Are you sure you want to delete history?");
                                if (ret == Alert.OK) {
                                  BlocProvider.of<HistoryBloc>(context)
                                      .add(DeleteEvent(history: history));
                                  BlocProvider.of<HistoryBloc>(context)
                                      .add(LoadEvent());
                                }
                              },
                            ),
                          ]),
                        ])),
                collapsed: Padding(
                    padding: EdgeInsets.all(8),
                    child: Text("${history.requests.length} requests",
                        style: theme.textTheme.body2)),
                expanded: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: history.requests
                        .map((req) =>
                            RequestItem(request: some(req), matchWindow: true))
                        .toList()),
                builder: (_, collapsed, expanded) {
                  return Expandable(
                    collapsed: collapsed,
                    expanded: expanded,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
