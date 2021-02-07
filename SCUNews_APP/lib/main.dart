import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:dio/dio.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share/share.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//import 'package:flutter_android_downloader/flutter_android_downloader.dart';
import 'keywords.dart';
import 'page_refactor.dart';
import 'about.dart';
import 'favorite.dart';
import 'focus.dart';


Dio dio = Dio();
const String versionNum = "103";
const String versionCode = "V1.0.3";
Database db;
bool check = false;
String dbPath;
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
List<Map> focusList;
int pushIndex = 0;
int pushMax = 4;
//List<Map> test;
//Future main() async {
//  WidgetsFlutterBinding.ensureInitialized();
//  await FlutterDownloader.initialize(
//      debug: true // optional: set false to disable printing logs to console
//      );
//  await Permission.storage.request();
//  runApp(new MyApp());
//}



Future init() async {
  WidgetsFlutterBinding.ensureInitialized(); //FlutterDownloader initial
  await FlutterDownloader.initialize(
    //FlutterDownloader initial
      debug: true // optional: set false to disable printing logs to console
  );
  await Permission.storage.request();
  dbPath = await getDatabasesPath();
  //dbPath = '$dbPath/my2.db';
  dbPath = '$dbPath/my5.db';
  print("1xxxx $dbPath");
  check = await File("$dbPath").exists();
  await initDB();
  //await checkUpdate();

}

Future initDB() async {//初始化数据库
  if (check) {
    print("DB file exists");
    db = await openDatabase(dbPath);
//    focusList = await db.rawQuery('SELECT * FROM Focus');
    //await db.rawQuery('DELETE  FROM Pushed');
//    test = await db.rawQuery('SELECT * FROM Focus WHERE word = "aaa"');
//    if(test.isEmpty)print("23333333333");
 //   print(focusList);
  } else {
    print("Create DB file $dbPath");
    db = await openDatabase(dbPath, version: 1,
        onCreate: (Database db, int version) async {
          // When creating the db, create the table
          await db.execute(
              'CREATE TABLE Fav (link TEXT PRIMARY KEY, title TEXT, time TEXT,source TEXT)');
          await db.execute(
              'CREATE TABLE Focus (word TEXT PRIMARY KEY, userword TEXT)');
          await db.execute(
              'CREATE TABLE Pushed (link TEXT PRIMARY KEY, title TEXT, time TEXT,source TEXT)');
          await db.execute(
              'CREATE TABLE Settings (name TEXT PRIMARY KEY, value TEXT)');
        });
  }
}

Future addDBRecord(NewsClip thing,String table) async{
  String tlink = thing.url;
  String ttitle = thing.title;
  String ttime = thing.time;
  String source = thing.source;
  await db.transaction((txn) async {
    await txn.rawInsert(
        'INSERT INTO $table(link, title, time, source) VALUES("$tlink", "$ttitle", "$ttime", "$source")');
    //print('inserted1: $id1');
  });
}

Future delDBRecord(String link) async{
  int count = await db
      .rawDelete('DELETE FROM Fav WHERE link = "$link"');
  assert(count == 1);
}

Future showNotification(NewsClip news) async {
  if(pushIndex < pushMax) {
    String title = news.title;
    List<Map> temp = await db.rawQuery(
        'SELECT * FROM Pushed WHERE title = "$title"');
    if (temp.isEmpty) {
      if(pushIndex >= pushMax) return;
      print("PIND = $pushIndex");
      pushIndex++;
      String time = news.time;
      String link = news.url;
      String source = news.source;
      addDBRecord(news, "Pushed");
      var android = new AndroidNotificationDetails(
          'channel id', 'channel NAME', 'CHANNEL DESCRIPTION',
          priority: Priority.High, importance: Importance.Max
      );
      var iOS = new IOSNotificationDetails();
      var platform = new NotificationDetails(android, iOS);
      await flutterLocalNotificationsPlugin.show(
          pushIndex, '$time来自$source：', '$title', platform,
          payload: '$title\n$link\n$source\n$time');
    }
  }
}

void needPush(List<NewsClip> list) async{//推送资讯
  if(focusList == null){
    focusList = await db.rawQuery('SELECT * FROM Focus');
  }
  for(int i=0;i<list.length;i++) {
    bool push = false;
    for(int j=0;j<focusList.length;j++){
      String temp = focusList[j]["word"];
      List<String> keywords = Keywords.map["$temp"];
      if(temp == "personal"){
        String userword = focusList[j]["userword"];
        if(keywords.isEmpty){
          keywords = userword.split(";");
          print(keywords);
        }
      }
      if(!keywords.isEmpty){
      for(int k=0;k<keywords.length;k++){
          if(!keywords[k].isEmpty && list[i].title.contains(keywords[k])) {
            print(keywords[k]);
              push = true;
              break;
            }
        }}
      if(push) {
        showNotification(list[i]);
        break;
      }
    }
  }
}

