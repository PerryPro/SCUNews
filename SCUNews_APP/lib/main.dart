import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:dio/dio.dart';

//import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
//import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'page_refactor.dart';
import 'about.dart';
import 'package:share/share.dart';

Dio dio = Dio();
const String versionNum = "100";
const String versionCode = "V1.0.0";
//Future main() async {
//  WidgetsFlutterBinding.ensureInitialized();
//  await FlutterDownloader.initialize(
//      debug: true // optional: set false to disable printing logs to console
//      );
//  await Permission.storage.request();
//  runApp(new MyApp());
//}
void main() {
  init();
  //checkUpdate();
  runApp(MyApp());
}

Future init() async {
  WidgetsFlutterBinding.ensureInitialized(); //FlutterDownloader initial
  await FlutterDownloader.initialize(
      //FlutterDownloader initial
      debug: true // optional: set false to disable printing logs to console
      );
  await Permission.storage.request();
  //await checkUpdate();
}



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ScrollableTabsDemo(),
    );
  }
}

class _Page {
  _Page({this.text, this.key})
      : this.url = "http://47.94.97.113/newsapi/$key/1/feed.d.json";

  //"https://3g.163.com/touch/reconstruct/article/list/$key/0-20.html";
  final String text;
  final String key;
  final String url;
  //final bool isFavorite = false;
  final List<_News> list = List();

  Future _request() async {
    Response response = await dio.get(url);
    String value = response.toString();
    //print(value);
    //value = value.substring(9, value.length - 1);
    Map<String, dynamic> map = json.decode(value);
    List data = map['data'];
    list.clear();
    data.forEach((value) {
      list.add(_News.fromJson(value));
    });
    return response;
  }
}

