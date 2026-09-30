import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/profile_model.dart';
import 'provider/profile_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    return ColoredBox(
      color: const Color(0xFFF4F6F9),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileCard(profile: profile),

              const SizedBox(height: 18),

              const Text(
                'Mission settings',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),

              const SizedBox(height: 10),

              SettingsCard(
                children: [
                  SettingsRow(
                    icon: Icons.description_outlined,
                    title: 'Allowance policy reference',
                    description:
                        'Example meal, accommodation and mileage rates',
                    onTap: () {},
                  ),
                  SettingsRow(
                    icon: Icons.verified_user_outlined,
                    title: 'Approval routing',
                    description: 'Function Manager → HR BP → Finance BP → Business Operations',
                    onTap: () {},
                  ),
                  SettingsRow(
                    icon: Icons.article_outlined,
                    title: 'Mission guidelines',
                    description: 'Company travel and mission handbook',
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 14),

              SettingsCard(
                children: [
                  SettingsRow(
                    icon: Icons.help_outline,
                    title: 'Help and support',
                    description:
                        'Contact People & Culture or Business Operations',
                    onTap: () {},
                  ),
                  SettingsRow(
                    icon: Icons.logout,
                    title: 'Sign out',
                    isDanger: true,
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Center(
                child: Text(
                  'SMS v0.9 prototype · internal use only',
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileCard extends StatelessWidget {
  final Profile profile;

  const ProfileCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipOval(
                  child: Image.network(
                    profile.profilePhoto,
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 52,
                        height: 52,
                        color: colorScheme.primaryContainer,
                        alignment: Alignment.center,
                        child: Text(
                          _initials(profile.name),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.primary,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        profile.jobTitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          ProfileChip(text: profile.level),
                          ProfileChip(text: profile.department),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            ProfileField(label: 'Employee ID', value: profile.employeeId),

            ProfileField(
              label: 'Work email',
              value: profile.email,
              icon: Icons.mail_outline,
            ),

            ProfileField(
              label: 'Phone',
              value: profile.phone,
              icon: Icons.phone_outlined,
            ),

            ProfileField(
              label: 'Base location',
              value: profile.baseLocation,
              icon: Icons.business_outlined,
            ),

            const SizedBox(height: 4),

            Container(
              padding: const EdgeInsets.only(top: 14),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: colorScheme.outlineVariant),
                ),
              ),
              child: Row(
                children: [
                  ProfileStat(
                    number: profile.totalMissions.toString(),
                    label: 'TOTAL',
                  ),
                  ProfileStat(
                    number: profile.approvedMissions.toString(),
                    label: 'APPROVED',
                  ),
                  ProfileStat(
                    number: profile.completeMissions.toString(),
                    label: 'COMPLETED',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');

    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }

    return name.substring(0, 1).toUpperCase();
  }
}

class ProfileChip extends StatelessWidget {
  final String text;

  const ProfileChip({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class ProfileField extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;

  const ProfileField({
    super.key,
    required this.label,
    required this.value,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
          ),

          const Spacer(),

          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null)
                  Icon(icon, size: 14, color: colorScheme.onSurfaceVariant),

                if (icon != null) const SizedBox(width: 6),

                Flexible(
                  child: Text(
                    value,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileStat extends StatelessWidget {
  final String number;
  final String label;

  const ProfileStat({super.key, required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Column(
        children: [
          Text(
            number,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),

          const SizedBox(height: 2),

          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const SettingsCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surface,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final VoidCallback onTap;
  final bool isDanger;

  const SettingsRow({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final mainColor = isDanger ? colorScheme.error : colorScheme.onSurface;

    final iconBackground = isDanger
        ? colorScheme.errorContainer
        : colorScheme.primaryContainer;

    final iconColor = isDanger ? colorScheme.error : colorScheme.primary;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(9),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 17, color: iconColor),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: mainColor,
                    ),
                  ),

                  if (description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      description!,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            Icon(
              Icons.chevron_right,
              size: 20,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
