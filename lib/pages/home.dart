import 'dart:io';

import 'package:provider/provider.dart';
import 'package:band_news/services/socket_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

import 'package:band_news/models/band.dart';

class HomePage extends StatefulWidget {
  
  @override
  _HomePageState createState() => _HomePageState();
}
class _HomePageState extends State<HomePage>{

  List<Band> bands = [
    // Band(id: '1', name: 'One', votes: 5),
    // Band(id: '2', name: 'Two', votes: 15),
    // Band(id: '3', name: 'Three', votes: 25),
    // Band(id: '4', name: 'Four', votes: 35),
  ];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('active-bands', _handleActiveBands);

    super.initState();
  }

  _handleActiveBands( dynamic payload ){
    this.bands = (payload as List)
      .map( (band) => Band.fromMap(band))
      .toList();
      
    setState(() {});
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context);
    socketService.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('BandNames', style: TextStyle( color: Colors.black87 ) ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: <Widget>[
          Container(
            margin: EdgeInsets.only( right: 10 ),
            child: ( socketService.serverStatus == ServerStatus.Online )
              ? Icon( Icons.check_circle, color: Colors.blue[300] )
              : Icon( Icons.offline_bolt, color: Colors.red ),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[

          _showGraph(),

          Expanded(
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: (context, i) => _bandTile(bands[i])
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon( Icons.add ),
        elevation: 1,
        onPressed: () => addNewBand(),
      ),
    );
  }

  Widget _bandTile(Band band) {

    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
        key: Key(band.id),
        direction: DismissDirection.startToEnd,
        onDismissed: ( _ ) => socketService.socket.emit('delete-band', { 'id': band.id }),
        background: Container(
          padding: EdgeInsets.only(left: 8.0),
          color: Colors.red,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Delete Band', style: TextStyle( color: Colors.white )),
          ),
        ),
        child: ListTile(
        leading: CircleAvatar(
          child: Text( band.name.substring(0,2) ),
          backgroundColor: Colors.blue[100], 
        ),
        title: Text( band.name ),
        trailing: Text('${ band.votes }', style: TextStyle( fontSize: 20 ),),
        onTap: () => socketService.socket.emit('vote-band', { 'id': band.id }),
      ),
    );
  }

  addNewBand(){
    final textController = new TextEditingController();

    if( Platform.isAndroid ){
      return showDialog(
        context: context,
        builder: ( _ ) => AlertDialog(
            title: Text('New band name:'),
            content: TextField(
              controller: textController,
            ),
            actions: <Widget>[
              MaterialButton(
                child: Text('Add'),
                elevation: 5,
                textColor: Colors.blue,
                onPressed: () => addBandToList(textController.text),
              )
            ],
          )
      );
    }

    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
          title: Text('New band name:'),
          content: CupertinoTextField(
            controller: textController,
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text('Add'),
              onPressed: () => addBandToList( textController.text ),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: Text('Dismiss'),
              onPressed: () => Navigator.pop(context),
            )
          ],
        )
    );
    
  }

  void addBandToList(String name) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    if(name.length > 1){
      socketService.socket.emit('add-band', { 'name': name });
    }

    Navigator.pop(context);
  }

  Widget _showGraph(){
    Map<String, double> dataMap = new Map();
    dataMap.putIfAbsent('prueba', () => 0.toDouble());
    int initial = 0;
    bands.forEach((band) {
      dataMap.putIfAbsent( band.name , () => band.votes.toDouble());
      
      if(initial == 0) {
        initial = 1;
        dataMap.remove('prueba');
      }
    });
    return Container(
      padding: EdgeInsets.only(top: 15, bottom: 10),
      width: double.infinity,
      height: 200,
      child: PieChart(
        dataMap: dataMap,
        animationDuration: Duration(milliseconds: 800),
        initialAngleInDegree: 0,
        ringStrokeWidth: 32,
        chartType: ChartType.ring,
        centerText: "BAND",
        legendOptions: LegendOptions(
          showLegendsInRow: false,
          legendPosition: LegendPosition.right,
          showLegends: true,
          legendTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        chartValuesOptions: ChartValuesOptions(
          showChartValueBackground: true,
          showChartValues: true,
          showChartValuesInPercentage: true,
          showChartValuesOutside: false,
          decimalPlaces: 0,
        ),
      )
    );
  }
}