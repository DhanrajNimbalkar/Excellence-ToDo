import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get_storage/get_storage.dart';
import 'package:todo/Constants/colors.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final storage = GetStorage();
  var todos;
  ScrollController _scrollcontroller = ScrollController();
  TextEditingController _title = TextEditingController();
  TextEditingController _todoList = TextEditingController();
  @override
  void initState() {
    todos = storage.read('getToDo');
    todos != null
        // ignore: unnecessary_statements
        ? todos = todos.reversed.toList()
        : todos = null;

    super.initState();
  }

  addToDo() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('New ToDo'),
          content: SingleChildScrollView(
              controller: _scrollcontroller,
              child: Scrollbar(
                controller: _scrollcontroller,
                isAlwaysShown: true,
                child: Column(
                  children: [
                    TextField(
                      controller: _title,
                      decoration: InputDecoration(
                          hintText: "Title",
                          border:
                              OutlineInputBorder(borderSide: BorderSide.none)),
                    ),
                    TextField(
                      controller: _todoList,
                      maxLines: null,
                      minLines: 10,
                      decoration: InputDecoration(
                          hintText: "To Do",
                          border:
                              OutlineInputBorder(borderSide: BorderSide.none)),
                    )
                  ],
                ),
              )),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Add',
                style: TextStyle(color: LightTheme.kAppBarText),
              ),
              onPressed: () {
                if (todos == null && _todoList.text.length != 0) {
                  setState(() {
                    todos = [];
                    todos.add({
                      "Title": _title.text.length == 0 ? null : _title.text,
                      "ToDo": _todoList.text
                    });
                  });
                  storage.write('getToDo', todos);
                } else if (_todoList.text.length != 0) {
                  setState(() {
                    todos.add({
                      "Title": _title.text.length == 0 ? null : _title.text,
                      "ToDo": _todoList.text
                    });
                  });
                  storage.write('getToDo', todos);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future pageRefresher() async {
    // Page refresher
    Completer<Null> completer = new Completer<Null>();
    await Future.delayed(Duration(seconds: 1)).then((onvalue) {
      completer.complete();
      setState(() {
        todos = storage.read('getToDo');
        todos != null
            // ignore: unnecessary_statements
            ? todos = todos.reversed.toList()
            : todos = null;
      });
    });
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: pageRefresher,
      child: Scaffold(
          floatingActionButton: FloatingActionButton(
              backgroundColor: LightTheme.kBackground,
              child: Icon(
                Icons.playlist_add,
                size: 30,
                color: LightTheme.kAppBarText,
              ),
              onPressed: () async {
                await addToDo();
                pageRefresher();
                setState(() {
                  _title.clear();
                  _todoList.clear();
                });
              }),
          appBar: AppBar(
            backgroundColor: LightTheme.kBackground,
            centerTitle: true,
            elevation: 0,
            title: Text("Your To Do List",
                style: TextStyle(color: LightTheme.kAppBarText)),
          ),
          backgroundColor: LightTheme.kBackground,
          body: SafeArea(
            child: todos != null && todos.length > 0
                ? Container(
                    padding: EdgeInsets.all(10),
                    child: StaggeredGridView.countBuilder(
                      crossAxisCount: 4,
                      // reverse: true,
                      itemCount: todos.length,
                      itemBuilder: (BuildContext context, int index) =>
                          new Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: LightTheme.kGrey),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      todos[index]['Title'] == null
                                          ? Container()
                                          : Text(todos[index]['Title'],
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF635E5E))),
                                      Text(todos[index]['ToDo'],
                                          overflow: TextOverflow.ellipsis,
                                          maxLines:
                                              todos[index]['Title'] != null
                                                  ? 5
                                                  : 7,
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Color(0xFF635E5E))),
                                    ],
                                  ))),
                      staggeredTileBuilder: (int index) =>
                          new StaggeredTile.fit(2),
                      mainAxisSpacing: 4.0,
                      crossAxisSpacing: 4.0,
                    ))
                : Center(
                    child: Text("No ToDo for You"),
                  ),
          )),
    );
  }
}
