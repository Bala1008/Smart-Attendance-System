import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:attendance/screens/screens.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
//import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart'; 

class AllClass extends StatefulWidget {
  final String email;
  AllClass(this.email);
  @override
  _AllClassState createState() => _AllClassState();
}

class ClassScreen extends StatefulWidget {
  final String _className, _studentsCount, userEmail;
  ClassScreen(this._className, this._studentsCount, this.userEmail);
  @override
  _ClassScreenState createState() => _ClassScreenState();
}

class _ClassScreenState extends State<ClassScreen> {
  List studentsList;
  String fileURL, resultPath;
  bool downloading = false;
  var progressString = "";

  sendMail(String fileURL) async{
    print('File URL is' + fileURL);
    String username = "testrfc29@gmail.com";
    String password = "Test@123";
    final smtpServer = gmail(username, password);
    final message = Message()
      ..from = Address(username) 
      ..recipients.add(widget.userEmail)
      ..subject = 'Download Attendance - Smart Attendance Tracker :: ${DateTime.now()}'
      ..text = 'DOWNLOAD LINK \n' + fileURL;
     try{
       final sendReport = await send(message, smtpServer);
       print('MessageSent');
     } on MailerException catch (e){
       print('MessageNotSent \n' + e.toString());
     }
      

  }

