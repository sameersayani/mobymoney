import 'package:talker_flutter/talker_flutter.dart';

final talker = TalkerFlutter.init(
  settings: TalkerSettings(
    maxHistoryItems: 1000,
    useConsoleLogs: false, // We route formatted console logs through Logger / Talker
  ),
);
