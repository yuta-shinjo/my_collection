import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:my_collection/models/src/user.dart';
import 'package:my_collection/services/fire_users_service.dart';
import 'package:my_collection/services/fire_storage_service.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

part 'account_page_controller.freezed.dart';

@freezed
class AccountPageState with _$AccountPageState {
  const factory AccountPageState({
    @Default(User()) User profile,
    @Default('') String name,
    @Default('') String profileImageUrl,
    @Default('') String email,
    File? imageFile,
  }) = _AccountPageState;
}

final accountPageProvider =
    StateNotifierProvider.autoDispose<AccountPageController, AccountPageState>(
        (ref) {
  return AccountPageController();
});

class AccountPageController extends StateNotifier<AccountPageState> {
  AccountPageController() : super(const AccountPageState()) {
    _init();
  }

  void _init() async {
    final profile = await _fireUsersService.fetchUserProfile();
    if (profile != null) {
      state = state.copyWith(profile: profile);
    }
  }

  void fixName() {
    state = state.copyWith(name: state.profile.name);
  }

  // プロフィールを編集した時に時にリアルタイムに反映させるようにするため
  Future<void> fetchUserProfile() async {
    final profile = await _fireUsersService.fetchUserProfile();
    if (profile != null) {
      state = state.copyWith(profile: profile);
    }
  }

  // 編集ページで呼び出さないのは、変更ボタンを押さずにaccount_pageに戻った後、
  // 再度変更ボタンを押すと前回の内容が反映されてしまうためaccount_pageで実装した
  // 登録後に入力した内容を削除するため
  void resetProfile() {
    if (state.name != '') {
      state = state.copyWith(name: '');
    }
    if (state.imageFile != null) {
      state = state.copyWith(imageFile: null);
    }
  }

  final _fireUsersService = FireUsersService();

  final profileName = TextEditingController();

  Future<void> pickImage() async {
    //画像取得&軽量化
    final pickedImageFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 1, //画質。とりあえず1。
    );
    //トリミング
    if (pickedImageFile == null) return;
    final croppedImageFile = await ImageCropper().cropImage(
      sourcePath: pickedImageFile.path,
    );
    state = state.copyWith(imageFile: croppedImageFile);
  }

  final _fireStorageService = FireStorageService();

  Future<void> uploadImage() async {
    final uploadUrl = await _fireStorageService.uploadImage(
        croppedImageFile: state.imageFile);
    EasyLoading.dismiss();
    if (uploadUrl == null) return;
    state = state.copyWith(profileImageUrl: uploadUrl);
  }

  // Future<void> pickImage(XFile? image, String imageUrl) async {
  //   if (image == null) return;
  //   state = state.copyWith(imageFile: File(image.path));
  //   state = state.copyWith(profileImageUrl: imageUrl);
  // }

  void inputName(String name) => state = state.copyWith(name: name);

  void deleteImage(String imgUrl, File? imageFile) {
    if (state.imageFile != null) {
      state = state.copyWith(imageFile: null);
    }
    if (state.profile.imgUrls != '') {}
  }

  Future<void> updateProfile(
      File? imageFile, String imgUrls, String name) async {
    await _fireUsersService.update(
      state.imageFile,
      state.profile.imgUrls,
      state.name,
    );
  }

  void deleteImageFile() {
    state = state.copyWith(imageFile: null);
  }

  final btnController = RoundedLoadingButtonController();

  Future<void> isSignOut() async {
    await _fireUsersService.signOut();
  }
}
