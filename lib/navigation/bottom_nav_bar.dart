import 'package:flutter/material.dart';

class BottomNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onItemSelected;
  final VoidCallback onCreateMission;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
    required this.onCreateMission,
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 82,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          // HOME
          Expanded(
            child: _NavItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              label: 'Home',
              isSelected: widget.currentIndex == 0,
              isHovered: _hoveredIndex == 0,
              onHover: (hovered) {
                setState(() {
                  _hoveredIndex = hovered ? 0 : null;
                });
              },
              onTap: () => widget.onItemSelected(0),
            ),
          ),

          // MISSION
          Expanded(
            child: _NavItem(
              icon: Icons.assignment_outlined,
              activeIcon: Icons.assignment,
              label: 'Mission',
              isSelected: widget.currentIndex == 1,
              isHovered: _hoveredIndex == 1,
              onHover: (hovered) {
                setState(() {
                  _hoveredIndex = hovered ? 1 : null;
                });
              },
              onTap: () => widget.onItemSelected(1),
            ),
          ),

          // CREATE
          Expanded(child: _CreateButton(onTap: widget.onCreateMission)),

          // NOTIFICATION
          Expanded(
            child: _NavItem(
              icon: Icons.notifications_outlined,
              activeIcon: Icons.notifications,
              label: 'Notification',
              isSelected: widget.currentIndex == 2,
              isHovered: _hoveredIndex == 2,
              onHover: (hovered) {
                setState(() {
                  _hoveredIndex = hovered ? 2 : null;
                });
              },
              onTap: () => widget.onItemSelected(2),
            ),
          ),

          // PROFILE
          Expanded(
            child: _NavItem(
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              label: 'Profile',
              isSelected: widget.currentIndex == 3,
              isHovered: _hoveredIndex == 3,
              onHover: (hovered) {
                setState(() {
                  _hoveredIndex = hovered ? 3 : null;
                });
              },
              onTap: () => widget.onItemSelected(3),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final bool isHovered;
  final ValueChanged<bool> onHover;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.isHovered,
    required this.onHover,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Selected OR hovered = active blue state.
    final isActive = isSelected || isHovered;

    final color = isActive ? colorScheme.primary : colorScheme.onSurfaceVariant;

    return MouseRegion(
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. SMALL INDICATOR
            //    ABOVE the icon
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              height: 3,
              width: isActive ? 24 : 0,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const SizedBox(height: 5),

            // 2. ICON
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Icon(
                isActive ? activeIcon : icon,
                key: ValueKey(isActive),
                size: 23,
                color: color,
              ),
            ),

            const SizedBox(height: 3),

            // 3. TEXT
            //    UNDER the icon
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: color,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CreateButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Transform.translate(
        offset: const Offset(0, -18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 30),
            ),

            const SizedBox(height: 2),

            Text(
              'Create',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
