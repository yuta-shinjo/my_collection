import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_collection/ui/projects/register_back_button.dart';
import 'package:my_collection/ui/register_page/src/register_page_body.dart';

class RegisterPage extends ConsumerWidget {
  const RegisterPage({Key? key}) : super(key: key);

  static Route<T> route<T>() {
    return MaterialPageRoute<T>(
      builder: (_) => const RegisterPage(),
      settings: const RouteSettings(name: 'register_page'),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Focus(
      focusNode: FocusNode(),
      child: GestureDetector(
        onTap: FocusScope.of(context).unfocus,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('新規登録をする'),
            leading: const RegisterBackButton(),
          ),
          body: const RegisterPageBody(),
        ),
      ),
    );
  }
}
