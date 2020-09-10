import 'package:bloc/bloc.dart';
import 'package:flutter/services.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:oremamqttdemo/repository/mqtt_repository.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  MQTTRepository _mqttRepository = new MQTTRepository();

  HomeBloc(HomeState initialState) : super(initialState);

  @override
  Stream<HomeState> mapEventToState(HomeEvent event) async* {
    if (event is ConnectButtonPressed) {
      yield HomeLoadingState();

      try {
        MqttServerClient client =
            await _mqttRepository.initClient(ipAddress: event.ipAddress);
        ConnectToBrokerResult result =
            await _mqttRepository.connectToBroker(client: client);
        _mqttRepository.subscribe(client: client, topic: "meter/data");
        _mqttRepository.subscribe(client: client, topic: "meter/ack");
        yield HomeInitialState(client: client, connectToBrokerResult: result);
      } catch (err) {
        print(err);
        yield HomeInitialState();
      }
    }

    if(event is DisconnectedBroker){
      yield HomeLoadingState();

      try {
        yield HomeInitialState();
      } catch(err){
        print(err);
        yield HomeInitialState();
      }
    }

    if (event is RechargerButtonPressed) {
      yield HomeLoadingState();

      try {

        _mqttRepository.publish(client: event.client, topic: "client/session", message: "start");
        yield HomeInitialState(client: event.client,
            operation: "write",
            message: "start",
            topicPublished: "client/session",
            token: event.token,
        connectToBrokerResult: ConnectToBrokerResult.SUCCESS);

      } catch (err) {
        print(err);
        yield HomeInitialState();
      }
    }

    if (event is UpdateButtonPressed) {
      yield HomeLoadingState();

      try {
        _mqttRepository.publish(client: event.client, topic: "client/session", message: "start");
        yield HomeInitialState(client: event.client,
            operation: "read",
            message: "start",
            topicPublished: "client/session",
            connectToBrokerResult: ConnectToBrokerResult.SUCCESS);
      } catch (err) {
        print(err);
        print("ERROR");
        yield HomeInitialState();
      }
    }

    if(event is Publish){
      try {
        _mqttRepository.publish(client: event.client, topic: event.topic, message: event.message);
        yield HomeInitialState(client: event.client,
            operation: "read",
            message: "start",
            topicPublished: "client/session",
            connectToBrokerResult: ConnectToBrokerResult.SUCCESS);
      } catch(err){
        print(err);
        yield HomeInitialState();
      }
    }
  }
}

/**
 * Home page state
 */
class HomeState {}

class HomeLoadingState extends HomeState {}

class HomeInitialState extends HomeState {
  final MqttServerClient client;
  final ConnectToBrokerResult connectToBrokerResult;
  final String operation;
  final String message;
  final String topicPublished;
  final String token;

  HomeInitialState({
    this.operation = "",
    this.message = "",
    this.topicPublished = "",
    this.token,
    this.client,
    this.connectToBrokerResult});
}

class HomeErrorState extends HomeState {}

/**
 * Home page event
 */
class HomeEvent {}

class ConnectButtonPressed extends HomeEvent {
  final String ipAddress;

  ConnectButtonPressed({this.ipAddress});
}

class RechargerButtonPressed extends HomeEvent {
  final String token;
  final MqttServerClient client;

  RechargerButtonPressed({this.client, this.token});
}

class UpdateButtonPressed extends HomeEvent {
  final MqttServerClient client;

  UpdateButtonPressed({this.client});
}

class DisconnectedBroker extends HomeEvent {
  final MqttServerClient client;

  DisconnectedBroker({this.client});
}

class Publish extends HomeEvent {
  final String topic;
  final String message;
  final MqttServerClient client;

  Publish({this.topic, this.message, this.client});
}