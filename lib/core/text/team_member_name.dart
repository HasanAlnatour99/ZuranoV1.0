import 'package:flutter/material.dart';

/// Title-cases each whitespace-separated segment for display and Firestore writes.
///
/// Examples: `"alice  alnatour"` → `"Alice Alnatour"`, `"AHMED"` → `"Ahmed"`.
/// Arabic and other scripts without case pass through unchanged per character.
String formatTeamMemberName(String? raw) {
  if (raw == null) return '';
  final source = raw.trim();
  if (source.isEmpty) return '';
  return source.split(RegExp(r'\s+')).map(_titleCaseWord).join(' ');
}

String _titleCaseWord(String word) {
  if (word.isEmpty) return word;
  if (word.length == 1) return word.toUpperCase();
  return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
}

/// Renders a team member name with [formatTeamMemberName] applied (drop-in for [Text]).
class TeamMemberNameText extends StatelessWidget {
  const TeamMemberNameText(
    this.name, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.softWrap,
    this.textDirection,
    this.semanticsLabel,
  });

  final String? name;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  final bool? softWrap;
  final TextDirection? textDirection;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Text(
      formatTeamMemberName(name),
      style: style,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
      softWrap: softWrap,
      textDirection: textDirection,
      semanticsLabel: semanticsLabel,
    );
  }
}
