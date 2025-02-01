import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utilities/fonts_dart.dart';
import '../../utilities/theme_provider.dart';

class FollowersWidget extends StatelessWidget {
  final List<String> followers;
  final int otherFollowersCount;

  const FollowersWidget({
    super.key,
    required this.followers,
    required this.otherFollowersCount,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          buildFollowerAvatars(followers, isDarkMode),
          const SizedBox(width: 70),
          buildFollowerText(followers, otherFollowersCount, isDarkMode),
        ],
      ),
    );
  }

  Widget buildFollowerAvatars(List<String> followers, bool isDarkMode) {
    if (followers.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: 50.0,
      height: 30.0,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (int i = 0; i < followers.length; i++)
            Positioned(
              left: i * 20.0,
              child: CircleAvatar(
                backgroundImage: AssetImage(followers[i]),
                radius: 15,
                backgroundColor: const Color(0xFFFFF4F4),
              ),
            ),
          if (otherFollowersCount > 0)
            Positioned(
              left: followers.length * 20.0,
              child: CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFFFFF4F4),
                child: Text(
                    '+$otherFollowersCount',
                    style: isDarkMode ? AppFonts.textW24bold : AppFonts.textB24bold
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildFollowerText(List<String> followers, int otherFollowersCount, bool isDarkMode) {
    followers.take(3).join(', ');

    if (otherFollowersCount > 0) {
      return Text(
          '${'Followed by '.tr()} $otherFollowersCount ${'Others'.tr()}',
          style: isDarkMode ? AppFonts.textW16bold : AppFonts.textB16bold
      );
    } else {
      return Text('Followed by '.tr());
    }
  }
}
