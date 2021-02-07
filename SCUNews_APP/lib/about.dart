import 'package:flutter/material.dart';
import 'main.dart';

class AboutPage extends StatelessWidget {
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
        padding: EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              child: Text(
                "大川新闻",
                style: TextStyle(
                  fontSize: 30,
                ),
              ),
            ),
            Container(
              height: 15,
            ),
            Container(

                alignment: Alignment.center,
                child: Text(
                  "以最简单的方式提升阅读校园资讯的体验",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                )),
            Container(
              height: 15,
            ),
            Text(
              "当前版本：$versionCode",
              style: TextStyle(
                fontSize: 20,
                //fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              height: 15,
            ),
            Text(
              "版权所有 Perry  @ 四川大学 计算机学院",
              style: TextStyle(
                fontSize: 15,
              )
            )
          ],
        ),
      ),
    );
  }
}
