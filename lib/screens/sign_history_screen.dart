import 'package:fingerprint/dbhelper.dart';
import 'package:fingerprint/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class SignHistoryScreen extends StatefulWidget {
  const SignHistoryScreen({super.key});

  @override
  State<SignHistoryScreen> createState() => _SignHistoryScreenState();
}

class _SignHistoryScreenState extends State<SignHistoryScreen> {
  DateTime? _from = null;
  @override
  Widget build(BuildContext context) {
    var tm = ThemeServices().theme;
    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).primaryColor,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: ThemeServices().theme == ThemeMode.dark
                  ? Colors.white
                  : Colors.black,
            ),
            onPressed: () {
              Get.back();
            },
          ),
          elevation: 0,
          actions: [
            IconButton(
                onPressed: () async {
                  if (_from == null) {
                    _from = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2015, 8),
                      lastDate: DateTime(2101),
                      builder: (context, child) => Theme(
                          data: ThemeServices().theme == ThemeMode.dark
                              ? ThemeData.dark().copyWith(
                                  colorScheme: ColorScheme.dark(
                                    primary: Colors.white,
                                    onPrimary: Colors.black,
                                    surface: Colors.black,
                                    onSurface: Colors.white,
                                  ),
                                )
                              : ThemeData.light().copyWith(
                                  colorScheme: ColorScheme.light(
                                    primary: Colors.black,
                                    onPrimary: Colors.white,
                                    surface: Colors.white,
                                    onSurface: Colors.black,
                                  ),
                                ),
                          child: child!),
                    );
                  } else {
                    _from = null;
                  }
                  setState(() {});
                },
                icon: Icon(
                    _from == null
                        ? Icons.filter_list_alt
                        : Icons.filter_alt_off_rounded,
                    size: 24,
                    color: ThemeServices().theme == ThemeMode.dark
                        ? Colors.white
                        : Colors.black))
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                'History',
                style: TextStyle(
                    color: ThemeServices().theme == ThemeMode.dark
                        ? Colors.white
                        : Colors.black,
                    fontSize: 30,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
              ),
              FutureBuilder(
                future: DBHelper.GetAll(from: _from),
                builder: (context, snapshot) => snapshot.connectionState ==
                        ConnectionState.waiting
                    ? Center(child: CircularProgressIndicator())
                    : snapshot.data!.length == 1
                        ? Center(
                            child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.22),
                              Icon(
                                Icons.filter_alt_off_rounded,
                                color: ThemeServices().theme == ThemeMode.dark
                                    ? Color.fromRGBO(239, 239, 240, 0.3)
                                    : Color.fromRGBO(0, 0, 0, 0.4),
                                size: 120,
                              ),
                              Text(
                                'No Date Matches your Filter..!',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: ThemeServices().theme == ThemeMode.dark
                                      ? Color.fromRGBO(239, 239, 240, 0.3)
                                      : Color.fromRGBO(0, 0, 0, 0.4),
                                ),
                              ),
                            ],
                          ))
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Table(
                                border: TableBorder.all(
                                    color: tm == ThemeMode.dark
                                        ? Colors.white
                                        : Colors.black),
                                columnWidths: const <int, TableColumnWidth>{
                                  0: FlexColumnWidth(),
                                  1: FlexColumnWidth(),
                                  2: FlexColumnWidth(),
                                },
                                defaultVerticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                children: snapshot.data!
                                    .map(
                                      (e) => e.id == 0
                                          ? TableRow(
                                              children: <Widget>[
                                                _createTableCell('Date', tm,
                                                    isBold: true),
                                                _createTableCell(
                                                    e.SigninDate.toString(), tm,
                                                    isBold: true),
                                                _createTableCell(
                                                    e.SignoutDate.toString(),
                                                    tm,
                                                    isBold: true),
                                              ],
                                            )
                                          : TableRow(
                                              children: <Widget>[
                                                _createTableCell(
                                                    DateFormat.yMd().format(
                                                        DateTime.parse(
                                                            e.SigninDate)),
                                                    tm,
                                                    isBold: false),
                                                _createTableCell(
                                                    DateFormat.jm().format(
                                                        DateTime.parse(
                                                            e.SigninDate)),
                                                    tm,
                                                    isBold: false),
                                                _createTableCell(
                                                    e.SignoutDate == 'null'
                                                        ? ''
                                                        : DateFormat.jm().format(
                                                            DateTime.parse(
                                                                e.SignoutDate)),
                                                    tm,
                                                    isBold: false),
                                              ],
                                            ),
                                    )
                                    .toList()),
                          ),
              )
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                      backgroundColor: Theme.of(context).primaryColor,
                      content: Text(
                        'Are you sure you want to delete history?',
                        style: TextStyle(
                            color: ThemeServices().theme == ThemeMode.dark
                                ? Colors.white
                                : Colors.black,
                            fontSize: 25),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              DBHelper.empty();
                            });
                            Navigator.of(ctx).pop();
                          },
                          child: Text(
                            'Yes',
                            style: TextStyle(
                                color: ThemeServices().theme == ThemeMode.dark
                                    ? Colors.white
                                    : Colors.black),
                          ),
                        ),
                        TextButton(
                            onPressed: () {
                              Navigator.of(ctx).pop();
                            },
                            child: Text(
                              'No',
                              style: TextStyle(
                                  color: ThemeServices().theme == ThemeMode.dark
                                      ? Colors.white
                                      : Colors.black),
                            )),
                      ],
                    ));
          },
          child: const Icon(Icons.auto_delete),
        ));
  }

  Widget _createTableCell(content, themeMode, {required bool isBold}) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Center(
          child: Text(
        content,
        style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: themeMode == ThemeMode.dark ? Colors.white : Colors.black),
      )),
    );
  }
}
