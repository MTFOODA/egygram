import 'package:flutter/material.dart';
import 'package:flutter_application_3/widgets/create/create.dart';

class CreatePage extends StatefulWidget {
  final String currentUser;
  const CreatePage({super.key, required  this.currentUser});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Create(tabController: _tabController, userName: widget.currentUser);
  }
}
