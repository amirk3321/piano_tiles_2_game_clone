import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:piano_tiles/provider/game_state.dart';
import 'package:piano_tiles/provider/mission_provider.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../model/node_model.dart';
import 'widgets/line.dart';
import 'widgets/line_divider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  List<Note> notes = mission();
  AudioCache player = new AudioCache();
  AnimationController animationController;
  int currentNoteIndex = 0;
  int points = 0;
  bool hasStarted = false;
  bool isPlaying = true;
  NoteState state;
  int time = 5000;

  @override
  void initState() {
    super.initState();

    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 0));
    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed && isPlaying) {
        if (notes[currentNoteIndex].state != NoteState.tapped) {
          //game over
          setState(() {
            isPlaying = false;
            notes[currentNoteIndex].state = NoteState.missed;
          });
          animationController.reverse().then((_) => _showFinishDialog());
        } else if (currentNoteIndex == notes.length - 5) {
          //song finished
          _showFinishDialog();
        } else {
          setState(() => ++currentNoteIndex);
          animationController.forward(from: 0);
        }
      }
    });
    animationController.forward(from: -1);
  }

  void _onTap(Note note) {
    bool areAllPreviousTapped = notes
        .sublist(0, note.orderNumber)
        .every((n) => n.state == NoteState.tapped);

    if (areAllPreviousTapped) {
      if (!hasStarted) {
        setState(() => hasStarted = true);
        animationController.forward();
      }
      _playNote(note);
      setState(() {
        note.state = NoteState.tapped;
        ++points;
        if (points == 10) {
          animationController.duration = Duration(milliseconds: 700);
        } else if (points == 15) {
          animationController.duration = Duration(milliseconds: 500);
        } else if (points == 30) {
          animationController.duration = Duration(milliseconds: 400);
        }
      });
    }
  }

  _drawPoints() {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 40.0),
        child: Text(
          "$points",
          style: TextStyle(color: Colors.red, fontSize: 60),
        ),
      ),
    );
  }

  _drawLine(int lineNumber) {
    return Expanded(
      child: Line(
        lineNumber: lineNumber,
        currentNotes: notes.sublist(currentNoteIndex, currentNoteIndex + 5),
        animation: animationController,
        onTileTap: _onTap,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    animationController.dispose();
  }

  void _restart() {
    setState(() {
      hasStarted = false;
      isPlaying = true;
      notes = mission();
      points = 0;
      currentNoteIndex = 0;
      animationController.duration = Duration(milliseconds: 1000);
    });
    animationController.reset();
  }

  void _showFinishDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          content: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 100,
                  width: 100,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.all(Radius.circular(150)),
                  ),
                  child: Icon(Icons.play_arrow, size: 50),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.all(Radius.circular(150)),
                  ),
                  child: Text(
                    "Score: $points",
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                _startWidget(),
              ],
            ),
          ),
        );
      },
    ).then((_) => _restart());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
              height: MediaQuery.of(context).size.height,
              child: Image.asset(
                "assets/background.gif",
                fit: BoxFit.cover,
              )),
          Row(
            children: <Widget>[
              _drawLine(0),
              LineDivider(),
              _drawLine(1),
              LineDivider(),
              _drawLine(2),
              LineDivider(),
              _drawLine(3)
            ],
          ),
          _drawPoints(),
          _drawCompleteTile()
        ],
      ),
    );
  }

  _playNote(Note note) {
    switch (note.line) {
      case 0:
        player.play('a.wav');
        return;
      case 1:
        player.play('c.wav');
        return;
      case 2:
        player.play('e.wav');
        return;
      case 3:
        player.play('f.wav');
        return;
    }
  }

  Widget _drawCompleteTile() {
    return Positioned(
      top: 25,
      right: 50,
      left: 50,
      child: Container(
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _tileWidget(Icons.star,
              color: points >= 10 ? Colors.deepOrange : Colors.green[200]),
          _tileHorizontalLine(
              points >= 10 ? Colors.deepOrange : Colors.deepOrange[200]),
          _tileWidget(Icons.star,
              color: points >= 30 ? Colors.deepOrange : Colors.green[200]),
          _tileHorizontalLine(
              points >= 40 ? Colors.deepOrange : Colors.deepOrange[200]),
          _tileWidget(Icons.star,
              color: points >= 41 ? Colors.deepOrange : Colors.green[200]),
        ]),
      ),
    );
  }

  _tileWidget(IconData icon, {Color color}) {
    return Container(
      child: Icon(
        icon,
        color: color,
      ),
    );
  }

  _tileHorizontalLine(Color color) {
    return Container(
      width: 80,
      height: 4,
      color: color,
    );
  }

  Widget _startWidget() {
    if (points >= 10 && points <20)
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.star,
            color: Colors.deepOrange,
          ),
          Icon(
            Icons.star,
            color: Colors.green[200],
          ),
          Icon(
            Icons.star,
            color: Colors.green[200],
          ),
        ],
      );
    else if (points >= 20 && points <40)
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.star,
            color: Colors.deepOrange,
          ),
          Icon(
            Icons.star,
            color: Colors.deepOrange,
          ),
          Icon(
            Icons.star,
            color: Colors.green[200],
          ),
        ],
      );
    else if (points >= 41)
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.star,
            color: Colors.deepOrange,
          ),
          Icon(
            Icons.star,
            color: Colors.deepOrange,
          ),
          Icon(
            Icons.star,
            color: Colors.deepOrange,
          ),
        ],
      );
    else
      return Container();
  }
}
