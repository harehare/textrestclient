import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:text_rest_client/bloc/bloc.dart';
import 'package:text_rest_client/models/models.dart';
import 'package:text_rest_client/components/components.dart';
import 'package:text_rest_client/utils.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flushbar/flushbar.dart';
import 'package:localstorage/localstorage.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  final _controller = TextEditingController();
  final _pageController = PageController();
  final LocalStorage storage = LocalStorage('textrestclient');
  int _page = 0;

  @override
  void initState() {
    super.initState();
    initAsyncState();
    WidgetsBinding.instance.addObserver(this);
  }

  initAsyncState() async {
    await storage.ready;
    _controller.text = storage.getItem("text");
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      storage.setItem("text", _controller.text);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _pageController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
        appBar: AppBar(
            titleSpacing: 0.0,
            leading: IconButton(
                iconSize: 24,
                icon: Image.asset('assets/icon_64.png'),
                onPressed: () => Navigator.of(context).pushNamed("/")),
            title: Text(
              "Text Rest Client",
              style: theme.textTheme.subhead,
            ),
            backgroundColor: theme.backgroundColor,
            elevation: 0.0,
            actions: [
              IconButton(
                tooltip: "Github",
                color: theme.iconTheme.color,
                icon: Icon(FontAwesomeIcons.github),
                onPressed: () {
                  Util.openURL("https://github.com/harehare/TextRestClient");
                },
              ),
              IconButton(
                  tooltip: "History",
                  color: theme.iconTheme.color,
                  icon: Icon(Icons.history),
                  onPressed: () =>
                      Navigator.of(context).pushNamed("/histories")),
              Theme(
                  data: Theme.of(context).copyWith(
                    cardColor: theme.backgroundColor,
                    iconTheme: theme.iconTheme,
                  ),
                  child: PopupMenuButton<int>(
                      onSelected: (index) async {
                        switch (index) {
                          case 1:
                            await Clip().setData(
                                Util.parseText(_controller.text)
                                    .map((req) => req.cata(
                                        () => '', (req) => req.toCurlString()))
                                    .join('\n'));
                            Flushbar(
                                message: "Copied to clipboard",
                                duration: Duration(seconds: 3))
                              ..show(context);
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                            const PopupMenuItem(
                              value: 1,
                              child: Text(
                                'Copy CURL',
                              ),
                            ),
                          ])),
            ]),
        body: BlocBuilder<RequestBloc, RequestState>(
            builder: (context, state) => Stack(fit: StackFit.expand, children: [
                  Util.isPhone(size.width)
                      ? PageView(
                          controller: _pageController,
                          onPageChanged: (page) {
                            setState(() {
                              this._page = page;
                            });
                          },
                          children: [
                              editorWidget(context),
                              respponseWidget(context, state)
                            ])
                      : Column(children: [
                          Row(
                            children: [
                              editorWidget(context),
                              respponseWidget(context, state)
                            ],
                          )
                        ]),
                  state.isFetching
                      ? Positioned(
                          top: 0.0,
                          child: Container(
                              width: size.width,
                              height: 3,
                              child: LinearProgressIndicator(
                                backgroundColor: theme.indicatorColor,
                              )),
                        )
                      : SizedBox.shrink(),
                  Positioned(
                    bottom: 20.0,
                    right: 20.0,
                    child: state.isFetching
                        ? FloatingActionButton(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                                side: BorderSide(
                                    color: Colors.black45, width: 3.0),
                                borderRadius: BorderRadius.circular(100)),
                            child: Icon(
                              Icons.stop,
                              color: Colors.white,
                              size: 40,
                            ),
                            tooltip: "Cancel Request",
                            onPressed: () =>
                                BlocProvider.of<RequestBloc>(context)
                                    .add(SendCancelEvent()),
                          )
                        : FloatingActionButton(
                            backgroundColor: theme.buttonColor,
                            shape: RoundedRectangleBorder(
                                side: BorderSide(
                                    color: Colors.black45, width: 3.0),
                                borderRadius: BorderRadius.circular(100)),
                            child: Icon(
                              Icons.play_arrow,
                              color: Colors.black,
                              size: 40,
                            ),
                            tooltip: "Send Request",
                            onPressed: () {
                              final text = _controller.selection.start !=
                                      _controller.selection.end
                                  ? _controller.text.substring(
                                      _controller.selection.start,
                                      _controller.selection.end)
                                  : _controller.text;
                              BlocProvider.of<RequestBloc>(context)
                                  .add(SendEvent(text: text));
                              if (Util.isPhone(size.width)) {
                                _pageController.jumpToPage(1);
                              }
                              storage.setItem("text", _controller.text);
                              final requests = Util.parseText(text)
                                  .where((v) => v.isSome())
                                  .map((v) => v.cata(
                                      () => HttpRequest.empty(), (vv) => vv))
                                  .toList();
                              BlocProvider.of<HistoryBloc>(context)
                                  .add(AddEvent(requests: requests));
                            }),
                  ),
                ])),
        backgroundColor: theme.backgroundColor,
        bottomNavigationBar: Util.isPhone(size.width)
            ? BottomNavigationBar(
                backgroundColor: theme.backgroundColor,
                currentIndex: _page,
                onTap: (page) {
                  _pageController.animateToPage(page,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease);
                },
                items: [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.edit), title: Text("Request")),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.code), title: Text("Response")),
                ],
              )
            : null);
  }

  Widget editorWidget(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final height = Util.isPhone(size.width)
        ? (size.height - 165) / 2
        : (size.height - 145) / 2;

    return Column(children: [
      Container(
        width: Util.isPhone(size.width) ? size.width : size.width / 2,
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text("Request", style: theme.textTheme.body1)),
              ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: height,
                  maxHeight: height,
                ),
                child: TextField(
                  controller: _controller,
                  textAlignVertical: TextAlignVertical.top,
                  expands: true,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  style: theme.textTheme.body1,
                  onChanged: (text) => BlocProvider.of<RequestBloc>(context)
                      .add(InputEvent(input: text)),
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: theme.accentColor,
                      contentPadding: EdgeInsets.all(8.0),
                      hintText:
                          'POST https://foo.bar\n{"Content-Type": "application/json"}\n\nPUT https://foo.bar\n{"Content-Type": "application/json"}'),
                ),
              ),
            ],
          ),
        ),
      ),
      requestWidget(context),
    ]);
  }

  Widget requestWidget(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final height = Util.isPhone(size.width)
        ? (size.height - 165) / 2
        : (size.height - 145) / 2;
    final width = Util.isPhone(size.width) ? size.width : size.width / 2 - 16;
    final requests = Util.parseText(_controller.text);

    return Padding(
      padding: EdgeInsets.all(8),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          border: Border.all(color: theme.dividerColor, width: 2.0),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        child: requests.length == 0
            ? Center(child: Text("Empty request", style: theme.textTheme.body1))
            : Scrollbar(
                child: SingleChildScrollView(
                  child: Column(
                    children: requests
                        .map((req) => RequestItem(request: req))
                        .toList(),
                  ),
                ),
              ),
      ),
    );
  }

  Widget respponseWidget(BuildContext context, RequestState state) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final height =
        Util.isPhone(size.width) ? size.height - 155 : size.height - 130;
    final width = Util.isPhone(size.width) ? size.width : size.width / 2 - 16;

    return Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text("Response", style: theme.textTheme.body1),
            ),
            Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                border: Border.all(color: theme.dividerColor, width: 2.0),
                borderRadius: const BorderRadius.all(Radius.circular(8)),
              ),
              child: state.responses.isNone() && !state.isFetching
                  ? Center(
                      child:
                          Text("Empty response", style: theme.textTheme.body1))
                  : state.isFetching
                      ? Center(
                          child: Text("Sending request...",
                              style: theme.textTheme.body1))
                      : Scrollbar(
                          child: SingleChildScrollView(
                            child: Column(
                              children: state.responses
                                  .bind((responses) => dartz.some(responses.map(
                                      (response) =>
                                          ResponseItem(response: response))))
                                  .getOrElse(() => [])
                                  .toList(),
                            ),
                          ),
                        ),
            ),
          ],
        ));
  }
}
