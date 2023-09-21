import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sa_app/model/user.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  double screenHeight = 0;
  double screenWidth = 0;

  Color primary = const Color(0xffeef444c);
  String birth = "Date of birth";

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  void pickUploadProfilePic() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxHeight: 512,
      maxWidth: 512,
      imageQuality: 90,
    );

    Reference ref = FirebaseStorage.instance
        .ref()
        .child("${User.studentId.toLowerCase()}_profilepic.jpg");

    await ref.putFile(File(image!.path));

    ref.getDownloadURL().then((value) async {
      setState(() {
        User.profilePicLink = value;
      });
      await FirebaseFirestore.instance
          .collection("Student")
          .doc(User.id)
          .update({
        'profilePic': value,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                pickUploadProfilePic();
              },
              child: Container(
                margin: EdgeInsets.only(top: 80, bottom: 24),
                height: 120,
                width: 120,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: primary,
                ),
                child: Center(
                  child: User.profilePicLink == " "
                      ? const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 80,
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(User.profilePicLink)),
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                "Student ${User.studentId}",
                style: TextStyle(
                  fontFamily: "NexaBold",
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            User.canEdit
                ? textField("First Name", "First name", firstNameController)
                : field("First Name", User.firstname),
            User.canEdit
                ? textField("Last Name", "Last name", lastNameController)
                : field("Last Name", User.lastname),
            User.canEdit
                ? GestureDetector(
                    onTap: () {
                      showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1950),
                        lastDate: DateTime.now(),
                        builder: (context, child) {
                          return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                    primary: primary,
                                    secondary: primary,
                                    onSecondary: Colors.white),
                                textButtonTheme: TextButtonThemeData(
                                  style: TextButton.styleFrom(
                                    primary: primary,
                                  ),
                                ),
                                textTheme: const TextTheme(
                                    headline4: TextStyle(
                                      fontFamily: "NexaBold",
                                    ),
                                    overline: TextStyle(
                                      fontFamily: "NexaBold",
                                    ),
                                    button: TextStyle(
                                      fontFamily: "NexaBold",
                                    )),
                              ),
                              child: child!);
                        },
                      ).then((value) {
                        setState(() {
                          birth = DateFormat("dd/MM/yyyy").format(value!);
                        });
                      });
                    },
                    child: field("Date of Birth", birth),
                  )
                : field("Date of Birth", User.birthday),
            User.canEdit
                ? textField("Address", "Address", addressController)
                : field("Address", User.address),
            User.canEdit
                ? GestureDetector(
                    onTap: () async {
                      String firstName = firstNameController.text;
                      String lastName = lastNameController.text;
                      String birthDate = birth;
                      String address = addressController.text;

                      if (User.canEdit) {
                        if (firstName.isEmpty) {
                          showSnankBar("Please enter your first name!");
                        } else if (lastName.isEmpty) {
                          showSnankBar("Please enter your last name!");
                        } else if (birthDate.isEmpty) {
                          showSnankBar("Please enter your birthdate!");
                        } else if (address.isEmpty) {
                          showSnankBar("Please enter your address!");
                        } else {
                          await FirebaseFirestore.instance
                              .collection("Student")
                              .doc(User.id)
                              .update({
                            'firstName': firstName,
                            'lastName': lastName,
                            'birthDate': birthDate,
                            'address': address,
                            'canEdit': false,
                          }).then((value) {
                            setState(() {
                              User.canEdit = false;
                              User.firstname = firstName;
                              User.lastname = lastName;
                              User.birthday = birthDate;
                              User.address = address;
                            });
                          });
                        }
                      } else {
                        showSnankBar(
                            "You can\'t edit anymore, please contact support team.");
                      }
                    },
                    child: Container(
                      height: kToolbarHeight,
                      width: screenWidth,
                      margin: EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: primary),
                      child: Center(
                        child: Text(
                          "SAVE",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: "NexaBold",
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }

  Widget field(String title, String text) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: TextStyle(
              fontFamily: "NexaBold",
              color: Colors.black54,
            ),
          ),
        ),
        Container(
          height: kToolbarHeight,
          width: screenWidth,
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.only(left: 11),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: Colors.black,
              )),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              text,
              style: TextStyle(
                color: Colors.black54,
                fontFamily: "NexaBold",
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget textField(
      String title, String hint, TextEditingController controller) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: TextStyle(
              fontFamily: "NexaBold",
              color: Colors.black54,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(bottom: 12),
          child: TextFormField(
            controller: controller,
            cursorColor: Colors.black54,
            maxLines: 1,
            decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: Colors.black54,
                  fontFamily: "NexaBold",
                ),
                enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black54))),
          ),
        ),
      ],
    );
  }

  void showSnankBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          text,
        )));
  }
}
