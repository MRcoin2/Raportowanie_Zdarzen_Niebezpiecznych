import 'dart:convert';
import 'dart:typed_data';
import 'package:printing/printing.dart';
import 'package:raportowanie_zdarzen_niebezpiecznych/main_form/database_communication.dart';
import 'package:http/http.dart' as http;

import '../authentication/secrets/api_key.dart';

Future<Uint8List> generatePdf(Report report) async {
  var response = await http.post(Uri.parse('${API_URL}/generate-pdf'),
      body: json.encode({
        'api_key': API_KEY,
        'data': {
          "report timestamp":
              report.reportTimestamp.millisecondsSinceEpoch / 1000,
          "personal data": {
            "phone": report.personalData['phone'],
            "affiliation": report.personalData['affiliation'],
            "name": report.personalData['name'],
            "status": report.personalData['status'],
            "email": report.personalData['email'],
            "surname": report.personalData['surname']
          },
          "incident data": {
            "incident timestamp": report
                    .incidentData['incident timestamp'].millisecondsSinceEpoch /
                1000,
            "time": report.incidentData['time'],
            "category": report.incidentData['category'],
            "location": report.incidentData['location'],
            "date": report.incidentData['date'],
            "description": report.incidentData['description']
          }
        },
      }));
  if (response.statusCode == 200) {
    return response.bodyBytes;
  }
  else {
    return Uint8List(0);
  }
}

Future<void> printReport(Report report) async {
  await Printing.layoutPdf(onLayout: (format) => generatePdf(report));
}
