import 'dart:async';
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

    UpdateSpreadsheetPropertiesRequest();

//    var getValue = await sheetApi.spreadsheets.values.get(spreadsheetId, 'sheet1!B2');
//
//    getValue.values.forEach((list) => {
//      list.forEach((str) => {
//        print(str)
//      })
//    });

//    UpdateSpreadsheetProperties updateSpreadsheetProperties = new UpdateSpreadsheetProperties();
//    updateSpreadsheetProperties.setTitle('sheetEX');
//
//    BatchRequest request = new BatchRequest();
//    request.setRequestProperties(updateSpreadsheetProperties);



//    BatchUpdateValuesRequest batchUpdateValuesRequest = new BatchUpdateValuesRequest();
//    var range = ValueRange.fromJson(request.toJsonMap());
//

    BatchUpdateSpreadsheetRequest batchUpdateSpreadsheetRequest = new BatchUpdateSpreadsheetRequest();
    batchUpdateSpreadsheetRequest.requests = new List();

//    // ファイル名
//    var fileNameReq = new Request();
//    fileNameReq.updateSpreadsheetProperties = new UpdateSpreadsheetPropertiesRequest();
//    fileNameReq.updateSpreadsheetProperties.properties = new SpreadsheetProperties();
//    fileNameReq.updateSpreadsheetProperties.properties.title = 'changeTest';
//    fileNameReq.updateSpreadsheetProperties.fields = '*';
//    batchUpdateSpreadsheetRequest.requests.add(fileNameReq);

    // シート追加
//    var sheetAddReq = new Request();
//    AddSheetRequest _addSheetRequest = new AddSheetRequest();
//    _addSheetRequest.properties = new SheetProperties();
//    _addSheetRequest.properties.title = 'newSheet';
//    sheetAddReq.addSheet = _addSheetRequest;
//    batchUpdateSpreadsheetRequest.requests.add(sheetAddReq);

    // シート内容のクリア
    var sheetContentsClearReq = new Request();
    UpdateCellsRequest _updateCellsRequest = new UpdateCellsRequest();
    _updateCellsRequest.fields = 'userEnteredValue';
    _updateCellsRequest.range = new GridRange();
    _updateCellsRequest.range.sheetId = 0; // sheet index
    sheetContentsClearReq.updateCells = _updateCellsRequest;
    batchUpdateSpreadsheetRequest.requests.add(sheetContentsClearReq);

    // シートのコピー
    var sheetCopyReq = new Request();

    // シート名
//    var sheetTitleReq = new Request();
//    UpdateSheetPropertiesRequest updateSheetPropertiesRequest = new UpdateSheetPropertiesRequest();
//    updateSheetPropertiesRequest.properties = new SheetProperties();
//    updateSheetPropertiesRequest.properties.title = 'newSheetName';
//    updateSheetPropertiesRequest.properties.index = 0;
//    updateSheetPropertiesRequest.fields = "*";
//    sheetTitleReq.updateSheetProperties = updateSheetPropertiesRequest;
//    batchUpdateSpreadsheetRequest.requests.add(sheetTitleReq);

    // batch update
    sheetApi.spreadsheets.batchUpdate(batchUpdateSpreadsheetRequest, spreadsheetId);

    var inputValues = [
      [
        'test input2'
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