import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:rPiInterface/utils/authentication.dart';
import 'package:rPiInterface/utils/models.dart';
import 'package:rPiInterface/utils/mqtt_wrapper.dart';



// programar button "Usar default" e "Usar novo" para enviar MACAddress para RPi e voltar à HomePage
// programar button "Definir novo default" para enviar MACAddress para RPi e mudar "defaultBIT"

class DevicesPage extends StatefulWidget {
  ValueNotifier<MqttCurrentConnectionState> connectionNotifier;
  MQTTClientWrapper mqttClientWrapper;
  MqttCurrentConnectionState connectionState;

  ValueNotifier<String> macAddress1Notifier;
  ValueNotifier<String> macAddress2Notifier;

  ValueNotifier<String> acquisitionNotifier;
  ValueNotifier<String> patientNotifier;

  /* String macAddress1;
  String macAddress2; */

  DevicesPage(
      {this.mqttClientWrapper,
      this.macAddress1Notifier,
      this.macAddress2Notifier,
      this.connectionNotifier,
      this.acquisitionNotifier,
      this.patientNotifier});

  @override
  _DevicesPageState createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  final Auth _auth = Auth();

  final TextEditingController _controller1 = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller1.text = widget.macAddress1Notifier.value;
    _controller2.text = widget.macAddress2Notifier.value;
  }

  void _setNewDefault1() {
    setState(() => widget.macAddress1Notifier.value = _controller1.text);
  }

  void _setNewDefault2() {
    setState(() => widget.macAddress2Notifier.value = _controller2.text);
  }

  @override
  Widget build(BuildContext context) {

    final bodyWidth = MediaQuery.of(context).size.width -
        MediaQuery.of(context).viewInsets.left - MediaQuery.of(context).viewInsets.right;

    return Scaffold(
      appBar: new AppBar(title: new Text('BITalino(s)'),),
      body: Center(
        child: ListView(
          children: <Widget>[
            ValueListenableBuilder(
                valueListenable: widget.connectionNotifier,
                builder: (BuildContext context,
                    MqttCurrentConnectionState state, Widget child) {
                  return Container(
                    height: 20,
                    color: state == MqttCurrentConnectionState.CONNECTED
                        ? Colors.green[50]
                        : state == MqttCurrentConnectionState.CONNECTING
                            ? Colors.yellow[50]
                            : Colors.red[50],
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        child: Text(
                          state == MqttCurrentConnectionState.CONNECTED
                              ? 'Conectado ao servidor'
                              : state == MqttCurrentConnectionState.CONNECTING
                                  ? 'A conectar...'
                                  : 'Disconectado do servidor',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            //fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                ValueListenableBuilder(
                valueListenable: widget.acquisitionNotifier,
                builder: (BuildContext context,
                    String state, Widget child) {
                  return Container(
                    height: 20,
                    color: state ==
                            'acquiring'
                        ? Colors.green[50]
                        : state == 'reconnecting'
                        ? Colors.yellow[50]
                        : Colors.red[50],
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        child: Text(
                          state == 'acquiring'
                              ? 'A adquirir dados'
                              : state == 'reconnecting'  
                              ? 'A retomar aquisição ...'
                              : state == 'stopped'
                              ? 'Aquisição terminada e dados gravados'
                              : 'Aquisição desligada',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            //fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
            Padding(
              padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
              child: Column(children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 0.0, 10.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      child: Text(
                        'Dispositivos default',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 150.0,
                  width: 300.0,
                  color: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey[200],
                            offset: new Offset(5.0, 5.0))
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
                          child: Container(
                            height: 60.0,
                            width: 290.0,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              shape: BoxShape.rectangle,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4.0)),
                              border: new Border.all(
                                  color: Colors.grey,
                                  width: 1.0,
                                  style: BorderStyle.solid),
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding:
                                    EdgeInsets.fromLTRB(11.0, 0.0, 0.0, 0.0),
                                child: ValueListenableBuilder(
                                    valueListenable: widget.macAddress1Notifier,
                                    builder: (BuildContext context,
                                        String macAddress1, Widget child) {
                                      return Text(
                                        macAddress1,
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[600],
                                        ),
                                      );
                                    }),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
                          child: Container(
                            height: 60.0,
                            width: 290.0,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              shape: BoxShape.rectangle,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4.0)),
                              border: new Border.all(
                                  color: Colors.grey,
                                  width: 1.0,
                                  style: BorderStyle.solid),
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding:
                                    EdgeInsets.fromLTRB(11.0, 0.0, 0.0, 0.0),
                                child: ValueListenableBuilder(
                                    valueListenable: widget.macAddress2Notifier,
                                    builder: (BuildContext context,
                                        String macAddress2, Widget child) {
                                      return Text(
                                        macAddress2,
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[600],
                                        ),
                                      );
                                    }),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
                  child: RaisedButton(
                    onPressed: () {
                      widget.mqttClientWrapper.publishMessage(
                        "['USE',{'MAC1':'${widget.macAddress1Notifier.value}','MAC2':'${widget.macAddress2Notifier.value}'}]");
                      widget.mqttClientWrapper.publishMessage("['ID', ${widget.patientNotifier.value}]");
                    },
                    child: new Text("Usar default"),
                  ),
                ),
              ]),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
              child: Column(children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 0.0, 10.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      child: Text(
                        'Escolher novo(s) dispositivo(s)',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 150.0,
                  width: 0.95 * bodyWidth,
                  color: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey[200],
                            offset: new Offset(5.0, 5.0))
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
                          child: Row(children: [
                            Expanded(
                              child: TextField(
                                  style: TextStyle(color: Colors.grey[600]),
                                  controller: _controller1,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Endereço MAC',
                                  ),
                                  onChanged: null),
                            ),
                            IconButton(
                                icon: Icon(
                                  MdiIcons.qrcode,
                                ),
                                onPressed: () => scan(_controller1))
                          ]),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
                          child: Row(children: [
                            Expanded(
                              child: TextField(
                                  style: TextStyle(color: Colors.grey[600]),
                                  controller: _controller2,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Endereço MAC',
                                  ),
                                  onChanged: null),
                            ),
                            IconButton(
                                icon: Icon(
                                  MdiIcons.qrcode,
                                ),
                                onPressed: () => scan(_controller2))
                          ]),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      RaisedButton(
                        onPressed: () {
                          widget.mqttClientWrapper.publishMessage(
                              "['USE',{'MAC1':'${_controller1.text}','MAC2':'${_controller2.text}'}]");
                          widget.mqttClientWrapper.publishMessage("['ID', ${widget.patientNotifier.value}]");
                        },
                        child: new Text("Usar novo"),
                      ),
                      RaisedButton(
                        onPressed: () {
                          _setNewDefault1();
                          _setNewDefault2();
                          widget.mqttClientWrapper.publishMessage(
                              "['NEW',{'MAC1':'${_controller1.text}','MAC2':'${_controller2.text}'}]");
                        },
                        child: new Text("Definir novo default"),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Future scan(TextEditingController controller) async {
    try {
      var scan = (await BarcodeScanner.scan());
      String scanString = scan.rawContent;
      setState(() => controller.text = scanString);
    } on PlatformException catch (e) {
      print(e);
    }
  }
  
}