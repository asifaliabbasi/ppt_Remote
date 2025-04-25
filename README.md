# PPT Remote

A cross-platform PowerPoint remote control application built with Flutter and Python. Control your presentations seamlessly from your mobile device or tablet.

## 🌟 Features

- **Remote Presentation Control**: Start, navigate, and end PowerPoint presentations from your mobile device
- **Cross-Platform Support**: Works on both Android and iOS devices
- **Simple Interface**: Intuitive controls for presentation navigation
- **Network Connectivity**: Connects over local network for reliable control
- **Real-time Response**: Instant command execution with minimal latency

## 🛠️ Technical Stack

- **Frontend**: Flutter for cross-platform mobile application
- **Backend**: Python-based host application
- **Communication**: TCP/IP socket-based client-server architecture
- **Desktop Integration**: PyAutoGUI for presentation control

## 🚀 Getting Started

### Prerequisites

- Flutter SDK
- Python 3.x
- PowerPoint or compatible presentation software

### Host Setup (Windows/Mac/Linux)

1. Install Python requirements:
   ```bash
   pip install -r requirements_exe.txt
   ```

2. Run the host application:
   ```bash
   python ppt_host.py
   ```

3. The host application will display your local IP address and start listening for connections.

### Mobile App Setup

1. Install the PPT Remote app on your mobile device
2. Enter the IP address shown in the host application
3. Connect and start controlling your presentations

## 🔧 Controls

- **Start Presentation**: Begins the slideshow (F5)
- **Next Slide**: Navigate to the next slide (Right Arrow)
- **Previous Slide**: Go back to the previous slide (Left Arrow)
- **End Presentation**: Exit the slideshow mode (Esc)

## 🔒 Security

The application operates on your local network only, ensuring your presentations remain secure and private.

## 📝 License

This project is open source and available under the MIT License.

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the issues page.

## ✨ Acknowledgments

- Built with Flutter and Python
- Uses PyAutoGUI for system control
- Inspired by the need for simple, reliable presentation control
