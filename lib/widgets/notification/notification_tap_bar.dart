import 'package:flutter/material.dart';
import 'notification_following.dart';
import 'notification_you.dart';

class NotificationTapBar extends StatefulWidget {
  const NotificationTapBar({super.key, required TabController tabController});

  @override
  State<NotificationTapBar> createState() => _NotificationTapBarState();
}

class _NotificationTapBarState extends State<NotificationTapBar>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TabBar(
              controller: tabController,
              indicatorColor: Colors.white,
              tabs: const [
                Tab(text: "Following"),
                Tab(text: "You"),
              ],
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: const [
          NotificationFollowingScreen(),
          NotificationYouScreen(),
        ],
      ),
    );
  }
}