class _News {
  final String title;
  final String url;
  final String skpUrl;
  final String image;
  final String source;
  final String time;
   bool isFavorite;
  _News.fromJson(Map<String, dynamic> json)
      : title = json["title"],
        url = json["link"],
        skpUrl = json["skipURL"],
        image = json["img"],
        source = json["source"],
        time = json["date"],
        isFavorite = false;
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
    checkUpdate();
  }

  @override
  void dispose() {
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

  Future downloadNewVersion(String vNum) async{
//    await FlutterDownloader.enqueue(
//      url: "http://47.94.97.113/newsAPI/flutter/SCUNews_V$vNum.apk",
//      savedDir:
//      (await getExternalStorageDirectory()).path,
//      showNotification: true,
//      // show download progress in status bar (for Android)
//      openFileFromNotification:
//      true, // click on notification to open downloaded file (for Android)
//    );
    if (await canLaunch("http://47.94.97.113/newsAPI/flutter/SCUNews_V$vNum.apk")) {
      await launch("http://47.94.97.113/newsAPI/flutter/SCUNews_V$vNum.apk");
    } else {
      throw 'Could not launch update url';
    }
  }

  Future checkUpdate() async{
    Response response = await dio.get("http://47.94.97.113/newsAPI/flutter/version.txt");
    String value = response.toString();
    List<String> res = value.split('\n');
    //print(value);
    int serverV = int.parse(res[0]);
    int nowV = int.parse(versionNum);
    if(serverV > nowV){
      print(serverV);
      String temp = res[1];
      showDialog<Null>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context)
        {
          return new AlertDialog(
            title: new Text('有新版本：'),
            content: new SingleChildScrollView(
              child: new ListBody(
                children: <Widget>[
                  new Text('当前版本：$versionCode \t 最新版本：$temp'),
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: Drawer(
        child: Container(
          child: ListView(
            padding: EdgeInsets.zero, //去除灰色状态栏
            children: <Widget>[
              DrawerHeader(
//                decoration: BoxDecoration(
//                  color: Colors.lightBlueAccent,
//                ),
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: NetworkImage(
                            'http:\/\/47.94.97.113\/newsAPI\/img\/bg.png'),
                        fit: BoxFit.cover)),
                child: null,
//                child: Image.network(
//                  "http:\/\/47.94.97.113\/newsAPI\/img\/bg.png",
//                  width: 500,
//                  height: 50,
//                  fit: BoxFit.fill,
//                ),
//                Center(
//                  child: SizedBox(
//                    width: 60.0,
//                    height: 60.0,
//                    child: CircleAvatar(
//                      child: Text('R'),
//                    ),
//                  ),
//                ),
              ),
              ListTile(
                leading: Icon(Icons.star,size: 32,
                  //color: Colors.orangeAccent,
                ),
                title: Text('收藏夹',style: TextStyle(fontSize: 16),),
                onTap: () {

                  Navigator.pop(context);
                },
              ),
              Divider(
                height: 3,
              ),
              ListTile(
                leading: Icon(Icons.info,size: 32,),
                title: Text('关于',style: TextStyle(fontSize: 16),),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context){
                    return AboutPage();
                  }));
                },
              )
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
    );
  }
}

class MySc extends StatefulWidget
{
  _News content;
  MySc(_News thing) {
    content = thing;
  }
  @override
  State<StatefulWidget> createState() {
    return _SMySc();
  }

}

class _SMySc extends State<MySc>
{
  bool ff = false;
  InAppWebViewController webView; //pyz
  _launchURL(String url) async {
    //pyz
    //const url = 'https://flutter.dev';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
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
          actions: <Widget>[
            Container(
              width: 50,
              child: FlatButton(
                textColor: Colors.white,
                onPressed: () {
                  setState(() {ff = !ff;});
//                                setState(() {
//                                  if(fav)
//                                  {
//                                    fav = false;
//                                    print("To false;");
//                                  }
//                                  else {fav = true;
//                                  print("To true;");}
//                                });
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
        body: InAppWebView(
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
          onLoadStart:
              (InAppWebViewController controller, String url) {},
          onLoadStop:
              (InAppWebViewController controller, String url) {
            if (url.contains("jwc.scu.edu.cn")) {
              webView.evaluateJavascript(
                  source: PageRefactor.jwc);
            } else if (url.contains("xsc.scu.edu.cn")) {
              webView.evaluateJavascript(
                  source: PageRefactor.xgb);
            } else if (url.contains("tuanwei.scu.edu.cn")) {
              webView.evaluateJavascript(
                  source: PageRefactor.xtw);
            } else if (url.contains("cs.scu.edu.cn")) {
              webView.evaluateJavascript(
                  source: PageRefactor.jsjxy);
            }
          },
          onDownloadStart: (controller, url) async {
            print("onDownloadStart $url");
            if (url.contains("system/_content/download.jsp")) {
              _launchURL(widget.content.url);
            } else {
              final taskId = await FlutterDownloader.enqueue(
                url: url,
                savedDir:
                (await getExternalStorageDirectory()).path,
                showNotification: true,
                // show download progress in status bar (for Android)
                openFileFromNotification:
                true, // click on notification to open downloaded file (for Android)
              );
            }
          },
        ));
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



class _PageWidgetState extends State<_PageWidget> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  InAppWebViewController webView; //pyz
  int cct = 1;
  bool fav = false;
  _launchURL(String url) async {
    //pyz
    //const url = 'https://flutter.dev';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

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
    bool ff = fav;//pyz
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _refreshData,
      child: Scrollbar(
        child: ListView.builder(
          padding: kMaterialListPadding,
          itemCount: widget.page.list.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  String url = widget.page.list[index].url;
                  if (!url.startsWith("http")) {
                    url = widget.page.list[index].skpUrl;
                  }
                  return MySc(widget.page.list[index])
//                    Scaffold(
//                      appBar: AppBar(
//                        leading: FlatButton(
//                            textColor: Colors.white,
//                            child: Icon(
//                              Icons.keyboard_arrow_left,
//                              color: Colors.white,
//                              //size: 33,
//                            ),
//                            onPressed: () {
//                              Navigator.pop(context);
//                            }),
//                        actions: <Widget>[
//                          Container(
//                            width: 50,
//                            child: FlatButton(
//                              textColor: Colors.white,
//                              onPressed: () {
//                                setState(() {ff = !ff;});
////                                setState(() {
////                                  if(fav)
////                                  {
////                                    fav = false;
////                                    print("To false;");
////                                  }
////                                  else {fav = true;
////                                  print("To true;");}
////                                });
//                              },
//                              child: Icon(
//                                ff ? Icons.star : Icons.star_border,
//                                color: Colors.white,
//                                //size: 33,
//                              ),
//                            ),
//                          ),
//                          Container(
//                            width: 50,
//                            child: FlatButton(
//                              textColor: Colors.white,
//                              onPressed: () {
//                                Share.share(widget.page.list[index].source +
//                                    "：" +
//                                    widget.page.list[index].title +
//                                    "\n" +
//                                    url);
//                              },
//                              child: Icon(
//                                Icons.share,
//                                color: Colors.white,
//                                //size: 33,
//                              ),
//                            ),
//                          )
//                        ],
//                        //new Icon(Icons.keyboard_arrow_left,size: 33,),
//                        title: Text("详情"),
//                        backgroundColor: Color.fromARGB(255, 119, 136, 213),
//                        //设置appbar背景颜色
//                        centerTitle: true, //设置标题是否局中
//                      ),
//                      body: InAppWebView(
//                        initialUrl: url,
//                        initialHeaders: {},
//                        initialOptions: InAppWebViewGroupOptions(
//                          crossPlatform: InAppWebViewOptions(
//                            debuggingEnabled: true,
//                            useOnDownloadStart: true,
//                          ),
//                          android: AndroidInAppWebViewOptions(
//                            loadWithOverviewMode: false,
//                          ),
//                        ),
//                        onWebViewCreated: (InAppWebViewController controller) {
//                          webView = controller;
//                        },
//                        onLoadStart:
//                            (InAppWebViewController controller, String url) {},
//                        onLoadStop:
//                            (InAppWebViewController controller, String url) {
//                          if (url.contains("jwc.scu.edu.cn")) {
//                            webView.evaluateJavascript(
//                                source: PageRefactor.jwc);
//                          } else if (url.contains("xsc.scu.edu.cn")) {
//                            webView.evaluateJavascript(
//                                source: PageRefactor.xgb);
//                          } else if (url.contains("tuanwei.scu.edu.cn")) {
//                            webView.evaluateJavascript(
//                                source: PageRefactor.xtw);
//                          } else if (url.contains("cs.scu.edu.cn")) {
//                            webView.evaluateJavascript(
//                                source: PageRefactor.jsjxy);
//                          }
//                        },
//                        onDownloadStart: (controller, url) async {
//                          print("onDownloadStart $url");
//                          if (url.contains("system/_content/download.jsp")) {
//                            _launchURL(url);
//                          } else {
//                            final taskId = await FlutterDownloader.enqueue(
//                              url: url,
//                              savedDir:
//                                  (await getExternalStorageDirectory()).path,
//                              showNotification: true,
//                              // show download progress in status bar (for Android)
//                              openFileFromNotification:
//                                  true, // click on notification to open downloaded file (for Android)
//                            );
//                          }
//                        },
//                      ))
                  ;
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
                          child: Image.network(
                            widget.page.list[index].image,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
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
//                                      Text(
//                                        widget.page.list[index].digest,
//                                        style: TextStyle(
//                                            color: Colors.black87,
//                                            fontSize: 10.0),
//                                      ),
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
//                    Expanded(
//                      child: Divider(),
//                    )
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
