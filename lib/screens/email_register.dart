import 'package:flutter/material.dart';
import 'package:mytodo/config/config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mytodo/screens/loginScree.dart';

class EmailPassSignup extends StatefulWidget {
  @override
  _EmailPassSignupState createState() => _EmailPassSignupState();
}

class _EmailPassSignupState extends State<EmailPassSignup> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confpasswordController = TextEditingController();

  void signup() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseFirestore db = FirebaseFirestore.instance;
    final String email = emailController.text.trim();
    final String password = passwordController.text;
    final String confpassword = confpasswordController.text;
    if (password == confpassword) {
      if (email.isNotEmpty && password.isNotEmpty) {
        try {
          final UserCredential user = await auth.createUserWithEmailAndPassword(
              email: email, password: password);
          // ignore: unused_local_variable
          await db.collection("users").doc(user.user.uid).set({
            "email": email,
            "lastseen": DateTime.now(),
            // "signin_method": user.user.providerData
          });
          print("data saved succefully");
          showDialog(
              context: context,
              builder: (ctx) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  title: Text("Congratulations"),
                  content: Text("SIgn up Successfull, please login"),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginScreen()));
                        },
                        child: Text("OK"))
                  ],
                );
              });
        } catch (e) {
          showDialog(
              context: context,
              builder: (ctx) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  title: Text("Error"),
                  content: Text(e.message),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text("OK"))
                  ],
                );
              });
        }
      } else {
        showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                title: Text("Error"),
                content: Text("Please enter email and password"),
                actions: [
                  TextButton(
                    onPressed: () {
                      emailController.text = "";
                      passwordController.text = "";
                      confpasswordController.text = "";
                      Navigator.of(ctx).pop();
                    },
                    child: Text("OK"),
                  )
                ],
              );
            });
      }
    } else {
      showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Text("Error"),
              content: Text("Password is not matching"),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(ctx).pop(), child: Text("OK"))
              ],
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text("Email Signup"),
          backgroundColor: primaryColor,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 80),
                  decoration: BoxDecoration(boxShadow: [
                    BoxShadow(
                      color: Color(0x4400F58D),
                      blurRadius: 30,
                      offset: Offset(10, 10),
                      spreadRadius: 0,
                    )
                  ]),
                  child: Image(
                    image: AssetImage(
                      "assets/logo_round.png",
                    ),
                    width: 200,
                    height: 200,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 30),
                  child: Text(
                    "Signup",
                    style: TextStyle(
                      fontSize: 30,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.only(top: 30),
                  child: TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      hintText: "write email here",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.only(top: 20),
                  child: TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: "Password",
                      hintText: "write password here",
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.only(top: 20),
                  child: TextField(
                    controller: confpasswordController,
                    decoration: InputDecoration(
                      labelText: "Confirm Password",
                      hintText: "Rewrite password here",
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                ),
                InkWell(
                  onTap: () => signup(),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [primaryColor, secondaryColor]),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    margin: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    child: Center(
                      child: Text(
                        "Signup with email",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
