import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:oremamqttdemo/home/component/initial_screen.dart';
import 'package:oremamqttdemo/home/home_bloc.dart';
import 'package:oremamqttdemo/repository/mqtt_repository.dart';
import 'package:toast/toast.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String counterNumber = "";
  String protocolVersion = "";
  String softwareVersion = "";
  String tarifIndex = "";

  String topicPublished = "";
  String message = "";
  String operation = "";

  HomeBloc bloc = HomeBloc(HomeInitialState());

  String publishedToken = "";

  MqttServerClient client;

  void messageArrive() {
    client.published.listen((MqttPublishMessage event) {
      print(event.toString());
      if (topicPublished == "client/session" && message == "start" &&
          operation == "write") {
        if (event.toString().contains("/M07C123") ||
            message.toString().toLowerCase().contains("nack")) {
          bloc.add(Publish(topic: "client/write", message: publishedToken, client: client));
        }
      } else if (topicPublished == "client/session" && message == "break") {
        if (event.payload.message.toString() == "/M07C123" || event.payload.message.toString() == "nack") {
          //Toast.makeText(this,"session closed",Toast.LENGTH_LONG).show()
        }
      } else if (topicPublished == "client/write") {
        if (event.payload.message.toString().toLowerCase().contains("ack")) {
          //Toast.makeText(this,"write sucess",Toast.LENGTH_LONG).show()
          bloc.add(Publish(topic: "client/read", message: "FFFE", client: client));
        }
      } else if (topicPublished == "client/read" && message == "FFFE") {
        switch (event.payload.message.toString()) {
          case "01":
            Toast.show("Token accepté", context, duration: Toast.LENGTH_LONG);
            break;
          case "02":
            Toast.show("1ndKCT", context, duration: Toast.LENGTH_LONG);
            break;
          case "03":
            Toast.show("2ndKCT", context, duration: Toast.LENGTH_LONG);
            break;
          case "04":
            Toast.show("Overflow Error", context, duration: Toast.LENGTH_LONG);
            break;
          case "05":
            Toast.show("keyTpe Error", context, duration: Toast.LENGTH_LONG);
            break;
          case "06":
            Toast.show("Format Error", context, duration: Toast.LENGTH_LONG);

            break;
          case "07":
            Toast.show("Range Error", context, duration: Toast.LENGTH_LONG);

            break;
          case "08":
            Toast.show("Function Error", context, duration: Toast.LENGTH_LONG);

            break;
          case "09":
            Toast.show("Old Error", context, duration: Toast.LENGTH_LONG);

            break;
          case "0A":
            Toast.show("Token utilisé", context, duration: Toast.LENGTH_LONG);

            break;
          case "0B":
            Toast.show(
                "Key Expired Error", context, duration: Toast.LENGTH_LONG);

            break;
          case "0C":
            Toast.show("DDTK Error", context, duration: Toast.LENGTH_LONG);

            break;
          case "0D":
            Toast.show(
                "Token n'est pas valide", context, duration: Toast.LENGTH_LONG);

            break;
          case "0E":
            Toast.show("Mfr Code Error", context, duration: Toast.LENGTH_LONG);

            break;
          case "0F":
            Toast.show(
                "Token LockoutStatus", context, duration: Toast.LENGTH_LONG);

            break;
          case "10":
            Toast.show(
                "Token Status Not Ready", context, duration: Toast.LENGTH_LONG);
        }
        bloc.add(Publish(topic: "client/session", message: "break", client: client));
      } else if (topicPublished == "client/session" && message == "start" &&
          operation == "read") {
        if (event.payload.message.toString().contains("/M07C123") ||
            event.payload.message.toString().toLowerCase().contains("nack")) {
          //Toast.makeText(this,"session opned",Toast.LENGTH_LONG).show()
          bloc.add(Publish(topic: "client/read", message: "2006", client: client));
        }
      } else if (topicPublished == "client/read" && message == "2006") {
        // Toast.makeText(this,message.toString(),Toast.LENGTH_LONG).show()
          counterNumber = message;
        bloc.add(Publish(topic: "client/read", message: "2000", client: client));
      } else if (topicPublished == "client/read" && message == "2000") {
        // Toast.makeText(this,message.toString(),Toast.LENGTH_LONG).show()
        protocolVersion = message.toString();
        bloc.add(Publish(topic: "client/read", message: "2003", client: client));
      } else if (topicPublished == "client/read" && message == "2003") {
        // Toast.makeText(this,message.toString(),Toast.LENGTH_LONG).show()
        softwareVersion = message;
        bloc.add(Publish(topic: "client/read", message: "2009", client: client));
      }
      else if (topicPublished == "client/read" && message == "2009") {
        // Toast.makeText(this,message.toString(),Toast.LENGTH_LONG).show()
        tarifIndex = event.payload.message.toString();
        bloc.add(Publish(topic: "client/session", message: "break", client: client));
      }
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Smart meter"),
      ),
      body: BlocProvider<HomeBloc>(
        create: (BuildContext context) => bloc,
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeInitialState) {
              client = state.client;
              if (state.operation != "") {
                operation = state.operation;
              }
              message = state.message;
              if (state.topicPublished != "") {
                topicPublished = state.topicPublished;
              }
              if (state.token != "") {
                topicPublished = state.token;
              }
              if (client != null ) {
                messageArrive();
              }
              return InitialScreen(
                  COUNTER_NUMBER: counterNumber,
                  SOFTWARE_VERSION: softwareVersion,
                  PROTOCOL_VERSION: protocolVersion,
                  TARIF_INDEX: tarifIndex,
                  IS_CONNECTED: state.connectToBrokerResult ==
                      ConnectToBrokerResult.SUCCESS,
                  client: state.client);
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}
