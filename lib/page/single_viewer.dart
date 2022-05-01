import 'package:flutter/material.dart';
import 'package:opendata/api/api.dart';
import 'package:opendata/widget/viewer.dart';

class SingleViewerPage extends StatefulWidget {
  final ApiInterface api;

  const SingleViewerPage({Key? key, required this.api}) : super(key: key);

  @override
  State<SingleViewerPage> createState() => _SingleViewerPageState();
}

class _SingleViewerPageState extends State<SingleViewerPage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.api.displayName)),
      body: FutureBuilder(
        future: widget.api.records(limit: 100),
        builder: (_, snap) {
          if (!snap.hasData && !snap.hasError) {
            return Center(child: SizedBox(width: 200, height: 200, child: CircularProgressIndicator()));
          } else if (!snap.hasData && snap.hasError) {
            return Center(child: Text("An Error occured : ${snap.error}"),);
          } else if (snap.hasData && !(snap.data! is ApiResult)) {
            return Center(child: Text("An Internal Error occured, Wrong return type of Future !"));
          }
          var apiResult = snap.data as ApiResult;

          return GraphViewer(api: widget.api, apiResult: apiResult);
        },
      ),
    );
  }
}