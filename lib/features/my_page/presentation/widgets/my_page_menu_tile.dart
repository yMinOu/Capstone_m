/// 마이페이지에서 사용하는 공통 메뉴 타일 위젯.
import 'package:flutter/material.dart';
import 'package:nihongo/core/constants/app_colors.dart';
class MyPageMenuTile extends StatelessWidget {
  const MyPageMenuTile({
    super.key,
    required this.title,
    required this.onTap,
    this.trailing,
  });

  final String title;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {

    return InkWell(
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: AppColors.textBlack,
                ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}