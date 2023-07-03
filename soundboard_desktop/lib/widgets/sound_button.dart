import 'package:flutter/material.dart';
import 'package:soundboard_desktop/classes/sound.dart';

class SoundButton extends StatefulWidget {
  const SoundButton({
    super.key,
    required this.title,
    this.buttonFunction,
    this.buttonColor = const Color.fromARGB(255, 15, 57, 68),
    this.textColor,
    this.checkPlayerState = true,
    this.sound,
  });

  final String title;
  final Function? buttonFunction;
  final bool checkPlayerState;
  final Color buttonColor;
  final Color? textColor;
  final Sound? sound;

  @override
  State<SoundButton> createState() => _SoundButtonState();
}

class _SoundButtonState extends State<SoundButton> {
  Color disabledColor = const Color.fromARGB(255, 5, 19, 22);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      initialData: !widget.checkPlayerState,
      stream: widget.sound?.getPlayerStateStream(),
      builder: (context, snapshot) {
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(0),
            backgroundColor: (snapshot.data ?? !widget.checkPlayerState)
                ? widget.buttonColor
                : disabledColor,
          ),
          onPressed: buttonClick,
          child: SizedBox(
            width: 120,
            height: 120,
            child: Center(
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: widget.textColor),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> buttonClick() async {
    if (widget.buttonFunction != null) {
      widget.buttonFunction!();
    } else {
      widget.sound?.play();
    }
  }
}
