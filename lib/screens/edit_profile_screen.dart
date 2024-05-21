import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
                style: TextStyle(fontSize: 16),
              ),
              centerTitle: false,
            ),
            body: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.grey,
                        backgroundImage: NetworkImage(
                          userData['photoUrl'],
                        ),
                        radius: 40,
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
                )
              ],
            ),
          );
  }
}
