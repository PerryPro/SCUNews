//收藏夹
import 'dart:async';
import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'main.dart';
import 'package:sqflite/sqflite.dart';
var _scaffoldkey2 = new GlobalKey<ScaffoldState>();

class FavPage extends StatefulWidget {
  _FavPageState createState() => _FavPageState();
}

class _FavPageState extends State<FavPage> {
  List<Map> list;

  Future getAllFav() async {
    list = await db.rawQuery('SELECT * FROM Fav');
    print(list);
    setState(() {});
  }

  @override
  void initState() {
    getAllFav();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("收藏夹"),
        backgroundColor: Color.fromARGB(255, 119, 136, 213),
        //设置appbar背景颜色
        centerTitle: true, //设置标题是否局中
        leading: FlatButton(
            textColor: Colors.white,
            child: Icon(
              Icons.keyboard_arrow_left,
              color: Colors.white,
              //size: 33,
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      body: list == null
          ? null
          : ListView.builder(
              itemCount: list.length,
              itemBuilder: (BuildContext context, int index) {
                NewsClip thing = new NewsClip.fromFav(
                    list[index]['link'],
                    list[index]['title'],
                    list[index]['time'],
                    list[index]['source']);
                return GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return MySc(thing);
                    }));
                  },
                  child: Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Column(
                      //padding: EdgeInsets.all(5.0),
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                                flex: 1,
                                child: Padding(
                                    padding: EdgeInsets.only(left: 10),
                                    child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              thing.title,
                                              style: TextStyle(fontSize: 16.0),
                                            ),
                                            Text(
                                              thing.source,
                                              style: TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 10.0),
                                            ),
                                            Text(
                                              thing.time,
                                              style: TextStyle(
                                                color: Colors.black54,
                                                //fontSize: 8.0
                                              ),
                                            ),
                                          ],
                                        )))),
                          ],
                        ),
                        Divider(
                          height: 5,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
