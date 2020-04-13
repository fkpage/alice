import 'package:alice/core/alice_core.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';

import 'alice_call_error_widger.dart';
import 'alice_call_overview_widget.dart';
import 'alice_call_request_widget.dart';
import 'alice_call_response_widget.dart';

class AliceCallDetailsScreen extends StatefulWidget {
  final AliceHttpCall call;
  final AliceCore core;

  AliceCallDetailsScreen(this.call, this.core)
      : assert(call != null, "call can't be null"),
        assert(core != null, "core can't be null");

  @override
  _AliceCallDetailsScreenState createState() => _AliceCallDetailsScreenState();
}

class _AliceCallDetailsScreenState extends State<AliceCallDetailsScreen>
    with SingleTickerProviderStateMixin {
  AliceHttpCall get call => widget.call;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(brightness: widget.core.brightness),
      child: StreamBuilder<List<AliceHttpCall>>(
        stream: widget.core.callsSubject,
        initialData: [widget.call],
        builder: (context, callsSnapshot) {
          if (callsSnapshot.hasData) {
            AliceHttpCall call = callsSnapshot.data.firstWhere(
                (snapshotCall) => snapshotCall.id == widget.call.id,
                orElse: null);
            if (call != null) {
              return _buildMainWidget();
            } else {
              return _buildErrorWidget();
            }
          } else {
            return _buildErrorWidget();
          }
        },
      ),
    );
  }

  Widget _buildMainWidget() {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          key: Key('share_key'),
          onPressed: () {
            Share.share(_getSharableResponseString(),
                subject: 'Request Details');
          },
          child: Icon(Icons.share),
        ),
        appBar: AppBar(
          bottom: TabBar(tabs: _getTabBars()),
          title: Text('Alice - HTTP Inspector - Details'),
        ),
        body: TabBarView(
          children: _getTabBarViewList(),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(child: Text("Failed to load data"));
  }

  String _getSharableResponseString() {
    return '${widget.call.getCallLog()}\n\n${widget.call.getCurlCommand()}';
  }

  List<Widget> _getTabBars() {
    List<Widget> widgets = List();
    widgets.add(Tab(icon: Icon(Icons.info_outline), text: "Overview"));
    widgets.add(Tab(icon: Icon(Icons.arrow_upward), text: "Request"));
    widgets.add(Tab(icon: Icon(Icons.arrow_downward), text: "Response"));
    widgets.add(Tab(
      icon: Icon(Icons.warning),
      text: "Error",
    ));
    return widgets;
  }

  List<Widget> _getTabBarViewList() {
    List<Widget> widgets = List();
    widgets.add(AliceCallOverviewWidget(widget.call));
    widgets.add(AliceCallRequestWidget(widget.call));
    widgets.add(AliceCallResponseWidget(widget.call));
    widgets.add(AliceCallErrorWidget(widget.call));
    return widgets;
  }
}
