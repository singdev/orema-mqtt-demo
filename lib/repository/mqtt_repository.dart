import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

enum ConnectToBrokerResult { SUCCESS, FAILURE, INTERNET_ERROR, CLIENT_ERROR }

class MQTTRepository {
  static const String DEFAULT_IP_ADDRESS = "51.91.182.137";
  static const int TCP_PORT = 1883;
  static const String PREF_UNIQUE_ID = "PREF_UNIQUE_ID";

  Future<MqttServerClient> initClient({String ipAddress}) async {
    final String uniqueID = await getUniqueID();
    MqttServerClient client =
        new MqttServerClient(ipAddress, "MQTTSample$uniqueID");
    client.port = TCP_PORT;
    client.onSubscribed = onSubscribed;
    client.onConnected = onConnected;
    client.onDisconnected = () {
      onDisconnected(client);
    };
    return client;
  }

  Future<ConnectToBrokerResult> connectToBroker(
      {final MqttServerClient client}) async {
    try {
      await client.connect();
    } on NoConnectionException catch (e) {
      // Raised by the client when connection fails.
      print('EXAMPLE::client exception - $e');
      client.disconnect();
      return ConnectToBrokerResult.CLIENT_ERROR;
    } on SocketException catch (e) {
      // Raised by the socket layer
      print('EXAMPLE::socket exception - $e');
      client.disconnect();
      return ConnectToBrokerResult.INTERNET_ERROR;
    }

    /// Check we are connected
    if (client.connectionStatus.state == MqttConnectionState.connected) {
      print('EXAMPLE::Mosquitto client connected');
      return ConnectToBrokerResult.SUCCESS;
    } else {
      /// Use status here rather than state if you also want the broker return code.
      print(
          'EXAMPLE::ERROR Mosquitto client connection failed - disconnecting, status is ${client.connectionStatus}');
      client.disconnect();
      return ConnectToBrokerResult.FAILURE;
    }
  }

  Future<String> getUniqueID() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.containsKey(PREF_UNIQUE_ID)) {
      return sharedPreferences.getString(PREF_UNIQUE_ID);
    } else {
      return await generateUniqueID();
    }
  }

  Future<String> generateUniqueID() async {
    final uuid = Uuid();
    final String v4 = uuid.v4();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(PREF_UNIQUE_ID, v4);
    return v4;
  }

  //Subscribe to topic
  Future<void> subscribe(
      {final MqttServerClient client, final String topic}) async {
      print('EXAMPLE::Subscribing to the $topic topic');
      client.subscribe(topic, MqttQos.atMostOnce);
  }

  Future<void> publish(
      {final MqttServerClient client,
      final String topic,
      final String message}) async {

    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    print('EXAMPLE::Publishing our topic');
    client.publishMessage(topic, MqttQos.exactlyOnce, builder.payload);
  }

  /// The unsolicited disconnect callback
  void onDisconnected(MqttServerClient client) {
    print('EXAMPLE::OnDisconnected client callback - Client disconnection');
    if (client.connectionStatus.disconnectionOrigin ==
        MqttDisconnectionOrigin.solicited) {
      print('EXAMPLE::OnDisconnected callback is solicited, this is correct');
    }
  }

  /// The successful connect callback
  void onConnected() {
    print(
        'EXAMPLE::OnConnected client callback - Client connection was sucessful');
  }

  /// The subscribed callback
  void onSubscribed(String topic) {
    print('EXAMPLE::Subscription confirmed for topic $topic');
  }
}
