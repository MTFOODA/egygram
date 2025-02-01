import 'package:flutter/material.dart';
import 'gridView_widget.dart';

class ProfileTapBarWidget extends StatelessWidget {
  final TabController tabController;

  const ProfileTapBarWidget({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 3,
      child: SizedBox(
        child: Column(
          children: [
            TabBar(
              controller: tabController,
              indicatorColor: Colors.black,
              tabs: const [
                Tab(icon: Icon(Icons.grid_on, color: Colors.black)),
                Tab(icon: Icon(Icons.video_collection, color: Colors.black)),
                Tab(icon: Icon(Icons.person_pin, color: Colors.black)),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: [
                  buildGridView(),
                  buildGridView(),
                  buildGridView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
