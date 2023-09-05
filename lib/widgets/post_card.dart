import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/models/user_model.dart';
import 'package:instagram_clone/provider/user_provider.dart';
import 'package:instagram_clone/resources/firestore_methods.dart';
import 'package:instagram_clone/screens/comment_screen.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:instagram_clone/widgets/like_animation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PostCard extends StatefulWidget {
  final Map<String, dynamic> snap;
  const PostCard({
    super.key,
    required this.snap,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLikeAnimating = false;
  int commentLength = 0;

  @override
  void initState() {
    super.initState();
    // print('initstate called ...........');
    getComments();
  }

  void getComments() async {
    try {
      QuerySnapshot commentSnap = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.snap['postId'])
          .collection('comments')
          .get();

      commentLength = commentSnap.docs.length;
    } catch (e) {
      // print(e.toString());
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    UserModel userModel = Provider.of<UserProvider>(context).getUser;
    return Container(
      color: mobileBackgroundcolor,
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      child: Column(
        children: [
          //HEADER SECTION

          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 4,
              horizontal: 16,
            ).copyWith(right: 0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(widget.snap['profImage']),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.snap['username'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shrinkWrap: true,
                          children: [
                            'Delete',
                            'Report',
                          ]
                              .map(
                                (e) => InkWell(
                                  child: Container(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                    child: Text(e),
                                  ),
                                  onTap: () async {
                                    if (e == 'Delete') {
                                      await FireStoreMethods().deletePost(widget.snap['postId']);
                                      if (context.mounted) {
                                        showSnackBar('Deleted', context);
                                        Navigator.of(context).pop();
                                      }
                                    }
                                  },
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.more_vert),
                ),
              ],
            ),
          ),

          //IMAGE SECTION

          GestureDetector(
            onDoubleTap: () async {
              await FireStoreMethods().likePost(
                widget.snap['postId'],
                userModel.uid,
                widget.snap['likes'],
              );
              setState(() {
                isLikeAnimating = true;
              });
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  width: double.infinity,
                  child: Image.network(
                    widget.snap['postURL'],
                    fit: BoxFit.cover,
                  ),
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isLikeAnimating ? 0.65 : 0,
                  child: LikeAnimation(
                    isAnimating: isLikeAnimating,
                    duration: const Duration(
                      milliseconds: 400,
                    ),
                    onEnd: () {
                      setState(() {
                        isLikeAnimating = false;
                      });
                    },
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 120,
                    ),
                  ),
                )
              ],
            ),
          ),

          //LIKE COMMENT SECTION
          Row(
            children: [
              LikeAnimation(
                isAnimating: widget.snap['likes'].contains(userModel.uid),
                smallLike: true,
                child: CupertinoButton(
                  onPressed: () async {
                    await FireStoreMethods().likePost(
                      widget.snap['postId'],
                      userModel.uid,
                      widget.snap['likes'],
                    );
                  },
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minSize: double.minPositive,
                  child: widget.snap['likes'].contains(userModel.uid)
                      ? const Icon(
                          Icons.favorite,
                          color: Colors.red,
                        )
                      : const Icon(
                          Icons.favorite_border_outlined,
                          color: primaryColor,
                        ),
                ),
              ),
              CupertinoButton(
                onPressed: () => Navigator.of(context)
                    .push(
                  MaterialPageRoute(
                    builder: (context) => CommentScreen(
                      snap: widget.snap,
                    ),
                  ),
                )
                    .then((context) {
                  setState(() {
                    getComments();
                  });
                }),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minSize: double.minPositive,
                child: const Icon(
                  Icons.mode_comment_outlined,
                  color: primaryColor,
                ),
              ),
              CupertinoButton(
                onPressed: () {},
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minSize: double.minPositive,
                child: const Icon(
                  Icons.send,
                  color: primaryColor,
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: IconButton(
                    iconSize: 26,
                    icon: const Icon(Icons.bookmark_outline),
                    onPressed: () {},
                  ),
                ),
              )
            ],
          ),

          //DESCRIPTION AND NUMBER OF COMMENTS
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultTextStyle(
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                  child: Text(
                    '${widget.snap['likes'].length} likes',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 8),
                  child: RichText(
                    text: TextSpan(style: const TextStyle(color: primaryColor), children: [
                      TextSpan(
                        text: '${widget.snap['username']}  ',
                        style: const TextStyle(fontWeight: FontWeight.w400),
                      ),
                      TextSpan(
                        text: widget.snap['description'],
                      ),
                    ]),
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.of(context)
                      .push(
                    MaterialPageRoute(
                      builder: (context) => CommentScreen(
                        snap: widget.snap,
                      ),
                    ),
                  )
                      .then((context) {
                    setState(() {
                      getComments();
                    });
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      'View all $commentLength comments',
                      style: const TextStyle(
                        color: secondaryColor,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    DateFormat.yMMMd().format(widget.snap['datePublished'].toDate()),
                    style: const TextStyle(color: secondaryColor, fontSize: 12),
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
