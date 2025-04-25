import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:flutter/services.dart';
import 'package:volume_controller/volume_controller.dart';
import '../providers/connection_provider.dart';
import '../providers/theme_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _ipController = TextEditingController();
  double _lastVolume = 0.0;

  @override
  void initState() {
    super.initState();
    // Initialize the controller with the saved IP if available
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final connectionProvider =
          Provider.of<ConnectionProvider>(context, listen: false);
      _ipController.text = connectionProvider.serverIP;

      // Initialize volume button listener
      VolumeController.instance.showSystemUI = false;
      _lastVolume = await VolumeController.instance.getVolume();

      VolumeController.instance.addListener((volume) {
        final connectionProvider =
            Provider.of<ConnectionProvider>(context, listen: false);
        if (volume < _lastVolume) {
          connectionProvider.sendCommand('PREV');
        } else if (volume > _lastVolume) {
          connectionProvider.sendCommand('NEXT');
        }
        _lastVolume = volume;
      });
    });
  }

  @override
  void dispose() {
    _ipController.dispose();
    VolumeController.instance.removeListener();
    super.dispose();
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      final connectionProvider =
          Provider.of<ConnectionProvider>(context, listen: false);
      if (event.logicalKey == LogicalKeyboardKey.audioVolumeDown) {
        connectionProvider.sendCommand('NEXT');
      } else if (event.logicalKey == LogicalKeyboardKey.audioVolumeUp) {
        connectionProvider.sendCommand('PREV');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: _handleKeyEvent,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('PPT Remote'),
          actions: [
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return FlutterSwitch(
                  value: themeProvider.isDarkMode,
                  onToggle: (value) => themeProvider.toggleTheme(),
                  activeColor: Colors.blue,
                  inactiveColor: Colors.grey,
                );
              },
            ),
          ],
        ),
        body: Consumer<ConnectionProvider>(
          builder: (context, connectionProvider, child) {
            return Column(children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _ipController,
                        decoration: const InputDecoration(
                          labelText: 'Server IP',
                          border: OutlineInputBorder(),
                          hintText: 'Enter server IP address',
                        ),
                        keyboardType: TextInputType.number,
                        onSubmitted: (value) {
                          if (value.isNotEmpty) {
                            connectionProvider.connect(value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (_ipController.text.isNotEmpty) {
                          connectionProvider.connect(_ipController.text);
                        }
                      },
                      child: const Text('Connect'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(children: [
                    if (connectionProvider.isConnected)
                      const Text(
                        'Connected',
                        style: TextStyle(color: Colors.green, fontSize: 20),
                      )
                    else
                      const Text(
                        'Disconnected',
                        style: TextStyle(color: Colors.red, fontSize: 20),
                      ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildControlButton(
                          context,
                          'Prev',
                          Icons.arrow_back,
                          () => connectionProvider.sendCommand('PREV'),
                        ),
                        const SizedBox(width: 20),
                        _buildControlButton(
                          context,
                          'Next',
                          Icons.arrow_forward,
                          () => connectionProvider.sendCommand('NEXT'),
                        ),
                        const SizedBox(width: 20),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildControlDownButton(
                          context,
                          'Start',
                          Icons.play_arrow,
                          () => connectionProvider.sendCommand('START'),
                        ),
                        const SizedBox(width: 50),
                        _buildControlDownButton(
                          context,
                          'End',
                          Icons.stop,
                          () => connectionProvider.sendCommand('END'),
                        ),
                      ],
                    ),
                  ]),
                ),
              )
            ]);
          },
        ),
      ),
    );
  }

  Widget _buildControlButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Column(
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
              width: MediaQuery.of(context).size.width * 0.45,
              height: MediaQuery.of(context).size.height * 0.6,
              child: Icon(icon, size: 100)),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildControlDownButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Column(
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(child: Icon(icon, size: 30)),
        ),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }
}
