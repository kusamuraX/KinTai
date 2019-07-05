import 'dart:async';
import 'package:teskin/sheetObj/sheetJsonObj.dart';
import 'package:googleapis/sheets/v4.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;


const String spreadsheetId = '';

GoogleSignIn _googleSignIn = new GoogleSignIn(
  scopes: [SheetsApi.SpreadsheetsScope],
);

signIn() async{
  print('sign in start.');
  try {
    await _googleSignIn.signIn().catchError((error) => {
      print(error)
    });

    final headers = await _googleSignIn.currentUser.authHeaders;
    final _client = new AuthHttpClient(headers);

    var sheetApi = new SheetsApi(_client);
//
//    var getValue = await sheetApi.spreadsheets.values.get(spreadsheetId, 'sheet1!B2');
//
//    getValue.values.forEach((list) => {
//      list.forEach((str) => {
//        print(str)
//      })
//    });

    UpdateSpreadsheetProperties updateSpreadsheetProperties = new UpdateSpreadsheetProperties();
    updateSpreadsheetProperties.setTitle('sheetEX');

    BatchRequest request = new BatchRequest();
    request.setRequestProperties(updateSpreadsheetProperties);

    BatchUpdateValuesRequest batchUpdateValuesRequest = new BatchUpdateValuesRequest();
    var range = ValueRange.fromJson(request.toJsonMap());

    sheetApi.spreadsheets.values.batchUpdate(batchUpdateValuesRequest, spreadsheetId);

    UpdateSheetPropertiesRequest updateSheetReq = UpdateSheetPropertiesRequest();
    updateSheetReq.properties.title = '';

    var inputValues = [
      [
        'test input'
      ]
    ];

    var inputValueRange = new ValueRange();
    inputValueRange.values = inputValues;

    sheetApi.spreadsheets.values.update(inputValueRange, spreadsheetId, 'sheet1!B3', valueInputOption:'RAW');


  } catch (error) {
    print(error);
  }
}

class AuthHttpClient extends http.IOClient {
  Map<String, String> _headers;
  AuthHttpClient(this._headers) : super();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return super.send(request..headers.addAll(_headers));
  }
}