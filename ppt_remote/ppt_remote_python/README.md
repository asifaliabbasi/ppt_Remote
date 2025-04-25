# PPT Remote Controller

A PowerPoint remote control system consisting of a Flutter mobile app and a Python desktop server.

## Desktop App (PPT Host Controller)

### Requirements
- Python 3.x
- PowerPoint installed
- Required Python packages (install using `pip install -r requirements.txt`):
  - pyautogui
  - Pillow
  - keyboard

### Setup & Running
1. Install the required dependencies:
   ```bash
   pip install -r requirements.txt
   ```
2. Run the server application:
   ```bash
   python ppt_host.py
   ```
3. The GUI will show your local IP address - you'll need this for the mobile app.

### Troubleshooting
- If the server fails to start, make sure no other application is using port 3000
- If PowerPoint doesn't respond to commands:
  - Make sure PowerPoint is the active window
  - Check if your system allows pyautogui to control the keyboard
  - Try running the application as administrator

## Mobile App (PPT Remote)

### Requirements
- Flutter SDK
- Android Studio or Xcode (for deployment)

### Setup & Running
1. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```
2. Run the app on your device:
   ```bash
   flutter run
   ```

### Usage
1. Start the desktop app first and click "Start Server"
2. Launch the mobile app
3. Enter the IP address shown in the desktop app
4. Click "Connect"
5. Use the buttons to control your PowerPoint presentation:
   - Start: Begins the presentation (F5)
   - Next: Next slide (Right Arrow)
   - Prev: Previous slide (Left Arrow)
   - End: Exits the presentation (Esc)

### Troubleshooting
- If connection fails:
  - Ensure both devices are on the same network
  - Check if the IP address is correct
  - Verify that the desktop server is running
  - Check if your firewall is blocking the connection
- If commands don't work:
  - Check connection status in the app
  - Try disconnecting and reconnecting
  - Restart both the mobile app and desktop server

## Features
- Simple and intuitive UI
- Dark/Light mode toggle
- Connection status indicator
- Persistent IP address storage
- Real-time connection status
- Large, easy-to-tap control buttons
- Thread-safe client handling
- Error handling and logging

## Note
- Make sure both devices are on the same network for the connection to work
- The desktop app must be running before connecting from the mobile app
- PowerPoint must be the active window for commands to work
- Some systems may require administrator privileges for keyboard control 