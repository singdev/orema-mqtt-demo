import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:oremamqttdemo/home/component/token_input_dialog.dart';
import 'package:oremamqttdemo/home/home_bloc.dart';
import 'package:oremamqttdemo/repository/mqtt_repository.dart';

class InitialScreen extends StatefulWidget {
  final MqttServerClient client;

  final bool IS_CONNECTED;
  final String COUNTER_NUMBER;
  final String PROTOCOL_VERSION;
  final String SOFTWARE_VERSION;
  final String TARIF_INDEX;

  const InitialScreen(
      {Key key,
      this.COUNTER_NUMBER = "",
      this.PROTOCOL_VERSION = "",
      this.SOFTWARE_VERSION = "",
      this.TARIF_INDEX = "",
      this.IS_CONNECTED = false,
      this.client})
      : super(key: key);

  @override
  _InitialScreenState createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  final TextEditingController _ipAddressController =
      new TextEditingController();
  final TextEditingController _tokenController = new TextEditingController();

  bool errorToken = false;

  Future<void> showConnexionDialog() {
    showDialog(
        context: context,
        builder: (c) => AlertDialog(
              title: Text("Connection"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _ipAddressController,
                    decoration: InputDecoration(hintText: "Ip Address"),
                  )
                ],
              ),
              actions: [
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                    BlocProvider.of<HomeBloc>(context).add(ConnectButtonPressed(
                        ipAddress: _ipAddressController.text));
                  },
                  child: Text("CONNECT"),
                ),
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("ANNULER"),
                ),
              ],
            ));
  }

  Future<void> showRechargeDialog() {
    showDialog(
        context: context,
        builder: (c) => TokenInputDialog(
          controller: _tokenController,
          onRecharge: () {
            Navigator.pop(context);
            BlocProvider.of<HomeBloc>(context).add(
                RechargerButtonPressed(
                    client: widget.client,
                    token: _tokenController.text));
          },
        ));
  }

  void onDisconnected(){
    BlocProvider.of<HomeBloc>(context).add(
        DisconnectedBroker(
            client: widget.client));
  }

  @override
  void initState() {
    super.initState();
    _ipAddressController.text = MQTTRepository.DEFAULT_IP_ADDRESS;

    if(widget.client != null){
      widget.client.onDisconnected = onDisconnected;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: widget.IS_CONNECTED ? Colors.green : Colors.red,
            ),
            title: Text(
              widget.IS_CONNECTED ? "Connected" : "Disconnect",
              style: TextStyle(fontSize: 18.0, color: Colors.grey),
            ),
            trailing: IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                showConnexionDialog();
              },
            ),
          ),
          Divider(),
          ListTile(
            title: Text("Counter Number"),
            subtitle: Text("${widget.COUNTER_NUMBER}"),
          ),
          ListTile(
            title: Text("Protocol Version"),
            subtitle: Text("${widget.PROTOCOL_VERSION}"),
          ),
          ListTile(
            title: Text("Software Version"),
            subtitle: Text("${widget.SOFTWARE_VERSION}"),
          ),
          ListTile(
            title: Text("Tarif Index"),
            subtitle: Text("${widget.TARIF_INDEX}"),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: RaisedButton(
              onPressed: !widget.IS_CONNECTED
                  ? null
                  : () {
                      //TODO update event
                      BlocProvider.of<HomeBloc>(context)
                          .add(UpdateButtonPressed(client: widget.client));
                    },
              child: Text("Update"),
            ),
          ),
          RaisedButton(
            onPressed: !widget.IS_CONNECTED
                ? null
                : () {
                    showRechargeDialog();
                  },
            child: Text("Recharge"),
          ),
        ],
      ),
    );
  }
}
