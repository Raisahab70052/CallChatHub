import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

enum AvatarWidgetSize { small, medium, large }

class AvatarWidget extends StatelessWidget {
  const AvatarWidget({
    super.key,
    required this.initials,
    this.imageUrl,
    this.size = AvatarWidgetSize.medium,
    this.heroTag,
  });

  final String initials;
  final String? imageUrl;
  final AvatarWidgetSize size;
  final String? heroTag;

  double get _dimension {
    switch (size) {
      case AvatarWidgetSize.small:
        return 36;
      case AvatarWidgetSize.medium:
        return 56;
      case AvatarWidgetSize.large:
        return 100;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    final Widget avatar = Container(
      width: _dimension,
      height: _dimension,
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: dark
              ? const <Color>[Color(0xFF4A506F), Color(0xFF333755)]
              : const <Color>[Color(0xFFE0E8F8), Color(0xFFCAD2ED)],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: dark ? const Color(0x552F39A0) : const Color(0x6693ABF0),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: imageUrl == null
          ? Text(
              initials,
              style: TextStyle(
                fontSize: _dimension * 0.4,
                fontWeight: FontWeight.w700,
                color: dark ? Colors.white : const Color(0xFF1A2242),
              ),
            )
          : CachedNetworkImage(
              imageUrl: imageUrl!,
              fit: BoxFit.cover,
              width: _dimension,
              height: _dimension,
              errorWidget: (context, url, error) => Text(
                initials,
                style: TextStyle(
                  fontSize: _dimension * 0.4,
                  fontWeight: FontWeight.w700,
                  color: dark ? Colors.white : const Color(0xFF1A2242),
                ),
              ),
            ),
    );

    if (heroTag == null) return avatar;
    return Hero(tag: heroTag!, child: avatar);
  }
}
