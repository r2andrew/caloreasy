import 'dart:convert';

import 'package:http/http.dart' as http;

class CoachpilotService {

  Function loadResults;

  CoachpilotService(void Function(bool loaded, String response) this.loadResults);

  void getChefsResponse(String question) async {

  loadResults(false);

  var response = await http.post(
      Uri.parse('http://192.168.0.130:5000/coachpilot/'),
      headers: {
        "Content-Type" : "application/x-www-form-urlencoded"
      },
      encoding: Encoding.getByName('utf-8'),
      body: {'question' : question }
    );
    var data = jsonDecode(response.body);
    loadResults(true, data['result']);
  }
}