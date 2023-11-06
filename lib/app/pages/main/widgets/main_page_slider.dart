import 'package:flutter/material.dart';
import 'package:dnd_pocket_writer/misc/app_colors.dart';

class MainPageSlider extends StatefulWidget {
  const MainPageSlider({super.key, required this.onChanged});

  final Function(int) onChanged;

  @override
  State<MainPageSlider> createState() => _MainPageSliderState();
}

class _MainPageSliderState extends State<MainPageSlider> {
  double currentValue = 100.0;

  @override
  Widget build(BuildContext context) {
    return Slider(
      onChanged: (value) {
        setState(() {
          currentValue = value;
        });
        widget.onChanged.call(value.toInt());
      },
      value: currentValue,
      label: "${currentValue.toInt()} words",
      min: 100.0,
      max: 350.0,
      divisions: 5,
      activeColor: AppColors.main,
      inactiveColor: AppColors.main.withOpacity(0.2),
    );
  }
}
