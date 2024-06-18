import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../resources/firestore_methods.dart';
import '../resources/storage_methods.dart';
import '../utils/colors.dart';
import '../utils/utils.dart';

class EditProfileScreen extends StatefulWidget {
  final String uid;

  const EditProfileScreen({super.key, required this.uid});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  var userData = {};
  bool isLoading = false;
  TextEditingController fullNameController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController pronounController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController linkController = TextEditingController();
  File? pickedImage;

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();
      userData = userSnap.data()!;
      setState(() {
        isLoading = false;
        fullNameController.text = userData['fullName'];
        userNameController.text = userData['username'];
        pronounController.text = userData['pronoun'];
        bioController.text = userData['bio'];
        linkController.text = userData['link'];
      });
    } catch (e) {
      if (mounted) {
        showSnackBar(
          context,
          e.toString(),
        );
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  void pickedImageDialog() {
    showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        content: const Text('Choose image source'),
        actions: [
          ElevatedButton(
            child: const Text('Camera'),
            onPressed: () => Navigator.pop(context, ImageSource.camera),
          ),
          ElevatedButton(
            child: const Text('Gallery'),
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
          ),
        ],
      ),
    ).then((ImageSource? source) async {
      if (source == null) return;

      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile == null) return;

      setState(() => pickedImage = File(pickedFile.path));
      if (pickedImage != null) {
        setState(() {
          isLoading = true;
        });
        Uint8List file = pickedImage!.readAsBytesSync();
        String photoUrl = await StorageMethods()
            .uploadImageToStorage('profilePics', file, false);
        updatePhotoUser(photoUrl);
      }
    });
  }

  void updatePhotoUser(String photoUrl) async {
    String res = await FireStoreMethods().updatePhotoProfile(
      widget.uid,
      photoUrl,
    );
    if (res == 'success') {
      if (mounted) {
        getData();
        if (mounted) {
          showSnackBar(context, res);
        }
      }
    } else {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        showSnackBar(context, res);
      }
    }
  }

  void updateUser() async {
    setState(() {
      isLoading = true;
    });
    String res = await FireStoreMethods().updateProfile(
      widget.uid,
      fullNameController.text,
      userNameController.text,
      pronounController.text,
      bioController.text,
      linkController.text,
    );
    if (res == 'success') {
      if (mounted) {
        getData();
        if (mounted) {
          showSnackBar(context, res);
        }
      }
    } else {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        showSnackBar(context, res);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              title: const Text(
                'Edit Profile',
              ),
              centerTitle: false,
            ),
            body: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey,
                            backgroundImage: NetworkImage(
                              userData['photoUrl'],
                            ),
                            radius: 65,
                          ),
                          Positioned(
                            bottom: 0,
                            right: -25,
                            child: RawMaterialButton(
                              onPressed: () => pickedImageDialog(),
                              elevation: 2.0,
                              fillColor: const Color.fromARGB(255, 0, 0, 0),
                              padding: const EdgeInsets.all(8),
                              shape: const CircleBorder(),
                              child: const Icon(
                                Icons.camera_alt_outlined,
                                color: Colors.blue,
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 25),
                      TextField(
                        controller: fullNameController,
                        decoration: const InputDecoration(
                          label: Text('Name'),
                        ),
                      ),
                      TextField(
                        controller: userNameController,
                        decoration: const InputDecoration(
                          label: Text('Username'),
                        ),
                      ),
                      TextField(
                        controller: pronounController,
                        decoration: const InputDecoration(
                          label: Text('Pronoun'),
                        ),
                      ),
                      TextField(
                        controller: bioController,
                        decoration: const InputDecoration(
                          label: Text('Bio'),
                        ),
                      ),
                      TextField(
                        controller: linkController,
                        decoration: const InputDecoration(
                          label: Text('Link'),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: InkWell(
                    onTap: () => updateUser(),
                    child: Container(
                      width: double.infinity,
                      height: 45,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: const ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                        color: blueColor,
                      ),
                      child: const Text(
                        'Update',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
