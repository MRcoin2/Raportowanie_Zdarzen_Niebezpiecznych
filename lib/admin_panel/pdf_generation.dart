import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:raportowanie_zdarzen_niebezpiecznych/main_form/database_communication.dart';
import 'package:htmltopdfwidgets/htmltopdfwidgets.dart';

Future<void> printReport(Report report) async {
  String htmlContent = '''
                        <html>
                            <head>
                                <meta content="text/html; charset=UTF-8" http-equiv="content-type">
                            </head>
                            <body class="c5 doc-content">
                                <h2>${report.incidentData['category']}</h2>
                                <p>data zgłoszenia: ${DateFormat('dd.MM.yyyy').format(report.reportTimestamp)}</p>
                                <h3>Dane zgłaszającego:</h3>
                                <p>Imię Nazwizko: &nbsp;${report.personalData['name']} ${report.personalData['surname']}</p>
                                <p>Status:&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; ${report.personalData['status']}</p>
                                <p>Sąd:&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; ${report.personalData['affiliation']}</p>
                                <p>e-mail:&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; ${report.personalData['email']}</p>
                                <p>telefon: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;${report.personalData['phone']}</p>
                                <p>&nbsp;</p>
                                <h3>Dane zdarzenia:</h3>
                                <p>lokalizacja:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;${report.incidentData['location']}</p>
                                <p>data zdarzenia:&nbsp;&nbsp;${DateFormat('dd.MM.yyyy, hh:mm').format(DateTime.fromMillisecondsSinceEpoch(report.incidentData['incident timestamp'].seconds * 1000))}</p>
                                <p>opis:
                                ${report.incidentData['description']}</p>
                            </body>
                        </html>
                        ''';
  final newpdf = Document();
  List<Widget> widgets = await HTMLToPdf().convert(htmlContent,
      defaultFont: await PdfGoogleFonts.robotoLight(),
      fontFallback: [
        await PdfGoogleFonts.robotoBold(),
        await PdfGoogleFonts.robotoItalic()
      ]);
  newpdf.addPage(
    MultiPage(
      maxPages: 200,
      build: (context) {
        return widgets;
      },
    ),
  );
  //TODO find a better way to generate the PDF (maybe use a remote API)
  await Printing.layoutPdf(onLayout: (format) => newpdf.save());
}
