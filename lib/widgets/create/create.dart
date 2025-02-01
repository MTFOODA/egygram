import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/utilities/colors_dart.dart';
import 'package:provider/provider.dart';
import '../../utilities/fonts_dart.dart';
import '../../utilities/theme_provider.dart';
import '../post/create_post_widget.dart';
import '../reel/create_reel_widget.dart';
import '../story/create_story_widget.dart';

class Create extends StatefulWidget {
  final String userName;
  const Create({super.key, required TabController tabController, required  this.userName});

  @override
  State<Create> createState() => CreateState();
}

class CreateState extends State<Create>
    with SingleTickerProviderStateMixin{
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TabBar(
              controller: tabController,
              indicatorColor: AppColors.lightGrey,
              labelStyle: isDarkMode ? AppFonts.textW24bold : AppFonts.textB24bold,
              tabs: [
                Tab(text: "Post".tr()),
                Tab(text: "Reel".tr()),
                Tab(text: "Story".tr()),
              ],
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          CreatePostWidget(userName: widget.userName),
          CreateReelWidget(userName: widget.userName),
          CreateStoryWidget(userName: widget.userName),
        ],
      ),
    );
  }
}
