import 'package:anymex/widgets/anymex_widgets/anymex_text.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class _LinkedPlatform {
  final String key;
  final String name;
  final String iconAsset;
  final Color color;
  final String profileUrl;

  const _LinkedPlatform({
    required this.key,
    required this.name,
    required this.iconAsset,
    required this.color,
    required this.profileUrl,
  });
}

class LinkedAccountsSheet extends StatelessWidget {
  final Map<String, dynamic>? linkedAccounts;

  const LinkedAccountsSheet({super.key, this.linkedAccounts});

  static const List<_LinkedPlatform> _platforms = [
    _LinkedPlatform(
      key: 'anilist',
      name: 'AniList',
      iconAsset: 'assets/images/anilist-icon.png',
      color: Color(0xFF02A9FF),
      profileUrl: 'https://anilist.co/user/',
    ),
    _LinkedPlatform(
      key: 'mal',
      name: 'MyAnimeList',
      iconAsset: 'assets/images/mal-icon.png',
      color: Color(0xFF4C75D6),
      profileUrl: 'https://myanimelist.net/profile/',
    ),
    _LinkedPlatform(
      key: 'simkl',
      name: 'Simkl',
      iconAsset: 'assets/images/simkl-icon.png',
      color: Color(0xFFFFAE19),
      profileUrl: 'https://simkl.com/',
    ),
  ];

  static Future<void> show(
    BuildContext context, {
    Map<String, dynamic>? linkedAccounts,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => LinkedAccountsSheet(linkedAccounts: linkedAccounts),
    );
  }

  String? _usernameFor(String key) {
    final entry = linkedAccounts?[key];
    if (entry is Map) {
      final username = entry['username']?.toString().trim();
      if (username != null && username.isNotEmpty) return username;
    }
    return null;
  }

  Future<void> _openProfile(
    BuildContext context,
    _LinkedPlatform platform,
    String username,
  ) async {
    Navigator.pop(context);
    final uri = Uri.parse('${platform.profileUrl}$username');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final entries = <({_LinkedPlatform platform, String username})>[];
    for (final platform in _platforms) {
      final username = _usernameFor(platform.key);
      if (username != null) {
        entries.add((platform: platform, username: username));
      }
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const AnymeXText(
              'Linked Accounts',
              variant: TextVariant.bold,
              size: 18,
            ),
            const SizedBox(height: 2),
            AnymeXText(
              'Profiles linked through Commentum',
              size: 12,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            if (entries.isEmpty)
              _EmptyState(theme: theme)
            else
              ...entries.map(
                (entry) => _LinkedAccountTile(
                  platform: entry.platform,
                  username: entry.username,
                  onTap: () => _openProfile(
                    context,
                    entry.platform,
                    entry.username,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LinkedAccountTile extends StatelessWidget {
  final _LinkedPlatform platform;
  final String username;
  final VoidCallback onTap;

  const _LinkedAccountTile({
    required this.platform,
    required this.username,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: platform.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: platform.color.withOpacity(0.35),
                  width: 0.8,
                ),
              ),
              child: Image.asset(
                platform.iconAsset,
                fit: BoxFit.contain,
                color: platform.color,
                colorBlendMode: BlendMode.srcIn,
                filterQuality: FilterQuality.high,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnymeXText(
                    platform.name,
                    variant: TextVariant.semiBold,
                    size: 14,
                  ),
                  const SizedBox(height: 2),
                  AnymeXText(
                    '@$username',
                    size: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.open_in_new_rounded,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final ThemeData theme;

  const _EmptyState({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Icon(
            Icons.link_off_rounded,
            size: 28,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          const AnymeXText(
            'No linked accounts',
            variant: TextVariant.semiBold,
            size: 14,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          AnymeXText(
            'No external platform profiles are linked to this account.',
            size: 11,
            color: theme.colorScheme.onSurfaceVariant,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
