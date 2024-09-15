import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'web_cache_state.dart';
part 'web_cache_cubit.freezed.dart';
part 'web_cache_cubit.g.dart';

class WebCacheCubit extends HydratedCubit<WebCacheState> {
  WebCacheCubit() : super(const WebCacheState.initial());

  Future<void> updateLastReadChapter(
    String novelKey,
    String? chapterId,
  ) async {
    if (chapterId == null) return;
    emit(state.copyWith(
      lastReadChapterMap: {...state.lastReadChapterMap, novelKey: chapterId},
    ));
  }

  @override
  WebCacheState? fromJson(Map<String, dynamic> json) =>
      WebCacheState.fromJson(json);

  @override
  Map<String, dynamic>? toJson(WebCacheState state) => state.toJson();
}
