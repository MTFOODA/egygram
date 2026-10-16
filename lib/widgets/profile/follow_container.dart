import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/logics/follow/create_follow_logic/cubit.dart';
import 'package:flutter_application_3/widgets/helpers/follow_helper.dart';
import 'package:provider/provider.dart';
import '../../core/di/service_locator.dart';
import '../../logics/follow/get_follow_logic/cubit.dart';
import '../../models/user_model.dart';
import '../../utilities/fonts_dart.dart';
import '../../utilities/theme_provider.dart';

class FollowContainer extends StatefulWidget {
  final String currentUser;
  final UsersModel passedUser;

  const FollowContainer(
      {super.key, required this.currentUser, required this.passedUser});

  @override
  FollowContainerState createState() => FollowContainerState();
}

class FollowContainerState extends State<FollowContainer> {
  bool isFollowed = false;
  late UsersModel user;

  @override
  void initState() {
    super.initState();
    user = widget.passedUser;

    // Refresh the follower count from Supabase (keeps the UI in sync with the
    // server-side counter maintained by the repository RPCs).
    sl.userRepository.getUserByName(user.userName).then((fresh) {
      if (fresh != null && mounted) {
        setState(() {
          widget.passedUser.numberOfFollowers = fresh.numberOfFollowers;
        });
      }
    }).catchError((_) {
      // Best-effort: keep whatever count we were given.
    });

    // Fetch follow status
    context
        .read<GetFollowCubit>()
        .getFollowStatus(user.userName, widget.currentUser)
        .then((status) {
      if (mounted) {
        setState(() {
          isFollowed = status;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFollowed ? Colors.grey : Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      isFollowed = !isFollowed;
                      widget.passedUser.numberOfFollowers +=
                          isFollowed ? 1 : -1;
                    });

                    toggleFollow(
                      userFollowed: user.userName,
                      currentUser: widget.currentUser,
                      isFollowed: isFollowed,
                      follows: widget.passedUser.numberOfFollowers,
                      createFollowCubit: context.read<CreateFollowCubit>(),
                    );
                  },
                  child: Text(isFollowed ? 'Unfollow'.tr() : 'Follow'.tr(),
                      style: isDarkMode
                          ? AppFonts.textW16bold
                          : AppFonts.textB16bold),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, elevation: 0),
                  onPressed: () {},
                  child: Text('Message'.tr(),
                      style: isDarkMode
                          ? AppFonts.textW16bold
                          : AppFonts.textB16bold),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, elevation: 0),
                  onPressed: () {},
                  child: Text('Contact'.tr(),
                      style: isDarkMode
                          ? AppFonts.textW16bold
                          : AppFonts.textB16bold),
                ),
                IconButton(
                  icon: const Icon(Icons.person, color: Colors.black),
                  onPressed: () {}, //Todo
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
