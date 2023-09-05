import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/resources/auth_methods.dart';
import 'package:instagram_clone/resources/firestore_methods.dart';
import 'package:instagram_clone/screens/login_screen.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:instagram_clone/widgets/follow_button.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  const ProfileScreen({super.key, required this.uid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var userData = {};
  int postLen = 0, followers = 0, following = 0;
  bool isFollowing = false;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    setState(() {
      // print('setstate called');
      isLoading = true;
    });
    try {
      print(widget.uid);
      var userSnap = await FirebaseFirestore.instance.collection('users').doc(widget.uid).get();
      var postSnap = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: widget.uid)
          .get();
      postLen = postSnap.docs.length;
      followers = userSnap.data()!['followers'].length;
      following = userSnap.data()!['following'].length;
      isFollowing = userSnap.data()!['followers'].contains(FirebaseAuth.instance.currentUser!.uid);
      userData = userSnap.data()!;
      setState(() {});
    } catch (e) {
      if (context.mounted) {
        showSnackBar(e.toString(), context);
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String usernameCapitalized = userData['username'] ?? '';
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: mobileBackgroundcolor,
              title: Text(
                userData['username'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              centerTitle: false,
            ),
            body: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 30),
                            child: CircleAvatar(
                              backgroundColor: secondaryColor,
                              backgroundImage: NetworkImage(userData['photoURL'] ?? ''),
                              radius: 50,
                            ),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                buildStatColumn(postLen, "Posts"),
                                buildStatColumn(followers, "Followers"),
                                buildStatColumn(following, "Following"),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(top: 15, left: 10),
                        child: Text(
                          usernameCapitalized[0].toUpperCase() + usernameCapitalized.substring(1),
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(top: 4, left: 10),
                        child: Text(
                          userData['bio'] ?? '',
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: FirebaseAuth.instance.currentUser!.uid == widget.uid
                                ? FollowButton(
                                    backgroundColor: greyColor,
                                    borderColor: greyColor,
                                    text: 'Logout',
                                    textColor: primaryColor,
                                    customWidth: 400,
                                    function: () async {
                                      String res = await AuthMethods().signOut();
                                      if (res == "success" && context.mounted) {
                                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                                            builder: (context) => const LoginScreen()));

                                        showSnackBar('You are Logged out!', context);
                                      } else if (context.mounted) {
                                        showSnackBar(res, context);
                                      }
                                    },
                                  )
                                : isFollowing
                                    ? FollowButton(
                                        backgroundColor: greyColor,
                                        borderColor: greyColor,
                                        text: 'Unfollow',
                                        textColor: primaryColor,
                                        customWidth: 400,
                                        function: () async {
                                          await FireStoreMethods().followUser(
                                            FirebaseAuth.instance.currentUser!.uid,
                                            userData['uid'],
                                          );
                                          setState(() {
                                            isFollowing = false;
                                            followers--;
                                          });
                                        },
                                      )
                                    : FollowButton(
                                        backgroundColor: Colors.blueAccent.shade700,
                                        borderColor: Colors.blueAccent.shade700,
                                        text: 'Follow',
                                        textColor: primaryColor,
                                        customWidth: 400,
                                        function: () async {
                                          await FireStoreMethods().followUser(
                                            FirebaseAuth.instance.currentUser!.uid,
                                            userData['uid'],
                                          );
                                          setState(() {
                                            isFollowing = true;
                                            followers++;
                                          });
                                        },
                                      ),
                          ),
                          Expanded(
                            child: FollowButton(
                              backgroundColor: greyColor,
                              borderColor: greyColor,
                              text: 'Share Profile',
                              textColor: primaryColor,
                              customWidth: 400,
                              function: () {},
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(),
                FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection('posts')
                      .where('uid', isEqualTo: widget.uid)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.docs.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 1.5,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context, index) {
                        DocumentSnapshot snap = snapshot.data!.docs[index];
                        return Image(
                          image: NetworkImage(snap['postURL']),
                          fit: BoxFit.cover,
                        );
                      },
                    );
                  },
                )
              ],
            ),
          );
  }

  Column buildStatColumn(int num, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          num.toString(),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: primaryColor),
        ),
      ],
    );
  }
}