void main() {
  init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:
      ScrollableTabsDemo(),
    );
  }
}

class NewsClip {//资讯对象
  final String url;
  final String title;
  final String source;
  final String image;
  String time;
  bool isFavorite;

  NewsClip.fromJson(Map<String, dynamic> json)
      : title = json["title"],
        url = json["link"],
        image = json["img"],
        source = json["source"],
        time = json["date"],
        isFavorite = false;
  

  NewsClip.fromFav(String url2,String title2,String time2,String source2)
      : title = title2,
        url = url2,
        image = '',
        source = source2,
        time = time2,
        isFavorite = true;

  NewsClip.fromNotice(String url2,String title2,String time2,String source2)
      : title = title2,
        url = url2,
        image = '',
        source = source2,
        time = time2,
        isFavorite = false;
}

class _Page {
  _Page({this.text, this.key})
      : this.url = "http://47.94.97.113/newsapi/$key/1/feed.d.json";
  final String text;
  final String key;
  final String url;
  final List<NewsClip> list = List();

  Future _request() async {
    Response response = await dio.get(url);
    String value = response.toString();
    //print(value);
    //value = value.substring(9, value.length - 1);
    Map<String, dynamic> map = json.decode(value);
    List data = map['data'];
    list.clear();
    data.forEach((value) {
      list.add(NewsClip.fromJson(value));
    });
    needPush(list);
    return response;
  }
}


List<_Page> _allPages = <_Page>[
  _Page(text: '教务处', key: "jwc"),
  _Page(text: '学工部', key: "xgb"),
  _Page(text: '校团委', key: "xtw"),
  _Page(text: '计算机学院', key: "jsjxy"),
];

class ScrollableTabsDemo extends StatefulWidget {
  @override
  _ScrollableTabsState createState() => _ScrollableTabsState();
}

