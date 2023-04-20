import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:flutter_midi_command_platform_interface/flutter_midi_command_platform_interface.dart';

class MidiControllerPage extends StatefulWidget {
  @override
  _MidiControllerPageState createState() => _MidiControllerPageState();
}

class _MidiControllerPageState extends State<MidiControllerPage> {
  final TextEditingController _controller = TextEditingController();
  List<BluetoothDevice> _devices = [];
  BluetoothDevice _selectedDevice;

  @override
  void initState() {
    super.initState();
    scanForDevices();
  }

  void scanForDevices() async {
    FlutterBlue flutterBlue = FlutterBlue.instance;

    flutterBlue.startScan(timeout: Duration(seconds: 4));

    flutterBlue.scanResults.listen((List<ScanResult> results) {
      for (ScanResult result in results) {
        setState(() {
          _devices.add(result.device);
        });
      }
    });

    flutterBlue.stopScan();
  }

  void connectToDevice(BluetoothDevice device) async {
    await device.connect();
    MidiCommand.setupMidiToDevice(device);
    setState(() {
      _selectedDevice = device;
    });
  }

  void sendMidiMessage(String message) {
    List<int> midiBytes = message.split(' ').map((e) => int.parse(e, radix: 16)).toList();
    MidiCommand.sendData(midiBytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MIDI Controller'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Dispositivos encontrados:'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _devices.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_devices[index].name),
                  onTap: () => connectToDevice(_devices[index]),
                  selected: _selectedDevice == _devices[index],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Digite os bytes MIDI (em hexadecimal)',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () => sendMidiMessage(_controller.text),
              child: Text('Enviar'),
            ),
          ),
        ],
      ),
    );
  }
}

