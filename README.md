# Powershell Serial Script
A lightweight powershell script for sending and receiving serial data

This was developed to communicate with 3D printers via USB.
This script requires no software installation on Windows PCs. Download the script, follow the steps in [How to use the script](#how-to-use-the-script) and you should be good to go.

## How to use the script
1. Download the script [SerialTerminal.ps1](SerialTerminal.ps1) and save it to your computer.
2. Make sure, that you have a connection to the device.
3. Right click the file and choose the 'Run with PowerShell' option. (A PowerShell window should open itself)
4. (If you get asked to choose an execution policy, you can just hit [ENTER]) 
5. Choose the serial port to your device by typing it's name and hitting [ENTER]. (All available ports are shown when you start the script)
6. Type a message into the console and hit enter to send it to the device.
7. The script will retrieve messages from the device for a certain amount of time. After this time you can send more messages to the device.

## FAQ
### Error message `No ports available!` when running the script
- Check whether you have a connection to the device.
- Check that the device is turned on and is ready to accept data transmissions.
- Check whether your PC is able to establish a serial connection.

### Error message `Port closed!` when choosing a port
- Make sure that no other program is acessing the device (through that port).
- Confirm that you are still connected to the device.
- Check that the device is not in a sleep or power-saving mode.
