import 'package:flutter/foundation.dart';

/// Bump this whenever missions change (created, edited, submitted...).
/// The home pages listen to it and reload their list.
final ValueNotifier<int> missionRefresh = ValueNotifier<int>(0);

void notifyMissionsChanged() => missionRefresh.value++;
