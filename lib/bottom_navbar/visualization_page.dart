import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:epibox/bottom_navbar/destinations.dart';

import 'package:epibox/pages/speed_annotation.dart';
import 'package:epibox/pages/visualization_destination.dart';
import 'package:epibox/decor/default_colors.dart';
import 'package:epibox/utils/models.dart';
import 'package:epibox/utils/mqtt_wrapper.dart';

class VisualizationPage extends StatefulWidget {
  VisualizationPage({
    this.dataMAC1Notifier,
    this.dataMAC2Notifier,
    this.channelsMAC1Notifier,
    this.channelsMAC2Notifier,
    this.sensorsMAC1Notifier,
    this.sensorsMAC2Notifier,
    this.mqttClientWrapper,
    this.acquisitionNotifier,
    this.batteryBit1Notifier,
    this.batteryBit2Notifier,
    this.patientNotifier,
    this.annotationTypesD,
    this.connectionNotifier,
    this.timedOut,
    this.startupError,
    this.macAddress1Notifier,
    this.allDestinations,
    this.saveRaw,
  });

  final ValueNotifier<String> macAddress1Notifier;

  final ValueNotifier<List<List>> dataMAC1Notifier;
  final ValueNotifier<List<List>> dataMAC2Notifier;
  final ValueNotifier<List<List>> channelsMAC1Notifier;
  final ValueNotifier<List<List>> channelsMAC2Notifier;
  final ValueNotifier<List> sensorsMAC1Notifier;
  final ValueNotifier<List> sensorsMAC2Notifier;

  final MQTTClientWrapper mqttClientWrapper;

  final ValueNotifier<String> acquisitionNotifier;

  final ValueNotifier<double> batteryBit1Notifier;
  final ValueNotifier<double> batteryBit2Notifier;

  final ValueNotifier<String> patientNotifier;

  final ValueNotifier<List> annotationTypesD;

  final ValueNotifier<String> timedOut;
  final ValueNotifier<bool> startupError;

  final List<Destination> allDestinations;

  final ValueNotifier<MqttCurrentConnectionState> connectionNotifier;

  final ValueNotifier<bool> saveRaw;

  @override
  _VisualizationPageState createState() => _VisualizationPageState();
}

class _VisualizationPageState extends State<VisualizationPage>
    with TickerProviderStateMixin<VisualizationPage> {
  int _currentIndex = 0;
  ValueNotifier<bool> newAnnotation = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    newAnnotation.addListener(() async {
      if (newAnnotation.value) {
        Future<Null>.delayed(Duration.zero, () {
          _showSnackBar('Anotação gravada!');
          setState(() => newAnnotation.value = false);
        });
      }
    });
  }

  void _stopAcquisition() {
    widget.mqttClientWrapper.publishMessage("['INTERRUPT']");
  }

  void _resumeAcquisition() {
    widget.mqttClientWrapper.publishMessage("['RESUME ACQ']");
  }

  void _pauseAcquisition() {
    widget.mqttClientWrapper.publishMessage("['PAUSE ACQ']");
  }

  void _showSnackBar(String _message) {
    try {
      ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
        content: new Text(_message),
        backgroundColor: Colors.blue,
      ));
    } catch (e) {
      print(e);
    }
  }

  Future<void> _speedAnnotation() async {
    //List annotationTypesD = await getAnnotationTypes();
    List<String> annotationTypes =
        List<String>.from(widget.annotationTypesD.value);
    //print(annotationTypes);
    Navigator.of(context).push(new MaterialPageRoute<Null>(
        builder: (BuildContext context) {
          return SpeedAnnotationDialog(
            annotationTypesD: widget.annotationTypesD,
            annotationTypes: annotationTypes,
            patientNotifier: widget.patientNotifier,
            newAnnotation: newAnnotation,
            mqttClientWrapper: widget.mqttClientWrapper,
          );
        },
        fullscreenDialog: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: IndexedStack(
          index: _currentIndex,
          children:
              widget.allDestinations.map<Widget>((Destination destination) {
            return DestinationView(
              destination: destination,
              dataMAC1Notifier: widget.dataMAC1Notifier,
              dataMAC2Notifier: widget.dataMAC2Notifier,
              channelsMAC1Notifier: widget.channelsMAC1Notifier,
              channelsMAC2Notifier: widget.channelsMAC2Notifier,
              sensorsMAC1Notifier: widget.sensorsMAC1Notifier,
              sensorsMAC2Notifier: widget.sensorsMAC2Notifier,
              mqttClientWrapper: widget.mqttClientWrapper,
              acquisitionNotifier: widget.acquisitionNotifier,
              batteryBit1Notifier: widget.batteryBit1Notifier,
              batteryBit2Notifier: widget.batteryBit2Notifier,
              patientNotifier: widget.patientNotifier,
              annotationTypesD: widget.annotationTypesD,
              connectionNotifier: widget.connectionNotifier,
              timedOut: widget.timedOut,
              startupError: widget.startupError,
              saveRaw: widget.saveRaw,
            );
          }).toList(),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: widget.allDestinations.map((Destination destination) {
          return BottomNavigationBarItem(
            icon: Icon(
              destination.icon,
              color:
                  _currentIndex == widget.allDestinations.indexOf(destination)
                      ? DefaultColors.mainLColor
                      : Colors.grey[800],
            ),
            label: destination.label,
          );
        }).toList(),
      ),
      floatingActionButton: Stack(children: [
        Align(
          alignment: Alignment(-0.8, 1.0),
          child: FloatingActionButton(
            mini: true,
            heroTag: null,
            onPressed: () => _speedAnnotation(),
            child: Icon(MdiIcons.lightningBolt),
          ),
        ),
        Align(
            alignment: Alignment(0.2, 1.0),
            child: ValueListenableBuilder(
                valueListenable: widget.acquisitionNotifier,
                builder: (BuildContext context, String state, Widget child) {
                  return FloatingActionButton(
                    mini: true,
                    heroTag: null,
                    onPressed: state == 'paused'
                        ? () => _resumeAcquisition()
                        : () => _pauseAcquisition(),
                    child: state == 'paused'
                        ? Icon(Icons.play_arrow)
                        : Icon(Icons.pause),
                  );
                })),
        Align(
          alignment: Alignment.bottomRight,
          child: FloatingActionButton.extended(
            onPressed: () => _stopAcquisition(),
            label: Text('Parar'),
            icon: Icon(Icons.stop),
          ),
        ),
      ]),
    );
  }
}
