import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

const _linkStyle = TextStyle(
  color: Colors.blue,
  decoration: TextDecoration.underline,
);

mixin LinkModifier {
  static final matcher = RegExp(
      r'(http(s)?:\/\/.)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)');

  static List<InlineSpan> modifyLink(String text,
      {TextStyle? style, void Function(String link)? onLinkTap}) {
    if (text.isEmpty) return [];

    final matches = matcher.allMatches(text);

    if (matches.isEmpty) return [TextSpan(text: text, style: style)];

    final result = <InlineSpan>[];

    int previousEndIndex = 0;
    for (final match in matches) {
      final textSubstring = text.substring(previousEndIndex, match.start);

      previousEndIndex = match.end;

      if (textSubstring.isNotEmpty) {
        result.add(TextSpan(text: textSubstring, style: style));
      }

      final linkSubstring = text.substring(match.start, match.end);

      result.add(TextSpan(
          text: linkSubstring,
          style: style?.merge(_linkStyle),
          recognizer: TapGestureRecognizer()
            ..onTap =
                () => onLinkTap != null ? onLinkTap(linkSubstring) : null));
    }
    final textSubstring = text.substring(previousEndIndex);
    if (textSubstring.isNotEmpty) {
      result.add(TextSpan(text: textSubstring, style: style));
    }

    return result;
  }
}
