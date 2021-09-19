import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mytodo/config/config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mytodo/screens/email_register.dart';
import 'package:mytodo/screens/homeScreen.dart';
import 'package:mytodo/screens/phoneSign.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void login() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseFirestore db = FirebaseFirestore.instance;
    final String email = emailController.text.trim();
    final String password = passwordController.text;

    if (email.isNotEmpty && password.isNotEmpty) {
      try {
        final UserCredential user = await auth.signInWithEmailAndPassword(
            email: email, password: password);

        final DocumentSnapshot snapshot =
            await db.collection("users").doc(user.user.uid).get();
        final data = snapshot.data();
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
        print("Login successful");
        print(data["email"]);
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
                      onPressed: () {
                        emailController.text = "";
                        passwordController.text = "";
                        Navigator.of(ctx).pop();
                      },
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
                      Navigator.of(context).pop();
                    },
                    child: Text("OK"))
              ],
            );
          });
    }
  }

  //google sign in

  void signinUsingGoogle() async {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    final googlesignin = GoogleSignIn();
    final signInAcount = await googlesignin.signIn();

    final googleAccountAuthentication = await signInAcount.authentication;

    final credential = GoogleAuthProvider.credential(
        accessToken: googleAccountAuthentication.accessToken,
        idToken: googleAccountAuthentication.idToken);

    final user =
        (await FirebaseAuth.instance.signInWithCredential(credential)).user;
    try {
      print("login sucessfule,${user.displayName}");
      if (user != null) {
        db.collection("users").doc(user.uid).set({
          "displayName": user.displayName,
          "email": user.email,
          "photoURL": user.photoURL,
          "lastseen": DateTime.now(),
          "signin_methode": user.providerData
        });
      }
    } catch (e) {
      print("error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  "My Todo",
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
              InkWell(
                onTap: () async{
                  // ignore: await_only_futures
                  await login();
                  emailController.text = "";
                  passwordController.text = "";
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient:
                        LinearGradient(colors: [primaryColor, secondaryColor]),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  margin: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  child: Center(
                    child: Text(
                      "Login with email",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
              ),
              TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EmailPassSignup()));
                  },
                  child: Text(
                    "Signup using email",
                  )),
              Container(
                child: Wrap(
                  children: [
                    TextButton.icon(
                        onPressed: signinUsingGoogle,
                        icon: Icon(
                          FontAwesomeIcons.google,
                          color: Colors.red,
                        ),
                        label: Text(
                          "Signin with google",
                          style: TextStyle(color: Colors.red),
                        )),
                    SizedBox(
                      width: 20,
                    ),
                    TextButton.icon(
                        icon: Icon(
                          Icons.phone,
                          color: Colors.blue,
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PhoneSignIn()));
                        },
                        label: Text("Signin with phone")),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