class _ScrollableTabsState extends State<ScrollableTabsDemo>
    with SingleTickerProviderStateMixin {
  TabController _controller;
  bool ff = false;

  @override
  void initState() {
    super.initState();
    _controller = TabController(vsync: this, length: _allPages.length);
    checkUpdate(false);
    //初始化推送
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOS = new IOSInitializationSettings();
    var initSetttings = new InitializationSettings(android, iOS);
    flutterLocalNotificationsPlugin.initialize(initSetttings, onSelectNotification: onNoticeTap);

    //initDB();
  }

  @override
  void dispose() {
    db.close();
    _controller.dispose();
    super.dispose();
  }

  Decoration _getIndicator() {
    return ShapeDecoration(
      shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            side: BorderSide(color: Colors.white70, width: 1.5),
          ) +
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4.0)),
            side: BorderSide(color: Colors.transparent, width: 8.0),
          ),
    );
  }

  Future downloadNewVersion(String vNum) async {
    await FlutterDownloader.enqueue(
      fileName: "SCUNews_V$vNum.apk",
      url: "http://47.94.97.113/newsAPI/flutter/SCUNews_V$vNum.apk",
      savedDir:
      (await getExternalStorageDirectory()).path,
      showNotification: true,
      // show download progress in status bar (for Android)
      openFileFromNotification:
      true, // click on notification to open downloaded file (for Android)
    );
  }

  Future checkUpdate(bool popUp) async {
    Response response =
        await dio.get("http://47.94.97.113/newsAPI/flutter/version2020.txt");
    String value = response.toString();
    List<String> res = value.split('\n');
    //print(value);
    int serverV = int.parse(res[0]);
    int nowV = int.parse(versionNum);
    if (serverV > nowV) {
      print(serverV);
      String notice = "";
      if(res.length >= 3)notice = res[2];
      String temp = res[1];
      showDialog<Null>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text('有新版本：'),
            content: new SingleChildScrollView(
              child: new ListBody(
                children: <Widget>[
                  Text('当前版本：$versionCode'),
                  Text('最新版本：$temp'),
                  Text('$notice'),
                ],
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('升级'),
                onPressed: () {
                  downloadNewVersion(res[0]);
                  Navigator.pop(context);
                },
              ),
              new FlatButton(
                child: new Text('取消'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    } else if (serverV == nowV && popUp) {
      showDialog<Null>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text('检查更新：'),
            content: new SingleChildScrollView(
              child: new ListBody(
                children: <Widget>[
                  new Text('已是最新版本'),
                ],
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('确定'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<dynamic> onNoticeTap(String payload){
    //payload: '$title\n$link\n$source\n$time'
    List<String> split = payload.split("\n");
    String title = split[0];
    String url = split[1];
    String source = split[2];
    String time = split[3];
    //Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return MySc(NewsClip.fromNotice(url, title, time, source));
    }));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (){
        //SystemChannels.platform.invokeMethod<void>('SystemNavigator.pop'):
        //print("SS");
        exit(0);
        //return Future.value(true);
      },
      child: Scaffold(
        endDrawer: Drawer(
          child: Container(
            child: ListView(
              padding: EdgeInsets.zero, //去除灰色状态栏
              children: <Widget>[
                DrawerHeader(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/img/bg.png"),
                          //NetworkImage('http:\/\/47.94.97.113\/newsAPI\/img\/bg.png'),
                          fit: BoxFit.cover)),
                  child: null,
                ),
                ListTile(
                  leading: Icon(
                    Icons.star, size: 32,
                    //color: Colors.orangeAccent,
                  ),
                  title: Text(
                    '收藏夹',
                    style: TextStyle(fontSize: 16),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return FavPage();
                    }));
                  },
                ),
                Divider(
                  height: 3,
                ),
                ListTile(
                  leading: Icon(
                    Icons.update,
                    size: 32,
                  ),
                  title: Text(
                    '检查更新',
                    style: TextStyle(fontSize: 16),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    checkUpdate(true);
                  },
                ),
                Divider(
                  height: 3,
                ),
                ListTile(
                  leading: Icon(
                    Icons.feedback,
                    size: 32,
                  ),
                  title: Text(
                    '意见反馈',
                    style: TextStyle(fontSize: 16),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return Scaffold(
                        appBar: AppBar(
                          title: Text('意见反馈'),
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
                        body: InAppWebView(
                          initialUrl: 'http://47.94.97.113/newsapi/flutter/feed/',
                          initialHeaders: {},
                          initialOptions: InAppWebViewGroupOptions(
                            crossPlatform: InAppWebViewOptions(
                              debuggingEnabled: false,
                              useOnDownloadStart: false,
                              disableHorizontalScroll: true,
                            ),
                            android: AndroidInAppWebViewOptions(
                              loadWithOverviewMode: false,

                            ),
                          ),

                        ),
                      );
                    }));
                  },
                ),
//                Divider(
//                  height: 3,
//                ),
//                ListTile(
//                  leading: Icon(
//                    Icons.settings,
//                    size: 32,
//                  ),
//                  title: Text(
//                    '设置',
//                    style: TextStyle(fontSize: 16),
//
//                  ),
//                  onTap: () {
//                    Navigator.pop(context);
//                    Navigator.push(context, MaterialPageRoute(builder: (context) {
//                      return AboutPage();
//                    }));
//                  },
//                ),
                Divider(
                  height: 3,
                ),
                ListTile(
                  leading: Icon(
                    Icons.notifications,
                    size: 32,
                  ),
                  title: Text(
                    '推送设置',
                    style: TextStyle(fontSize: 16),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return FocusPage();
                    }));
                  },
                ),
                Divider(
                  height: 3,
                ),
                ListTile(
                  leading: Icon(
                    Icons.info,
                    size: 32,
                  ),
                  title: Text(
                    '关于',
                    style: TextStyle(fontSize: 16),

                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return AboutPage();
                    }));
                  },
                ),
              ],
            ),
          ),
        ),
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverOverlapAbsorber(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                sliver: SliverAppBar(
                  title: const Text('大川新闻'),
                  pinned: false,
                  backgroundColor: Color.fromARGB(255, 119, 136, 213),
                  forceElevated: innerBoxIsScrolled,
                  bottom: TabBar(
                    controller: _controller,
                    isScrollable: true,
                    labelColor: Colors.white,
                    indicator: _getIndicator(),
                    tabs: _allPages.map<Tab>((_Page page) {
                      return Tab(text: page.text);
                    }).toList(),
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _controller,
            children: _allPages.map<Widget>((_Page page) {
              return SafeArea(
                top: false,
                bottom: true,
                child: _PageWidget(page),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class MySc extends StatefulWidget {
  NewsClip content;
  MySc(NewsClip thing) {
    content = thing;
  }
  @override
  State<StatefulWidget> createState() {
    return _SMySc();
  }
}

var _scaffoldkey = new GlobalKey<ScaffoldState>();

class _SMySc extends State<MySc> {
  bool ff = false;
  InAppWebViewController webView;
  int index = 1;
  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    //super.initState();
    ff = widget.content.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldkey, //用一个key来指定，方便显示snackbar
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
          actions: <Widget>[
            Container(
              width: 50,
              child: FlatButton(
                textColor: Colors.white,
                onPressed: () {
                  setState(() {
                    ff = !ff;
                    widget.content.isFavorite = ff;
                  });
                  if (ff) {
                    addDBRecord(widget.content,"Fav");
                    _scaffoldkey.currentState.showSnackBar(
                      SnackBar(
                        content: Text('添加收藏成功！'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  } else {
                    delDBRecord(widget.content.url);
                    _scaffoldkey.currentState.showSnackBar(
                      SnackBar(
                        content: Text('取消收藏成功！'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                },
                child: Icon(
                  ff ? Icons.star : Icons.star_border,
                  color: Colors.white,
                  //size: 33,
                ),
              ),
            ),
            Container(
              width: 50,
              child: FlatButton(
                textColor: Colors.white,
                onPressed: () {
                  Share.share(widget.content.source +
                      "：" +
                      widget.content.title +
                      "\n" +
                      widget.content.url);
                },
                child: Icon(
                  Icons.share,
                  color: Colors.white,
                  //size: 33,
                ),
              ),
            )
          ],
          //new Icon(Icons.keyboard_arrow_left,size: 33,),
          title: Text("详情"),
          backgroundColor: Color.fromARGB(255, 119, 136, 213),
          //设置appbar背景颜色
          centerTitle: true, //设置标题是否局中
        ),
        body: IndexedStack(
          index: index,
          children: <Widget>[
            InAppWebView(
              initialUrl: widget.content.url,
              initialHeaders: {},
              initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                  debuggingEnabled: true,
                  useOnDownloadStart: true,
                ),
                android: AndroidInAppWebViewOptions(
                  loadWithOverviewMode: false,
                ),
              ),
              onWebViewCreated: (InAppWebViewController controller) {
                webView = controller;
              },
              onLoadStart: (InAppWebViewController controller, String url) {},
              onLoadStop: (InAppWebViewController controller, String url) {
                if (url.contains("jwc.scu.edu.cn")) {
                  webView.evaluateJavascript(source: PageRefactor.jwc);
                } else if (url.contains("xsc.scu.edu.cn")) {
                  webView.evaluateJavascript(source: PageRefactor.xgb);
                } else if (url.contains("tuanwei.scu.edu.cn")) {
                  webView.evaluateJavascript(source: PageRefactor.xtw);
                } else if (url.contains("cs.scu.edu.cn")) {
                  webView.evaluateJavascript(source: PageRefactor.jsjxy);
                }
                //sleep(Duration(microseconds: 500));
                //pyz
                setState(() {
                  index = 0;
                });
              },
              onDownloadStart: (controller, url) async {
                print("onDownloadStart $url");
                if (url.contains("system/_content/download.jsp")) {
                  _launchURL(widget.content.url);
                } else {
                  String temp = Uri.decodeFull(url);
                  String FileName = temp.substring( temp.lastIndexOf('|')+1, temp.length );
//                  //print(FileName);
                  final taskId = await FlutterDownloader.enqueue(
                    fileName: FileName,
                    url: url,
                    savedDir: (await getExternalStorageDirectory()).path,
                    showNotification: true,
                    // show download progress in status bar (for Android)
                    openFileFromNotification:
                    true, // click on notification to open downloaded file (for Android)
                  );
//                  downloadFile(url,FileName);
                }
              },
            ),
            Container(
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ],
        )
    );
  }
}

class _PageWidget extends StatefulWidget {
  const _PageWidget(this.page, {Key key}) : super(key: key);
  final _Page page;

  @override
  State<StatefulWidget> createState() {
    return _PageWidgetState();
  }
}

class _PageWidgetState extends State<_PageWidget>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  InAppWebViewController webView; //pyz
  ScrollController _controller = new ScrollController();
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future _refreshData() async {
    Response response = await widget.page._request();
    setState(() {});
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _refreshData,
      child: Scrollbar(
        child: ListView.builder(
          //controller: _controller,
          padding: kMaterialListPadding,
          itemCount: widget.page.list.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return MySc(widget.page.list[index]);
                }));
              },
              child: Padding(
                padding: EdgeInsets.all(5.0),
                child: Column(
                  //padding: EdgeInsets.all(5.0),
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3.0),
//                            boxShadow: [
//                              BoxShadow(
//                                  color: Colors.black54,
//                                  offset: Offset(2.0, 2.0),
//                                  blurRadius: 4.0)
//                            ]
                          ),
                          child: Image.asset(
                            "assets/img/scu.jpg",
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )


//                          Image.network(
//                            widget.page.list[index].image,
//                            width: 50,
//                            height: 50,
//                            fit: BoxFit.cover,
//                          ),
                        ),
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
                                          widget.page.list[index].title,
                                          style: TextStyle(fontSize: 16.0),
                                        ),
                                        Text(
                                          widget.page.list[index].time,
                                          style: TextStyle(
                                            color: Colors.black54,
                                            //fontSize: 8.0
                                          ),
                                        ),
                                        //Divider(),
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
      ),
    );
  }
}
