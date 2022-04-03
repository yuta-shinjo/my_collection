import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_collection/ui/components/components.dart';

import 'package:my_collection/ui/pages/home_page/src/home_page_body.dart';

class HomePage extends ConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const AppBarText('みんなの思い出'),
      ),
      body: HomePageBody(),
    );
  }
}
