import 'package:flutter/widgets.dart';
import 'package:formatted_text/formatted_text.dart';

import '../utils/utils.dart';

class FormattedTextEditingController extends TextEditingController {
  FormattedTextEditingController({
    String? text,
    this.formatters,
  }) : super(text: text);

  FormattedTextEditingController.fromValue(
    TextEditingValue? value, {
    this.formatters,
  })  : assert(
          value == null ||
              !value.composing.isValid ||
              value.isComposingRangeValid,
          'New TextEditingValue $value has an invalid non-empty composing range '
          '${value.composing}. It is recommended to use a valid composing range, '
          'even for readonly text fields',
        ),
        super(text: value?.text);

  final List<FormattedTextFormatter>? formatters;

  List<InlineSpan> _currentSpans = [];

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final List<InlineSpan> children = FormattedTextUtils.formattedSpans(
      context,
      text,
      style: style,
      showFormattingCharacters: true,
      formatters: formatters,
    );

    _currentSpans = children;

    return TextSpan(style: style, children: children);
  }

  @override
  String get text => value.text;

  @override
  set text(String newText) {
    value = value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(
          offset: selection.extentOffset + (newText.length - text.length)),
      composing: TextRange.empty,
    );
  }

  @override
  set value(TextEditingValue newValue) {
    assert(
      !newValue.composing.isValid || newValue.isComposingRangeValid,
      'New TextEditingValue $newValue has an invalid non-empty composing range '
      '${newValue.composing}. It is recommended to use a valid composing range, '
      'even for readonly text fields',
    );
    super.value = newValue;
  }

  List<TextStyle> get selectionTextStyles {
    final startIndex = selection.baseOffset - 1;
    final endIndex = selection.extentOffset;

    final textStyles = <TextStyle>[];

    int spansLength = 0;

    for (final span in _currentSpans) {
      if (span is! TextSpan) continue;
      if (span.children?.isNotEmpty ?? false) {
        for (final child in span.children!) {
          spansLength += (child as TextSpan).text?.length ?? 0;
        }
      }
      if (span.text != null) {
        spansLength += span.text!.length;
      }
      if (spansLength >= startIndex) {
        TextStyle? spanStyle;
        if (span.children?.isNotEmpty ?? false) {
          for (final child in span.children!) {
            if (spanStyle == null) {
              spanStyle = child.style;
              continue;
            }
            spanStyle.merge(child.style?.copyWith(inherit: true));
          }
        }
        if (span.style != null) {
          spanStyle ??= span.style;
        }
        if (spanStyle != null) {
          textStyles.add(spanStyle.copyWith(inherit: true));
        }
      }
      if (spansLength >= endIndex) {
        break;
      }
    }

    return textStyles;
  }
}
