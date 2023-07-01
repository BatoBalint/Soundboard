import 'package:flutter/material.dart';

class SoundButton extends StatefulWidget {
  const SoundButton({super.key, required this.title});

  final String title;

  @override
  State<SoundButton> createState() => _SoundButtonState();
}

class _SoundButtonState extends State<SoundButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(0),
      ),
      onPressed: () {},
      child: SizedBox(
        width: 120,
        height: 120,
        child: Center(
          child: Container(
            alignment: Alignment.center,
            child: Text(
              widget.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }
}
