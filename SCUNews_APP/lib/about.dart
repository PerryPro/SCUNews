import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
class AboutPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
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
          title: Text("关于"),
          backgroundColor: Color.fromARGB(255, 119, 136, 213),
          //设置appbar背景颜色
          centerTitle: true, //设置标题是否局中
        ),
        body: Padding(
          padding: EdgeInsets.all(5.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment:
            CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                "大川新闻",
                style: TextStyle(fontSize: 50, ),
              ),
              Text(
                "当前版本：V1.0.0",
              ),
              Text(
                "© PERRY @ SCU CS College",
              )
            ],
          ),
        ),
    );
  }
}