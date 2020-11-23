import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:band_news/services/socket_service.dart';

class StatusPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    final socketService = Provider.of<SocketService>(context);
    
    void emitirMessage(){
      socketService.socket.emit('emitir-mensaje', {
        'nombre': 'Flutter',
        'mensjae': 'Nuevo Mensaje'
      });
    }
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('ServerStatus: ${ socketService.serverStatus }')
          ],
        ),
     ),
     floatingActionButton: FloatingActionButton(
       child: Icon( Icons.message ),
       onPressed: () {
         emitirMessage();
       },
     ),
   );
   
   
  }
}