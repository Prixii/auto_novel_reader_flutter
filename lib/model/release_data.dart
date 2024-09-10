part of 'model.dart';

@freezed
class ReleaseData with _$ReleaseData {
  const factory ReleaseData({
    required String tag,
    required String body,
  }) = _ReleaseData;
}
