import 'dart:async';
import 'package:googleapis/sheets/v4.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dateInfo.dart';


const String spreadsheetId = '-';

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
//    var sheetContentsClearReq = new Request();
//    UpdateCellsRequest _updateCellsRequest = new UpdateCellsRequest();
//    _updateCellsRequest.fields = 'userEnteredValue';
//    _updateCellsRequest.range = new GridRange();
//    _updateCellsRequest.range.sheetId = 0; // sheet index
//    sheetContentsClearReq.updateCells = _updateCellsRequest;
//    batchUpdateSpreadsheetRequest.requests.add(sheetContentsClearReq);

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
//    sheetApi.spreadsheets.batchUpdate(batchUpdateSpreadsheetRequest, spreadsheetId);


    List<List<String>> dataList = await new DateInfo().getInputInfo(DateTime.now().month);
//
//    var inputValueRange = new ValueRange();
//    inputValueRange.values = dataList;
//
//    sheetApi.spreadsheets.values.update(inputValueRange, spreadsheetId, 'sheet1!A2', valueInputOption:'RAW');


    BatchUpdateValuesRequest request = new BatchUpdateValuesRequest();
    request.valueInputOption = 'RAW';

    var inputList = new List<ValueRange>();

    // 日付
    var inputDayValue = new ValueRange();
    inputDayValue.range = "sheet1!A2";
    inputDayValue.majorDimension = "COLUMNS";
    inputDayValue.values = new List<List<String>>();
    var dayList = new List<String>();

    // 曜日
    var inputWeekValue = new ValueRange();
    inputWeekValue.range = "sheet1!C2";
    inputWeekValue.majorDimension = "COLUMNS";
    inputWeekValue.values = new List<List<String>>();
    var weekList = new List<String>();

    // 区分
    var inputTypeValue = new ValueRange();
    inputTypeValue.range = "sheet1!E2";
    inputTypeValue.majorDimension = "COLUMNS";
    inputTypeValue.values = new List<List<String>>();
    var typeList = new List<String>();

    // 出社
    var inputStValue = new ValueRange();
    inputStValue.range = "sheet1!J2";
    inputStValue.majorDimension = "COLUMNS";
    inputStValue.values = new List<List<String>>();
    var stList = new List<String>();

    // 退社
    var inputEdValue = new ValueRange();
    inputEdValue.range = "sheet1!M2";
    inputEdValue.majorDimension = "COLUMNS";
    inputEdValue.values = new List<List<String>>();
    var edList = new List<String>();

    // 備考
    var inputEtcValue = new ValueRange();
    inputEtcValue.range = "sheet1!P2";
    inputEtcValue.majorDimension = "COLUMNS";
    inputEtcValue.values = new List<List<String>>();
    var etcList = new List<String>();

    for(List d in dataList) {
      dayList.add(d[0]);
      weekList.add(d[1]);
      typeList.add(d[2]);
      stList.add(d[3]);
      edList.add(d[4]);
      etcList.add(d[5]);
    }

    inputDayValue.values.add(dayList);
    inputWeekValue.values.add(weekList);
    inputTypeValue.values.add(typeList);
    inputStValue.values.add(stList);
    inputEdValue.values.add(edList);
    inputEtcValue.values.add(etcList);

    inputList.add(inputDayValue);
    inputList.add(inputWeekValue);
    inputList.add(inputTypeValue);
    inputList.add(inputStValue);
    inputList.add(inputEdValue);
    inputList.add(inputEtcValue);
    request.data = inputList;

    sheetApi.spreadsheets.values.batchUpdate(request, spreadsheetId);

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

