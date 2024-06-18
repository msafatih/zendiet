import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../resources/auth_methods.dart';
import '../screens/login_screen.dart';
import '../utils/colors.dart';
import '../utils/utils.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;

  const ProfileScreen({super.key, required this.uid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var userData = {};
  int postLen = 0;
  int followers = 0;
  int following = 0;
  int index = 0;
  bool isFollowing = false;
  bool isLoading = false;

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

      // get post lENGTH
      var postSnap = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();

      postLen = postSnap.docs.length;
      userData = userSnap.data()!;
      followers = userSnap.data()!['followers'].length;
      following = userSnap.data()!['following'].length;
      isFollowing = userSnap
          .data()!['followers']
          .contains(FirebaseAuth.instance.currentUser!.uid);
      setState(() {});
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
              actions: [
                PopupMenuButton<String>(
                  onSelected: (selected) async {
                    if (selected.toLowerCase() == 'edit profile') {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => EditProfileScreen(
                            uid: widget.uid,
                          ),
                        ),
                      );
                    } else {
                      await AuthMethods().signOut();
                      if (context.mounted) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      }
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return {'Edit Profile', 'Sign Out'}.map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Text(choice),
                      );
                    }).toList();
                  },
                ),
              ],
            ),
            body: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: Column(
                      children: [
                        Column(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.grey,
                              backgroundImage: NetworkImage(
                                userData['photoUrl'],
                              ),
                              radius: 65,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "@${userData['username']}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          userData['bio'],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            buildStatColumn(postLen, "Posts"),
                            buildStatColumn(followers, "Followers"),
                            buildStatColumn(following, "Following"),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  TabBar(
                    indicatorColor: Colors.white,
                    dividerColor: Colors.transparent,
                    onTap: (i) {
                      setState(() {
                        index = i;
                      });
                    },
                    tabs: [
                      Tab(
                        icon: Icon(
                          Icons.image,
                          color: index == 0 ? Colors.white : Colors.grey,
                          size: 32,
                        ),
                      ),
                      Tab(
                        icon: Icon(
                          Icons.bookmark,
                          color: index == 1 ? Colors.white : Colors.grey,
                          size: 32,
                        ),
                      )
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        ListView(
                          children: [
                            const SizedBox(height: 15),
                            FutureBuilder(
                              future: FirebaseFirestore.instance
                                  .collection('posts')
                                  .where('uid', isEqualTo: widget.uid)
                                  .get(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                return GridView.builder(
                                  shrinkWrap: true,
                                  itemCount:
                                      (snapshot.data! as dynamic).docs.length,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 5,
                                    mainAxisSpacing: 1.5,
                                    childAspectRatio: 1,
                                  ),
                                  itemBuilder: (context, index) {
                                    DocumentSnapshot snap =
                                        (snapshot.data! as dynamic).docs[index];

                                    return SizedBox(
                                      child: Image(
                                        image: NetworkImage(snap['postUrl']),
                                        fit: BoxFit.cover,
                                      ),
                                    );
                                  },
                                );
                              },
                            )
                          ],
                        ),
                        ListView(
                          children: [
                            const SizedBox(height: 15),
                            FutureBuilder(
                              future: FirebaseFirestore.instance
                                  .collection('posts')
                                  .get(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                List<DocumentSnapshot> postSavedUser = [];
                                List<DocumentSnapshot> postList =
                                    snapshot.data!.docs;
                                for (DocumentSnapshot docSnapshot in postList) {
                                  List<String> itemDetailList = (docSnapshot[
                                          'saved'] as List)
                                      .map((itemDetail) => itemDetail as String)
                                      .toList();
                                  for (String docSnapshotUser
                                      in itemDetailList) {
                                    if (docSnapshotUser == widget.uid) {
                                      postSavedUser.add(docSnapshot);
                                    }
                                  }
                                }

                                return GridView.builder(
                                  shrinkWrap: true,
                                  itemCount: postSavedUser.length,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 5,
                                    mainAxisSpacing: 1.5,
                                    childAspectRatio: 1,
                                  ),
                                  itemBuilder: (context, index) {
                                    var snapshotData = postSavedUser[index];
                                    return SizedBox(
                                      child: Image(
                                        image: NetworkImage(
                                            snapshotData['postUrl']),
                                        fit: BoxFit.cover,
                                      ),
                                    );
                                  },
                                );
                              },
                            )
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
  }

  Column buildStatColumn(int num, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: Colors.grey,
          ),
        ),
        Text(
          num.toString(),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        )
      ],
    );
  }
}
