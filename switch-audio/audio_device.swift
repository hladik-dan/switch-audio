import CoreAudio

class AudioDevice: Encodable {
    enum AudioDeviceType: String, Encodable {
        case input
        case output
        case unknown
    }
    
    var id = AudioDeviceID()
    var name = String()
    var type = AudioDeviceType.unknown
    var isDefault = false
    
    init(id: AudioDeviceID) {
        self.id = id
        self.name = self.getName()
        self.type = self.getType()
        self.isDefault = self.checkIfIsDefault()
    }
    
    public static func getAll() -> [AudioDevice] {
        return self.getAudioDeviceIDs().map { audioDeviceID in AudioDevice(id: audioDeviceID) }
    }
    
    public func setAsDefault() -> Void {
        if (self.type == .unknown) {
            return
        }
        
        let objectID = AudioObjectID(kAudioObjectSystemObject)
        var address = AudioObjectPropertyAddress(mSelector:
                                                    self.type == .input
                                                    ? kAudioHardwarePropertyDefaultInputDevice
                                                    : kAudioHardwarePropertyDefaultOutputDevice,
                                                 mScope:
                                                    self.type == .input
                                                    ? kAudioObjectPropertyScopeInput
                                                    : kAudioObjectPropertyScopeOutput,
                                                 mElement: kAudioObjectPropertyElementMain)
        
        AudioObjectSetPropertyData(objectID,
                                   &address,
                                   0,
                                   nil,
                                   UInt32(MemoryLayout<AudioDeviceID>.size),
                                   &self.id)
    }
    
    private static func getAudioDeviceIDs() -> [AudioDeviceID] {
        let objectID = AudioObjectID(kAudioObjectSystemObject)
        var address = AudioObjectPropertyAddress(mSelector: kAudioHardwarePropertyDevices,
                                                 mScope: kAudioObjectPropertyScopeGlobal,
                                                 mElement: kAudioObjectPropertyElementMain)
        var dataSize = UInt32()
        AudioObjectGetPropertyDataSize(objectID, &address, 0, nil, &dataSize)

        var data = (0 ..< Int(dataSize) / MemoryLayout<AudioDeviceID>.size).map { _ -> AudioDeviceID in
            return AudioDeviceID()
        }
        AudioObjectGetPropertyData(objectID, &address, 0, nil, &dataSize, &data)
        
        return data;
    }
    
    private func getName() -> String {
        var address = AudioObjectPropertyAddress(mSelector: kAudioDevicePropertyDeviceName,
                                                 mScope: kAudioObjectPropertyScopeGlobal,
                                                 mElement: kAudioObjectPropertyElementMain)
        var dataSize = UInt32()
        AudioObjectGetPropertyDataSize(self.id, &address, 0, nil, &dataSize)
        
        var data = [CChar](repeating: 0, count: 128)
        AudioObjectGetPropertyData(self.id, &address, 0, nil, &dataSize, &data)
        
        return String(cString: data)
    }
    
    private func getType() -> AudioDevice.AudioDeviceType {
        if (self.getNumberOfInputChannels() > 0) {
            return AudioDeviceType.input
        }
        
        if (self.getNumberOfOutputChannels() > 0) {
            return AudioDeviceType.output
        }
        
        return AudioDeviceType.unknown
    }
    
    private func getNumberOfInputChannels() -> Int {
        var address = AudioObjectPropertyAddress(mSelector: kAudioDevicePropertyStreamConfiguration,
                                                 mScope: kAudioObjectPropertyScopeInput,
                                                 mElement: kAudioObjectPropertyElementMain)
        var dataSize = UInt32()
        AudioObjectGetPropertyDataSize(self.id, &address, 0, nil, &dataSize)
        
        let data = UnsafeMutablePointer<AudioBufferList>.allocate(capacity: Int(dataSize))
        AudioObjectGetPropertyData(self.id, &address, 0, nil, &dataSize, data)
        
        return Int(UnsafeMutableAudioBufferListPointer(data).reduce(0) { $0 + $1.mNumberChannels })
    }
    
    private func getNumberOfOutputChannels() -> Int {
        var address = AudioObjectPropertyAddress(mSelector: kAudioDevicePropertyStreamConfiguration,
                                                 mScope: kAudioObjectPropertyScopeOutput,
                                                 mElement: kAudioObjectPropertyElementMain)
        var dataSize = UInt32()
        AudioObjectGetPropertyDataSize(self.id, &address, 0, nil, &dataSize)
        
        let data = UnsafeMutablePointer<AudioBufferList>.allocate(capacity: Int(dataSize))
        AudioObjectGetPropertyData(self.id, &address, 0, nil, &dataSize, data)
        
        return Int(UnsafeMutableAudioBufferListPointer(data).reduce(0) { $0 + $1.mNumberChannels })
    }
    
    private func checkIfIsDefault() -> Bool {
        let objectID = AudioObjectID(kAudioObjectSystemObject)
        var address = AudioObjectPropertyAddress(mSelector:
                                                    self.type == .input
                                                    ? kAudioHardwarePropertyDefaultInputDevice
                                                    : kAudioHardwarePropertyDefaultOutputDevice,
                                                 mScope: kAudioObjectPropertyScopeGlobal,
                                                 mElement: kAudioObjectPropertyElementMain)
        var dataSize = UInt32(MemoryLayout<AudioDeviceID>.size);
        var defaultAudioDeviceID = AudioDeviceID()
        
        AudioObjectGetPropertyData(objectID,
                                   &address,
                                   0,
                                   nil,
                                   &dataSize,
                                   &defaultAudioDeviceID)
        
        return self.id == defaultAudioDeviceID
    }
}
