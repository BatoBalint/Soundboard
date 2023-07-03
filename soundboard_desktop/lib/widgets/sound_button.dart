import 'package:flutter/material.dart';
import 'package:soundboard_desktop/classes/sound.dart';

class SoundButton extends StatefulWidget {
  const SoundButton({
    super.key,
    required this.title,
    this.buttonFunction,
    this.fileName,
    this.buttonColor = const Color.fromARGB(255, 15, 57, 68),
    this.checkPlayerState = true,
  });

  final String title;
  final Function? buttonFunction;
  final String? fileName;
  final bool checkPlayerState;
  final Color buttonColor;

  @override
  State<SoundButton> createState() => _SoundButtonState();
}

class _SoundButtonState extends State<SoundButton> {
  Sound? sound;
  Color disabledColor = const Color.fromARGB(255, 5, 19, 22);

  @override
  void initState() {
    super.initState();
    sound = Sound(fileName: widget.fileName, soundName: widget.title);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      initialData: !widget.checkPlayerState,
      stream: sound!.getPlayerStateStream(),
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
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> buttonClick() async {
    SnackBar s = SnackBar(
      content: Text(
        widget.title,
        style: const TextStyle(color: Colors.white70),
      ),
      backgroundColor: Colors.black,
    );
    ScaffoldMessenger.of(context).showSnackBar(s);

    if (widget.buttonFunction != null) {
      widget.buttonFunction!();
    } else {
      sound?.play();
    }
  }
}
