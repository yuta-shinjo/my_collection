import 'package:flutter/material.dart';
import 'package:my_collection/ui/components/components.dart';
import 'package:my_collection/ui/pages/add_album_page/src/add_album_page_body.dart';

class AddAlbumPage extends StatelessWidget {
  const AddAlbumPage({Key? key}) : super(key: key);

  static Route<T> route<T>() {
    return MaterialPageRoute<T>(
      builder: (_) => const AddAlbumPage(),
      settings: const RouteSettings(name: 'add_album_page'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const AppBarText('新規作成'),
          leading: IconButton(
            onPressed: (() => Navigator.pop(context)),
            icon: Icon(Icons.close),
          )),
      body: AddAlbumPgeBody(),
    );
  }
}
