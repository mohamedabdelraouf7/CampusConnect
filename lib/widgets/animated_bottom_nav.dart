import 'package:flutter/material.dart';

class AnimatedBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final List<BottomNavigationBarItem> items;
  
  const AnimatedBottomNav({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -3),
          ),
        ],
        color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
      ),
      child: SafeArea(
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final isSelected = index == selectedIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                  horizontal: isSelected ? 16 : 8,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: InkWell(
                  onTap: () => onItemSelected(index),
                  child: Row(
                    children: [
                      Icon(
                        (items[index].icon as Icon).icon,
                        color: isSelected 
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        Text(
                          items[index].label ?? '',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}