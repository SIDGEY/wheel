

import 'package:flutter/material.dart';

import '../generated/l10n.dart';

extension Translations on BuildContext{
  S get text => S.of(this);
}
