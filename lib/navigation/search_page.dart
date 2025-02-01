import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../logics/user/get_user_logic/cubit.dart';
import '../logics/user/get_user_logic/state.dart';
import '../screens/others_profile.dart';
import '../utilities/fonts_dart.dart';
import '../utilities/theme_provider.dart';
import '../widgets/helpers/search_widget.dart';
import '../utilities/decoration.dart';

class SearchPage extends StatefulWidget {
  final String currentUser;
  const SearchPage({super.key, required this.currentUser});

  @override
  State<SearchPage> createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  TextEditingController controller = TextEditingController();

  List<Map<String, String>> users = [];
  List<Map<String, String>> filteredUsers = [];

  void searchUsers(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredUsers = users;
      } else {
        filteredUsers = users
            .where((user) =>
            user['userName']!.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> refreshContent(BuildContext context) async {
    context.read<GetUserCubit>().getUsers();
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => refreshContent(context),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              TextField(
                controller: searchController,
                decoration: searchInputDecoration(
                    context, 'User'.tr(), const Icon(CupertinoIcons.search)),
                onChanged: searchUsers,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                decoration: searchInputDecoration(
                  context,
                  'Post'.tr(),
                  const Icon(CupertinoIcons.search),
                ).copyWith(
                  suffixIcon: IconButton(
                    icon: const Icon(CupertinoIcons.paperplane),
                    onPressed: () {
                      searchById(
                        context: context,
                        postId: controller.text.trim(),
                        currentUser: widget.currentUser,
                        controller: controller,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SizedBox(
                  child: BlocListener<GetUserCubit, GetUsersState>(
                    listener: (context, state) {
                      if (state is GetUserSuccessState) {
                        setState(() {
                          users = state.users
                              .map((user) => {
                            'userName': user.userName,
                            'profileImage': user.profileImage ??
                                'assets/images/profile_picture.jpg',
                          })
                              .where((user) => user['userName'] != widget.currentUser)
                              .toList();
                          filteredUsers = users;
                        });
                      } else if (state is GetUserErrorState) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: ${state.errorMessage}'),
                          ),
                        );
                      }
                    },
                    child: filteredUsers.isNotEmpty
                        ? ListView.builder(
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = filteredUsers[index];
                        return Card(
                          elevation: 5,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: user['profileImage']!
                                  .startsWith('http')
                                  ? NetworkImage(user['profileImage']!)
                                  : AssetImage(user['profileImage']!)
                              as ImageProvider,
                            ),
                            title: Text(user['userName']!,style: isDarkMode ? AppFonts.textW24bold : AppFonts.textB24bold),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OthersProfilePage(
                                    currentUser: widget.currentUser,
                                    passedUser: user['userName']!,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    )
                        : Center(
                      child: Text(
                        'User not found'.tr(),
                          style: isDarkMode
                              ? AppFonts.textW24bold : AppFonts.textB24bold
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
