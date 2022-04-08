import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_collection/models/src/album.dart';
import 'package:my_collection/services/fire_users_service.dart';

part 'profile_map_page_controller.freezed.dart';

@freezed
class ProfileMapPageState with _$ProfileMapPageState {
  const factory ProfileMapPageState({
    @Default('') String markerId,
    @Default('') String content,
    @Default('') String imgUrls,
    @Default(0) int currentPage,
    @Default(0) int activeAlbumIndex,
    @Default(false) bool isViewAlbums,
    @Default(<Album>[]) List<Album> albums,
    Album? selectedAlbum,
  }) = _ProfileMapPageState;
}

final profileMapPageProvider = StateNotifierProvider.autoDispose<
    ProfileMapPageController, ProfileMapPageState>(
  (ref) => ProfileMapPageController(),
);

class ProfileMapPageController extends StateNotifier<ProfileMapPageState> {
  ProfileMapPageController() : super(const ProfileMapPageState()) {
    _init();
  }

  final _fireUsersService = FireUsersService();
  final PageController controller = PageController();

  void _init() async {
    await _fireUsersService.fetchMyAlbumList(
      onValueChanged: (albums) {
        state = state.copyWith(albums: albums);
      },
    );

    // ページコントローラのページ遷移を監視しページ数を丸める
    controller.addListener(() {
      int next = controller.page!.round();
      if (state.currentPage != next) {
        state = state.copyWith(currentPage: next);
      }
    });
  }

  // 作成ページで作成ボタンを押したときにmapPageのマップを更新するため
  Future<void> fetchAlbumList() async {
    await _fireUsersService.fetchMyAlbumList(
      onValueChanged: (albums) {
        state = state.copyWith(albums: albums);
      },
    );
  }

  void toggleViewAlbums() {
    state = state.copyWith(isViewAlbums: !state.isViewAlbums);
  }

  // albumを表示する時にactive(これによってpaddingの値が変わる)がnullになってしまって
  // 一瞬だけpaddingがついてしまって小さくなってしまうのを改善
  void initializedPage() {
    state = state.copyWith(currentPage: 0);
  }

  void selectedAlbum(int activeAlbumIndex) {
    state = state.copyWith(activeAlbumIndex: activeAlbumIndex);
  }
}
