import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;


enum ServerStatus {
  Online, Offline, Connecting
}

class SocketService with ChangeNotifier {
  
  ServerStatus _serverStatus = ServerStatus.Connecting;
  IO.Socket _socket;

  ServerStatus get serverStatus => this._serverStatus;
  IO.Socket get socket => this._socket;

  SocketService() {
    this._initConfig();
  }

  void _initConfig() {

    this._socket = IO.io('http://192.168.0.13:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    this._socket.on("connect", (_) {
      this._serverStatus = ServerStatus.Online;
      notifyListeners();
    });
    this._socket.on("disconnect", (_) {
      this._serverStatus = ServerStatus.Offline;
      notifyListeners();
    });

    // this._socket.on('nuevo-mensaje', ( payload ) {
    //   print('Server: ' + payload['nombre']);
    //   print(payload.containsKey('mensaje2') ? payload['mensaje2'] : 'no hay');
    // });

  }

}