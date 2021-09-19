import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mytodo/config/config.dart';

class PhoneSignIn extends StatefulWidget {
  @override
  _PhoneSignInState createState() => _PhoneSignInState();
}

class _PhoneSignInState extends State<PhoneSignIn> {
  final TextEditingController phoneController = TextEditingController();
  TextEditingController otpController = TextEditingController();
  bool isSignedIn = false;
  bool otpSent = false;
  String uid;
  String _verificationId;

  void verifyOTP() async {
    //we know that _verificationId is not empty
    final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId, smsCode: otpController.text);

    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
      
      if (FirebaseAuth.instance.currentUser != null) {
        setState(() {
          isSignedIn = true;
          uid = FirebaseAuth.instance.currentUser.uid;
        });
      }
    } catch (e) {
      print(e.message);
    }
  }

  void phoneSign() async {
    FirebaseAuth auth = FirebaseAuth.instance;

    final phonenum = phoneController.text;

    await auth.verifyPhoneNumber(
        phoneNumber: phonenum,
        timeout: const Duration(seconds: 120),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);

    setState(() {
      otpSent = true;
    });
  }

  void codeAutoRetrievalTimeout(String verificationId) {
    setState(() {
      _verificationId = verificationId;
      otpSent = true;
    });
  }

  void codeSent(String verificationId, [int a]) async {
    setState(() {
      _verificationId = verificationId;
      otpSent = true;
    });
  }

  void verificationFailed(FirebaseAuthException e) {
    print(e.message);
    setState(() {
      isSignedIn = false;
      otpSent = false;
    });
  }

  void verificationCompleted(PhoneAuthCredential credential) async {
    await FirebaseAuth.instance.signInWithCredential(credential);

    //following lines before the "if" statement are for data base still not working
    // FirebaseAuth auth = FirebaseAuth.instance;
    // FirebaseFirestore db = FirebaseFirestore.instance;
    //     final phonenum = phoneController.text;

    // final ConfirmationResult user =
    //     await auth.signInWithPhoneNumber(phonenum);
    // await db.collection("users").doc(user.user.uid).set({
    //   "Phone": phonenum,
    //   "lastseen": DateTime.now(),
    //   // "signin_method": user.user.providerData
    // });

    if (FirebaseAuth.instance.currentUser != null) {
      setState(() {
        isSignedIn = true;
        uid = FirebaseAuth.instance.currentUser.uid;
      });
    } else {
      print("not varified");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Phone Sign in"),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.only(bottom: 20, left: 10, right: 10, top: 50),
        child: isSignedIn
            ? Center(
                child: Text("Welcom user \n Your uid is $uid"),
              )
            : otpSent
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextField(
                        controller: otpController,
                        decoration: InputDecoration(
                            hintText: "Enter OTP",
                            border: OutlineInputBorder()),
                      ),
                      InkWell(
                        onTap: () {
                          verifyOTP();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [primaryColor, secondaryColor]),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 20),
                          margin: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 20),
                          child: Center(
                            child: Text(
                              "Sign In",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextField(
                        controller: phoneController,
                        decoration: InputDecoration(
                            labelText: "Phone Number",
                            hintText: "Write phone number here",
                            border: OutlineInputBorder()),
                      ),
                      InkWell(
                        onTap: () {
                          phoneSign();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [primaryColor, secondaryColor]),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 20),
                          margin: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 20),
                          child: Center(
                            child: Text(
                              "Send OTP",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
