import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntroScreen extends StatefulWidget {
  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  List<Slide> slides = new List();

  @override
  void initState() {
    super.initState();

    slides.add(
      new Slide(
        title: "RE OPTIONS",
        description: "After Logging in, you will be taken to this page to select your options.",
        pathImage: "images/select_page_initial.jpg",
        heightImage: 400,
        backgroundColor: Color(0xfff5a623),
      ),
    );
    slides.add(
      new Slide(
        title: "RE OPTIONS",
        description: "After selecting your options, you will click submit, and it should look something like this",
        pathImage: "images/select_page_final.jpg",
        heightImage: 400,
        backgroundColor: Color(0xff203152),
      ),
    );
    slides.add(
      new Slide(
        title: "ROSTER",
        description:
        "Once you get to this page, make sure to select the 'Download Roster' option at the top right of your screen. You will need to re-download the roster everytime you add/remove people from your REC.",
        pathImage: "images/download_roster_button.jpg",
        heightImage: 400,
        backgroundColor: Color(0xff9932CC),
      ),
    );
    slides.add(
      new Slide(
        title: "MANUAL ENTRY",
        description:
        "You can also manually enter a person's information by tapping the 'Manual Entry' option on the top left.",
        pathImage: "images/manual_entry_button.jpg",
        heightImage: 400,
        backgroundColor: Color(0xff9932CC),
      ),
    );
    slides.add(
      new Slide(
        title: "MANUAL ENTRY",
        description: "On this page, you can manually enter all the information you need about someone's arrival time. There are checks in place to make sure that the data is accurate so you will recieve errors if something is incorrect.",
        pathImage: "images/manual_entry_page.jpg",
        heightImage: 400,
        backgroundColor: Color(0xfff5a623),
      ),
    );
  }

  void onDonePress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('intro', true);
    Navigator.popAndPushNamed(context, "/select");
  }

  @override
  Widget build(BuildContext context) {
    return new IntroSlider(
      slides: this.slides,
      onDonePress: this.onDonePress,
      onSkipPress: this.onDonePress
    );
  }
}
