import 'package:flutter/material.dart';
import 'package:todo/db/todo_database.dart';
import 'package:todo/db/todo_dao.dart';
import 'package:todo/db/todo.dart';
import 'package:todo/edit_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(primarySwatch: Colors.red), home: MyHome());
  }
}

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  late final database;
  late TodoDao todoDao;
  int lastId = 1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getConnection();
  }

  getConnection() async {
    database =
        await $FloorTodoDatabase.databaseBuilder("todo_database.db").build();
    setState(() {
      todoDao = database.todoDao;
    });
  }

  add(int id, String task) {
    this.todoDao.insertTodo(Todo(id, task));
  }

  getLast() async {
    Todo? todo = await this.todoDao.findTodoLast();

    setState(() {
      if (todo != null) {
        lastId = todo.id + 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final key = GlobalKey<FormState>();
    TextEditingController controller = TextEditingController();
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              this.todoDao.deleteall();
            });
          },
          child: Icon(Icons.remove),
        ),
        appBar: AppBar(title: Text('To Do List')),
        body: Column(
          children: [
            Form(
                key: key,
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: controller,
                        decoration: InputDecoration(
                            hintText: "Enter Something",
                            labelText: "Todo List"),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Must Not Be Empty";
                          }
                          return null;
                        },
                      )
                    ],
                  ),
                )),
            Container(
              decoration: BoxDecoration(
                  color: Colors.red, borderRadius: BorderRadius.circular(10)),
              width: MediaQuery.of(context).size.width,
              child: OutlinedButton(
                onPressed: () async {
                  if (key.currentState!.validate()) {
                    String result = controller.text;
                    await getLast();
                    add(this.lastId, result);
                  }
                },
                child: Text(
                  "Save",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            Expanded(
                child: StreamBuilder<List<Todo>>(
              stream: this.todoDao.findAllTodo(),
              builder: ((context, AsyncSnapshot snapshot) {
                return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: Row(children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.6,
                            padding: EdgeInsets.symmetric(
                                vertical: 20, horizontal: 40),
                            child: Text("${snapshot.data[index].task}"),
                          ),
                          IconButton(
                              onPressed: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return EditScreen(snapshot.data[index].id);
                                }));
                              },
                              icon: Icon(Icons.edit),
                              color: Colors.red),
                          IconButton(
                              onPressed: () {
                                setState(() {
                                  this
                                      .todoDao
                                      .deleteById(snapshot.data[index].id);
                                });
                              },
                              icon: Icon(Icons.delete),
                              color: Colors.red),
                        ]),
                      );
                    });
              }),
            ))
          ],
        ));
  }
}
