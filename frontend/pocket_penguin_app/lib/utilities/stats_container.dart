import 'package:flutter/material.dart';
import '../constants/colors.dart';

class StatsContainer extends StatelessWidget {
  const StatsContainer({
    Key? key,
    required this.icon,
    required this.stat,
    this.iconColor = Colors.orange,
  }) : super(key: key);

  final Color iconColor;
  final IconData icon;
  final String stat;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 110,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColor.secondaryColor,
      ),
      child: Center(
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          children: [
            Icon(
              icon,
              color: iconColor,
            ),
            Text(
              stat,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            )
          ],
        ),
      ),
    );
  }
}
