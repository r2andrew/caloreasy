import 'dart:convert';

import 'package:http/http.dart' as http;

class CoachpilotService {

  Function loadResults;

  CoachpilotService(void Function(bool loaded, String response) this.loadResults);

  void getChefsResponse(String question, http.Client client) async {

  loadResults(false);

  try {
    var response = await client.post(
      Uri.parse('http://81.98.10.9/coachpilot/'),
      headers: {
        "Content-Type" : "application/x-www-form-urlencoded"
      },
      encoding: Encoding.getByName('utf-8'),
      body: {'question' : question }
    );

    var data = jsonDecode(response.body);
    loadResults(true, data['result']);

    } catch (e) {
    loadResults(true, 'API error occurred: $e');
    }
  }
}