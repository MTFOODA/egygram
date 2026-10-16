import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utilities/theme_provider.dart';
import 'gridView_widget.dart';

class ProfileTapBarWidget extends StatelessWidget {
  final TabController tabController;

  const ProfileTapBarWidget({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Flexible(
      flex: 3,
      child: SizedBox(
        child: Column(
          children: [
            TabBar(
              controller: tabController,
              indicatorColor: isDarkMode ? Colors.white : Colors.black,
              tabs: [
                Tab(
                    icon: Icon(Icons.grid_on,
                        color: isDarkMode ? Colors.white : Colors.black)),
                Tab(
                    icon: Icon(Icons.video_collection,
                        color: isDarkMode ? Colors.white : Colors.black)),
                Tab(
                    icon: Icon(Icons.person_pin,
                        color: isDarkMode ? Colors.white : Colors.black)),
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
