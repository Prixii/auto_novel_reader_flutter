part of 'model.dart';

@freezed
class EpubManageData extends HiveObject with _$EpubManageData {
  EpubManageData._();

  @HiveType(typeId: 1)
  factory EpubManageData({
    @HiveField(1) required String path,
    @HiveField(2) required String name,
    @HiveField(3) required String uid,
    @HiveField(4) @Default(0.0) progress,
    @HiveField(5) @Default(0) chapter,
  }) = _EpubManageData;

  factory EpubManageData.fromJson(Map<String, dynamic> json) =>
      _$EpubManageDataFromJson(json);
}

// class EpubManagerDataAdapter extends TypeAdapter<EpubManageData> {
//   @override
//   EpubManageData read(BinaryReader reader) {
//     return EpubManageData(
//       path: reader.read(),
//       name: reader.read(),
//       uid: reader.read(),
//       progress: reader.read(),
//       chapter: reader.read(),
//     );
//   }

//   @override
//   int get typeId => 0;

//   @override
//   void write(BinaryWriter writer, EpubManageData obj) {
//     writer.writeString(obj.path);
//     writer.writeString(obj.name);
//     writer.writeString(obj.uid);
//     writer.writeDouble(obj.progress);
//     writer.writeInt(obj.chapter);
//   }
// }
