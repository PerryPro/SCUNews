import 'dart:async';
import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'main.dart';
class FocusPage extends StatefulWidget {
  _FocusPageState createState() => _FocusPageState();
}
var _scaffoldkey = new GlobalKey<ScaffoldState>();
class _FocusPageState extends State<FocusPage> {
  List<Map> list;
  int checkboxNum = 5;
  List<String> focusClass = ["award","vacation","competition","exam","cet"];
  List<String> focusClassCN = ["奖助学金","放假与停课","各类比赛","考试通知","四六级通知"];
  List<bool> checkbox = new List();
  TextEditingController textController = TextEditingController();
  List<Map> personalList;
  Future getAllFav() async {
    list = await db.rawQuery('SELECT * FROM Focus');
    print(list);
    initCheckbox();
    setState(() {});
  }

  bool hasKeyword(String keyword) {
    for(int i=0;i<list.length;i++){
        if(list[i]['word'] == keyword)return true;
      }
    return false;
  }

  void initCheckbox() {
    for(int i=0;i<checkboxNum;i++){
      checkbox.add(hasKeyword(focusClass[i]));
    }
  }

  Future addFocusRecord(String keyword) async{
    await db.transaction((txn) async {
      await txn.rawInsert(
          'INSERT INTO Focus(word) VALUES("$keyword")');
      //print('inserted1: $id1');
    });
  }

  Future delFocusRecord(String keyword) async{
    int count = await db
        .rawDelete('DELETE FROM Focus WHERE word = "$keyword"');
    assert(count == 1);
  }

  Future changePersonalRecord(String keyword) async{
    await db.rawQuery('DELETE FROM Focus WHERE word = "personal"');

    await db.transaction((txn) async {
      await txn.rawInsert(
          'INSERT INTO Focus(word, userword) VALUES("personal", "$keyword")');
      //print('inserted1: $id1');
    });
  }

  Future getPersonalRecord() async{
    personalList = await db.rawQuery('SELECT * FROM Focus WHERE word = "personal"');
    print(personalList);
    textController.text = personalList[0]["userword"];
    setState(() {

    });
  }

  Future delPushRecords() async{
    await db.rawQuery('DELETE FROM Pushed');
  }

  @override
  void initState() {
    getAllFav();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldkey,
        appBar: AppBar(
        title: Text("选择推送内容"),
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
        actions: <Widget>[
          Container(
            width: 50,
            child: FlatButton(
              textColor: Colors.white,
              onPressed: () {
                  delPushRecords();
                  _scaffoldkey.currentState.showSnackBar(
                    SnackBar(
                      content: Text('清除推送记录成功！'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                } ,
              child: Icon(
                Icons.delete_sweep,
                color: Colors.white,
                //size: 33,
              ),
            ),
          )
        ],
      ),
      body:
        ListView.builder(
            itemCount:checkboxNum +1,
            itemBuilder: (BuildContext context, int index) {
              if(index != checkboxNum ){
                String title = focusClassCN[index];
                String thisClass = focusClass[index];
                //print(checkbox[index]);
                return CheckboxListTile(
              value:checkbox[index],
              title: Text('$title'),
              onChanged: (value){
                print(value);
//                setState(() {
//                  _checkboxSelected=value;
//                });
                checkbox[index] = !checkbox[index];
                setState(() {

                });
                if(value) addFocusRecord("$thisClass");
                else delFocusRecord("$thisClass");
              },
            );
            }
              else return ListTile(
//                leading: Icon(
//                  Icons.edit
//                ),
                title: Text(
                  '自定义关键词',
                  //style: TextStyle(fontSize: 16),
                ),
                onTap: () {
                  getPersonalRecord();
                  showDialog<Null>(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return new AlertDialog(
                        title: new Text('自定义关键词：'),
                        content: new SingleChildScrollView(
                          child:TextField(
                            controller: textController,
                            decoration: InputDecoration(
                              helperText: '多个关键词以英文分号(;)隔开',
                            ),
                          )
                        ),
                        actions: <Widget>[
                          new FlatButton(
                            child: new Text('确认'),
                            onPressed: () {
                              changePersonalRecord(textController.text);
//                              print(textController.text);
                              Navigator.pop(context);
                              _scaffoldkey.currentState.showSnackBar(
                                SnackBar(
                                  content: Text('新的设置将在重新启动应用后生效'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                          new FlatButton(
                            child: new Text('取消'),
                            onPressed: () {
//                              getPersonalRecord();
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            }
        )

    );
  }
}
