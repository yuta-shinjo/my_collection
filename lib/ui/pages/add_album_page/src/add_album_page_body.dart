import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_collection/controllers/pages/add_album_page_controller.dart';
import 'package:my_collection/controllers/pages/tag_chips_page_controller.dart';
import 'package:my_collection/themes/app_colors.dart';
import 'package:my_collection/ui/components/components.dart';
import 'package:my_collection/ui/pages/add_album_page/src/tag_chips_page.dart';
import 'package:my_collection/ui/projects/rounded_loading_button.dart';
import 'package:my_collection/utiles.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class AddAlbumPgeBody extends ConsumerWidget {
  const AddAlbumPgeBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imgFile = ref.watch(addAlbumPageProvider.select((s) => s.imgFile));
    final imgUrls = ref.watch(addAlbumPageProvider.select((s) => s.imgUrl));
    final content = ref.watch(addAlbumPageProvider.select((s) => s.content));
    final btnController = ref.read(addAlbumPageProvider.notifier).btnController;
    final controller =
        ref.read(addAlbumPageProvider.notifier).contentController;
    final tags =
        ref.watch(tagChipsPageProvider.select((s) => s.labelList)) ?? [];
    return Focus(
      focusNode: FocusNode(),
      child: GestureDetector(
        onTap: FocusScope.of(context).unfocus,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () async {
                  final image = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);
                  await ref
                      .read(addAlbumPageProvider.notifier)
                      .pickImage(image, imgUrls);
                  btnController.reset();
                },
                child: SizedBox(
                  height: MediaQuery.of(context).size.height / 3,
                  width: double.infinity,
                  child: _imgArea(imgFile),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 16, top: 18),
                child: Subtitle2Text('キャプション', color: AppColors.textDisable),
              ),
              const Divider(color: AppColors.grey),
              _contentArea(controller, btnController),
              const Divider(color: AppColors.grey),
              const Padding(
                padding: EdgeInsets.only(left: 16, top: 16),
                child: Subtitle2Text('タグ', color: AppColors.textDisable),
              ),
              const Divider(color: AppColors.grey),
              TagChip(btnController: btnController),
              const SizedBox(height: 40),
              ButtonTheme(
                child: LoadingButton(
                  primaryColor: AppColors.primary,
                  text: ButtonText('作成'),
                  controller: btnController,
                  onPressed: () async {
                    if (imgFile != null) {
                      print(tags);
                      try {
                        ref.read(addAlbumPageProvider.notifier).startLoading();
                        ref
                            .read(addAlbumPageProvider.notifier)
                            .loadingSuccess(btnController);
                        await ref
                            .read(addAlbumPageProvider.notifier)
                            .addAlbum(content, imgUrls, imgFile, tags);
                        if (tags != []) {
                          await ref
                              .read(addAlbumPageProvider.notifier)
                              .addTags(tags);
                        }
                        createAlbumSuccessMassage();
                        ref
                            .read(addAlbumPageProvider.notifier)
                            .contentController
                            .clear();
                        ref
                            .read(addAlbumPageProvider.notifier)
                            .deleteImage(imgUrls, imgFile);
                        ref.read(tagChipsPageProvider.notifier).clearChips();
                      } catch (e) {
                        ref
                            .read(addAlbumPageProvider.notifier)
                            .loadingError(btnController);
                        print(e);
                      } finally {
                        ref.read(addAlbumPageProvider.notifier).endLoading();
                      }
                    } else {
                      ref
                          .read(addAlbumPageProvider.notifier)
                          .btnController
                          .error();
                    }
                  },
                ),
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imgArea(File? imgFile) {
    return Image(
      image: imgFile != null
          ? Image.file(imgFile, fit: BoxFit.cover).image
          : NetworkImage(
              'https://www.tsuzukiblog.org/_wu/2020/03/shutterstock_1005938026.jpg',
            ),
      fit: BoxFit.cover,
    );
  }

  Widget _contentArea(
    TextEditingController controller,
    RoundedLoadingButtonController btnController,
  ) {
    return Consumer(
      builder: (context, ref, _) {
        return TextFormField(
          onTap: () => btnController.reset(),
          maxLines: 6,
          minLines: 6,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.all(15),
            hintText: 'キャプションを書こう',
            border: InputBorder.none,
          ),
          onChanged: (text) {
            ref.read(addAlbumPageProvider.notifier).inputContent(text);
          },
          controller: controller,
        );
      },
    );
  }
}
