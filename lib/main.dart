import 'package:flutter/material.dart';
import 'package:attendance/screens/screens.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:attendance/screens/bottom_nav_bar.dart';
import 'package:attendance/backend.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:flutter_downloader/flutter_downloader.dart';

//Suriya
// void main() => runApp(MyApp());
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // WidgetsFlutterBinding.ensureInitialized();
  // FlutterDownloader.initialize(debug: true);
  SharedPreferences preferences = await SharedPreferences.getInstance();
  String ex = preferences.getString('email');
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ex == null ? MyApp() : BottomNavScreen(ex),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance Recorder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: WelcomeScreen(),
    );
  }
}
// void main() => runApp(MyApp());

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(home: HttpClass());
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: HomePage(),
//     );
//   }
// }

// class HomePage extends StatefulWidget {
//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   String name = ""; //user's response will be assigned to this variable
//   String final_response =
//       ""; //will be displayed on the screen once we get the data from the server
//   File _image;
//   final _formkey =
//       GlobalKey<FormState>(); //key created to interact with the form

//   //function to validate and save user form
//   Future<void> _savingData() async {
//     final validation = _formkey.currentState.validate();
//     if (!validation) {
//       return;
//     }
//     _formkey.currentState.save();
//   }

//   //function to add border and rounded edges to our form
//   OutlineInputBorder _inputformdeco() {
//     return OutlineInputBorder(
//       borderRadius: BorderRadius.circular(20.0),
//       borderSide:
//           BorderSide(width: 1.0, color: Colors.blue, style: BorderStyle.solid),
//     );
//   }

//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         width: double.infinity,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             SizedBox(height: 200),
//             Container(
//               width: 350,
//               child: Form(
//                 key: _formkey,
//                 child: TextFormField(
//                   decoration: InputDecoration(
//                     labelText: 'Enter your name: ',
//                     enabledBorder: _inputformdeco(),
//                     focusedBorder: _inputformdeco(),
//                   ),
//                   onSaved: (value) {
//                     name =
//                         value; //getting data from the user form and assigning it to name
//                   },
//                 ),
//               ),
//             ),

//             FlatButton(
//               onPressed: () async {
//                 //validating the form and saving it
//                 _savingData();

//                 //url to send the post request to
//                 final url = 'http://192.168.43.11:5000/name';

//                 //sending a post request to the url
//                 final response =
//                     await http.post(url, body: json.encode({'name': name}));
//               },
//               child: Text('SEND'),
//               color: Colors.blue,
//             ),

//             FlatButton(
//               onPressed: () async {
//                 //url to send the get request to
//                 final image =
//                     await ImagePicker.pickImage(source: ImageSource.gallery);
//                 setState(() => [
//                       _image = image,
//                     ]);

//                 final url = 'http://192.168.43.11:5000/name';

//                 //getting data from the python server script and assigning it to response
//                 final response = await http.get(url);

//                 //converting the fetched data from json to key value pair that can be displayed on the screen
//                 final decoded =
//                     json.decode(response.body) as Map<String, dynamic>;

//                 //changing the UI be reassigning the fetched data to final response
//                 setState(() {
//                   final_response = decoded['name'];
//                 });
//               },
//               child: Text('GET'),
//               color: Colors.lightBlue,
//             ),

//             //displays the data on the screen
//             Text(
//               final_response,
//               style: TextStyle(fontSize: 24),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
