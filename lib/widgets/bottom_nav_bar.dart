import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final Map<String, String> translations;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.translations,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.black, // navbar background
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, CupertinoIcons.house, translations['home']!, currentIndex),
          _buildNavItem(1, CupertinoIcons.wrench, translations['mechanicsTitle']!, currentIndex),
          _buildNavItem(2, CupertinoIcons.cart, translations['sparePartsTitle']!, currentIndex),
          _buildNavItem(3, CupertinoIcons.calendar, translations['bookingsPage']!, currentIndex),
          _buildNavItem(4, CupertinoIcons.person, translations['profilePage']!, currentIndex),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, int selectedIndex) {
    final bool isSelected = index == selectedIndex;

    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.greenAccent[400] : Colors.grey[900],
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey,
              size: 22,
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
