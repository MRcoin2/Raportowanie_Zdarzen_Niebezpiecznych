import 'dart:convert';
import 'dart:typed_data';
import 'package:printing/printing.dart';
import 'package:raportowanie_zdarzen_niebezpiecznych/main_form/database_communication.dart';
import 'package:http/http.dart' as http;

import '../authentication/secrets/api_key.dart';

Future<Uint8List> generateSingleReportPdf(Report report) async {
  var response = await http.post(Uri.https(API_URL,'generate-pdf'),
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
          },
          "images": report.imageUrls,
        },
      }));
  if (response.statusCode == 200) {
    return response.bodyBytes;
  }
  else {
    throw Exception('Failed to generate PDF');
  }
}

Future<Uint8List> generatePeriodicReportPdf(Map<String,int> categoryCounts) async{
  var response = await http.post(Uri.https(API_URL,'generate-periodic-pdf'),
      body: json.encode({
        'api_key': API_KEY,
        'category_counts': categoryCounts,
      }));
  if (response.statusCode == 200) {
    return response.bodyBytes;
  }
  else {
    throw Exception('Failed to generate PDF');
  }
}

// TODO make these functions general
Future<void> printReport(Report report) async {
  await Printing.layoutPdf(onLayout: (format) => generateSingleReportPdf(report));
}

// download pdf
Future<void> downloadReport(Report report) async {
  await Printing.sharePdf(
      bytes: await generateSingleReportPdf(report), filename: 'report.pdf');
}

Future<void> printPeriodicReport(Map <String,int> categoryCounts) async {
  await Printing.layoutPdf(onLayout: (format) => generatePeriodicReportPdf(categoryCounts));
}

Future<void> downloadPeriodicReport(Map <String,int> categoryCounts) async {
  await Printing.sharePdf(
      bytes: await generatePeriodicReportPdf(categoryCounts), filename: 'report.pdf');
}