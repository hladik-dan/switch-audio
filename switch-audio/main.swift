import CoreAudio
import Foundation

let audioDevices = AudioDevice.getAll()
let inputAudioDevices = audioDevices.filter { $0.type == .input }
let outputAudioDevices = audioDevices.filter { $0.type == .output }

let arguments = CommandLine.arguments

if (arguments.count < 2) {
    print("Usage:\t--list | --list-input | --list-output | --set-input=ID | --set-output=ID")
    print("\t--list          : Shows all audio devices.")
    print("\t--list-input    : Shows input audio devices.")
    print("\t--list-output   : Shows output audio devices.")
    print("\t--set-input=ID  : Sets the default input to given ID.")
    print("\t--set-output=ID : Sets the default output to given ID.")
    
    exit(EXIT_SUCCESS)
}

let argument = arguments[1]

if (argument == "--list") {
    let jsonEncodedData = try JSONEncoder().encode(audioDevices)
    let data = String(data: jsonEncodedData, encoding: .utf8)!
    
    print(data)
    
    exit(EXIT_SUCCESS)
}

if (argument == "--list-input") {
    let jsonEncodedData = try JSONEncoder().encode(inputAudioDevices)
    let data = String(data: jsonEncodedData, encoding: .utf8)!
    
    print(data)
    
    exit(EXIT_SUCCESS)
}

if (argument == "--list-output") {
    let jsonEncodedData = try JSONEncoder().encode(outputAudioDevices)
    let data = String(data: jsonEncodedData, encoding: .utf8)!
    
    print(data)
    
    exit(EXIT_SUCCESS)
}

if (argument.contains("--set-input")) {
    guard let audioDeviceID = Int(Argument.getValue(argument: argument)) else {
        print("The --set-output value is not a number!")
        exit(EXIT_FAILURE)
    }
    
    guard let inputAudioDevice = inputAudioDevices.first(where: { $0.id == audioDeviceID }) else {
        print("The AudioDeviceID doesn't exist!")
        exit(EXIT_FAILURE)
    }
    
    inputAudioDevice.setAsDefault()
    
    exit(EXIT_SUCCESS)
}

if (argument.contains("--set-output")) {
    guard let audioDeviceID = Int(Argument.getValue(argument: argument)) else {
        print("The --set-output value is not a number!")
        exit(EXIT_FAILURE)
    }
    
    guard let outputAudioDevice = outputAudioDevices.first(where: { $0.id == audioDeviceID }) else {
        print("The AudioDeviceID doesn't exist!")
        exit(EXIT_FAILURE)
    }
    
    outputAudioDevice.setAsDefault()
    
    exit(EXIT_SUCCESS)
}
