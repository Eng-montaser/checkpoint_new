import 'package:flutter/cupertino.dart';

class QuizData {
  String questions;
  bool answer;
  bool? yesExplanation;
  bool? noExplanation;
  TextEditingController? explanationText;
  QuizData(
      {required this.questions,
      required this.answer,
      this.yesExplanation,
      this.noExplanation,
      this.explanationText});
}

class QuizDataBody {
  String? encounter_incident;
  String? doors_closed;
  String? doors_closed_notes;
  String? back_of_house;
  String? back_of_house_notes;
  String? checkout_lat;
  String? checkout_long;
  QuizDataBody(
      {this.checkout_lat,
      this.checkout_long,
      this.back_of_house,
      this.back_of_house_notes,
      this.doors_closed,
      this.doors_closed_notes,
      this.encounter_incident});
  getQuizDataBody() {
    return {
      "encounter_incident": encounter_incident,
      "doors_closed": doors_closed,
      "doors_closed_notes": doors_closed_notes,
      "back_of_house": back_of_house,
      "back_of_house_notes": back_of_house_notes,
      "checkout_lat": checkout_lat,
      "checkout_long": checkout_long,
    };
  }
}