  Future<bool> loader() async {
    downloadFile();
    return (downloading)
        ? showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: ScalingText("Downloading..."),
            ),
          )
        : Text("Complete");
  }

  Future<void> downloadFile() async {
    Dio dio = Dio();
    try {
      var dir = await getApplicationSupportDirectory();
      await dio.download(
        fileURL,
        "${dir.path}/${resultPath}",
        onReceiveProgress: (count, total) {
          print("Rec: $count, Total: $total");
          setState(() {
            downloading = true;
            // progressString = ((count / total) * 100).toStringAsFixed(0) + "%";
          });
        },
      );
      print("hello+ ${dir.path}");
    } catch (e) {
      print(e);
    }
    setState(() {
      downloading = false;
      progressString = "Completed";
    });
    print("Download Completed");
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => BottomNavScreen(widget.userEmail)));
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color(0xFF3383CD),
                Color(0xFF11249F),
              ],
            ),
            image: DecorationImage(
              image: AssetImage(
                "assets/images/person.png",
              ),
              alignment: Alignment.topRight,
            ),
          ),
          child: Column(
            children: <Widget>[
              SizedBox(height: 230),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(30),
                        topLeft: Radius.circular(30)),
                    color: Colors.white,
                  ),
                  child: Stack(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(30),
                        child: ListView(
                          shrinkWrap: true,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(top: 7),
                                            child: Text(
                                                trimName(widget._className, 20),
                                                style: kHeadingextStyle),
                                          ),
                                        ],
                                      ),
                                    ),
                                    InkWell(

                                      onTap: () async {
                                        resultPath =
                                            '${widget.userEmail.split('@')[0]}_${widget._className}.csv';
                                        StorageReference storageReference =
                                            FirebaseStorage.instance
                                                .ref()
                                                .child('result/${resultPath}');
                                        storageReference
                                            .getDownloadURL()
                                            .then((fileurl) {
                                          setState(() {
                                            fileURL = fileurl;
                                          });
                                          
                                          sendMail(fileURL);
                                        });
                                        // loader();
                                        // await http.get(fileURL);
                                        // final taskId =
                                        //     await FlutterDownloader.enqueue(
                                        //   url: fileURL,
                                        //   savedDir: '/Downloads',
                                        //   showNotification: true,
                                        //   openFileFromNotification: true,
                                        // );
                                      },

                                      child: Expanded(
                                      flex: 1,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children:[ Container(
                                          decoration: BoxDecoration(           
                                            color: Color(0xFF11249F).withOpacity(.85),
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(10),
                                            child:Row(
                                              children: [
                                                Icon(Icons.file_download, color: Colors.white),
                                                SizedBox(width: 3),
                                                Text("Download", style: kTitleTextStyle.copyWith(color: Colors.white, fontWeight: FontWeight.normal, fontSize: 17)),
                                              ],

                                            ),),),
                                          ],
                                        ),
                                      ),
                                    
                                    ),
                                  ],
                                ),
                                SizedBox(height: 35),
                                StreamBuilder(
                                  stream: FirebaseFirestore.instance
                                      .collection('Staff')
                                      .doc(widget.userEmail)
                                      .collection('Classrooms')
                                      .doc(widget._className)
                                      .snapshots(),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<DocumentSnapshot>
                                          snapshot) {
                                    if (!snapshot.hasData)
                                      return CircularProgressIndicator();
                                    studentsList =
                                        snapshot.data.data()['students'];
                                    return StudentBuilder(snapshot.data.data());
                                  },
                                ),
                                SizedBox(height: 60),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 0,
                        left: 0,
                        bottom: 0,
                        child: Container(
                          padding: EdgeInsets.all(20),
                          height: 80,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(30),
                                  topLeft: Radius.circular(30)),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 50,
                                  offset: Offset(0, 4),
                                  color: kTextColor.withOpacity(.1),
                                ),
                              ]),
                          child: Row(
                            children: <Widget>[
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => AddUserClass(
                                            "Student", widget._className)),
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  height: 56,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    color: Color(0xFFD0D0D0),
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                  child: SvgPicture.asset(
                                    "assets/icons/profile.svg",
                                    color: Color(0xFF11249F),
                                  ),
                                ),
                              ),
                              SizedBox(width: 20),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => CaptureImage(
                                              widget.userEmail,
                                              widget._className,
                                              studentsList)),
                                    );
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(40),
                                      gradient: LinearGradient(
                                        begin: Alignment.topRight,
                                        end: Alignment.bottomLeft,
                                        colors: [
                                          Color(0xFF3383CD),
                                          Color(0xFF11249F),
                                        ],
                                      ),
                                    ),
                                    child: Text(
                                      "Take Attendance",
                                      style: kSubtitleTextSyule.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String trimName(String name, int x) {
  if (name.length <= x) {
    return name;
  } else
    return name.substring(0, x - 3) + "...";
}

class StudentBuilder extends StatelessWidget {
  final Map<String, dynamic> docData;
  StudentBuilder(this.docData);
  @override
  Widget build(BuildContext context) {
    if(docData['students'].length == 0){
      return Container(
          child: Column(
          children: [
            SizedBox(height: 30),
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                  children:[ 
                    Text(
                        "New Class Created.",
                        style:
                            kSubheadingextStyle.copyWith(fontFamily: 'Heading', fontWeight: FontWeight.normal),
                     ),
                    Text(
                        "Add Students to the class.",
                        style:
                            kSubheadingextStyle.copyWith(fontFamily: 'Heading', fontWeight: FontWeight.normal),
                     ),
                  ],
              ),
            ),
          ],),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 50000),
          child: ListView.builder(
            shrinkWrap: true,
            physics: ScrollPhysics(),
            itemCount: docData['students'].length,
            itemBuilder: (context, index) {
              // return Padding(padding: EdgeInsets.all(20), child: Text("Cool"));
              return Padding(
                padding: EdgeInsets.all(10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      ((index + 1 < 10) ? "0" : "") + (index + 1).toString(),
                      style: kHeadingextStyle.copyWith(
                          color: kTextColor.withOpacity(.15)),
                    ),
                    SizedBox(width: 30),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: trimName(docData['students'][index], 25),
                            style: kSubtitleTextSyule.copyWith(
                              fontWeight: FontWeight.w600,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class Students extends StatelessWidget {
  final String numBer;
  final String rollNo;
  final String name;
  const Students({
    Key key,
    this.numBer,
    this.rollNo,
    this.name,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            numBer,
            style:
                kHeadingextStyle.copyWith(color: kTextColor.withOpacity(.15)),
          ),
          SizedBox(width: 30),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: name,
                  style: kSubtitleTextSyule.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AllClassState extends State<AllClass> {
  @override
  void initState() {
    print(widget.email);
    super.initState();
  }

  // DocumentReference ins = FirebaseFirestore.instance
  //     .collection('Staff')
  //     .doc(getData())
  //     .collection('Classrooms')
  //     .get();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(left: 20, top: 20, right: 20),
        child: Column(
          children: <Widget>[
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("Classes",
                    style: kHeadingextStyle.copyWith(
                      fontFamily: 'Heading',
                      fontSize: 35,
                    )),
              ],
            ),

            // SizedBox(height: 10),

            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('Staff')
                  .doc(widget.email)
                  .collection('Classrooms')
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                return Sview(
                    documents: snapshot.data.docs, uEmail: widget.email);
              },
            ),
          ],
        ),
      ),
    );
  }
}

final List TileImage = [
  "assets/images/LightRed.png",
  "assets/images/LightViolet.png",
  "assets/images/LightOrange.png",
  "assets/images/LightYellow.png",
  "assets/images/LightPink.png",
];

class Sview extends StatelessWidget {
  final List<DocumentSnapshot> documents;
  final String uEmail;
  Sview({this.documents, this.uEmail});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    if(documents.length == 0) { return Expanded(
      child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: size.height * 0.1),
              Container(
                width: size.width,
                height: size.height * 0.3,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                    Container(
                      width: size.width,
                      height: size.height * 0.3,
                      decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                          "assets/images/presentation.png"
                        ),
                      ),
                      ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.1),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children:[
                  Text(
                  "You have no class to show.",
                  style:
                      kSubheadingextStyle.copyWith(fontFamily: 'Heading', fontWeight: FontWeight.normal),
                ),
                  Text(
                  "Create a class.",
                  style:
                      kSubheadingextStyle.copyWith(fontFamily: 'Heading', fontWeight: FontWeight.normal),
                ),                
              ],
              ),
              
            ],
      ),
    );
    }
    return Expanded(
      child: StaggeredGridView.countBuilder(
        crossAxisCount: 2,
        itemCount: documents.length,
        crossAxisSpacing: 15,
        mainAxisSpacing: 10,
        itemBuilder: (context, index) {
          String name = documents[index].get('name');
          //String number = documents[index].get('number').toString();
          return Material(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ClassScreen(name, 0.toString(), uEmail)),
                );
              },
              child: Container(
                padding: EdgeInsets.all(20),
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: AssetImage(TileImage[index % 5]),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Container(
                        child: Text(/*newList[index].name*/ trimName(name, 17),
                            style: kSubheadingextStyle.copyWith(
                                color: Colors.black)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        staggeredTileBuilder: (index) => StaggeredTile.fit(1),
      ),
    );
  }
}

////////////////////////////////////////
