// MIT License
// Copyright (c) 2021-2024 LinearMouse

import Foundation
import ObservationToken
import InputKitC

public final class InputDeviceManager {
    private var eventSystemClient: IOHIDEventSystemClient?

    public typealias DeviceAddedClosure = (InputDeviceManager, InputDevice) -> Void
    public typealias DeviceRemovedClosure = (InputDeviceManager, InputDevice) -> Void
    public typealias PropertyChangedClosure = (InputDeviceManager) -> Void
    public typealias EventReceivedClosure = (InputDeviceManager, InputDevice, IOHIDEvent) -> Void

    private var observations = (
        deviceAdded: [UUID: DeviceAddedClosure](),
        deviceRemoved: [UUID: DeviceRemovedClosure](),
        propertyChanged: [UUID: (property: String, closure: PropertyChangedClosure)](),
        eventReceived: [UUID: EventReceivedClosure]()
    )

    private var serviceClientToInputDevice = [IOHIDServiceClient: InputDevice]()

    public var devices: [InputDevice] {
        Array(serviceClientToInputDevice.values)
    }

    public init() {}
}

// MARK: Observation API

public extension InputDeviceManager {
    func observeDeviceAdded(using closure: @escaping DeviceAddedClosure) -> ObservationToken {
        let id = observations.deviceAdded.insert(closure)

        return ObservationToken { [weak self] in
            self?.observations.deviceAdded.removeValue(forKey: id)
        }
    }

    func observeDeviceRemoved(using closure: @escaping DeviceRemovedClosure) -> ObservationToken {
        let id = observations.deviceRemoved.insert(closure)

        return ObservationToken { [weak self] in
            self?.observations.deviceRemoved.removeValue(forKey: id)
        }
    }

    func observePropertyChanged(property: String,
                                using closure: @escaping PropertyChangedClosure) -> ObservationToken {
        let id = observations.propertyChanged.insert((property: property, closure: closure))

        return ObservationToken { [weak self] in
            self?.observations.propertyChanged.removeValue(forKey: id)
        }
    }

    func observeEventReceived(using closure: @escaping EventReceivedClosure) -> ObservationToken {
        let id = observations.eventReceived.insert(closure)

        return ObservationToken { [weak self] in
            self?.observations.eventReceived.removeValue(forKey: id)
        }
    }
}

// MARK: Device observation

extension InputDeviceManager {
    private enum ObservationMatches {
        static var input: CFArray {
            let usageMouse = [
                kIOHIDDeviceUsagePageKey: kHIDPage_GenericDesktop,
                kIOHIDDeviceUsageKey: kHIDUsage_GD_Mouse
            ] as CFDictionary

            let usagePointer = [
                kIOHIDDeviceUsagePageKey: kHIDPage_GenericDesktop,
                kIOHIDDeviceUsageKey: kHIDUsage_GD_Pointer
            ] as CFDictionary

            let usageKeyboard = [
                kIOHIDDeviceUsagePageKey: kHIDPage_GenericDesktop,
                kIOHIDDeviceUsageKey: kHIDUsage_GD_Keyboard
            ] as CFDictionary

            let usageKeypad = [
                kIOHIDDeviceUsagePageKey: kHIDPage_GenericDesktop,
                kIOHIDDeviceUsageKey: kHIDUsage_GD_Keypad
            ] as CFDictionary

            return [usageMouse, usagePointer, usageKeyboard, usageKeypad] as CFArray
        }
    }

    private static let propertyChangedCallback: IOHIDEventSystemClientPropertyChangedCallback =
        { target, _, property, value in
            guard let target = target else { return }
            guard let property = property else { return }

            let this = Unmanaged<InputDeviceManager>.fromOpaque(target).takeUnretainedValue()
            this.propertyChangedCallback(property as String, value)
        }

    /**
     Start observing device additions and removals.

     Registered `DeviceAddedClosure`s will be notified immediately with all the current devices.
     */
    public func startObservation() {
        guard eventSystemClient == nil else { return }

        guard let eventSystemClient = IOHIDEventSystemClientCreate(kCFAllocatorDefault) else {
            return
        }

        self.eventSystemClient = eventSystemClient

        IOHIDEventSystemClientSetMatchingMultiple(eventSystemClient,
                                                  ObservationMatches.input)
        IOHIDEventSystemClientRegisterDeviceMatchingBlock(eventSystemClient,
                                                          serviceMatchingCallback,
                                                          nil,
                                                          nil)
        IOHIDEventSystemClientRegisterEventBlock(eventSystemClient,
                                                 eventReceivedCallback,
                                                 nil,
                                                 nil)
        IOHIDEventSystemClientScheduleWithDispatchQueue(eventSystemClient, DispatchQueue.main)

        if let clients = IOHIDEventSystemClientCopyServices(eventSystemClient) as? [IOHIDServiceClient] {
            for client in clients {
                addDevice(forClient: client)
            }
        }

        for property in observations.propertyChanged.values.map(\.property) {
            IOHIDEventSystemClientRegisterPropertyChangedCallback(
                eventSystemClient,
                property as CFString,
                Self.propertyChangedCallback,
                Unmanaged.passUnretained(self).toOpaque(),
                nil
            )
        }
    }

    /**
     Stop observing device additions and removals.

     Registered `DeviceRemovedClosure`s will be notified immediately with all the current devices.
     */
    public func stopObservation() {
        guard let eventSystemClient = eventSystemClient else { return }

        IOHIDEventSystemClientUnregisterDeviceMatchingBlock(eventSystemClient)
        IOHIDEventSystemClientUnscheduleFromDispatchQueue(eventSystemClient, DispatchQueue.main)

        for device in devices {
            removeDevice(device)
        }

        self.eventSystemClient = nil
    }

    private func serviceMatchingCallback(_: UnsafeMutableRawPointer?,
                                         _: UnsafeMutableRawPointer?,
                                         _ client: IOHIDServiceClient?) {
        guard let client = client else { return }

        addDevice(forClient: client)
    }

    private func clientRemovalCallback(_: UnsafeMutableRawPointer?,
                                       _: UnsafeMutableRawPointer?,
                                       _ client: IOHIDServiceClient?) {
        guard let client = client else { return }

        removeDevice(forClient: client)
    }

    private func eventReceivedCallback(_: UnsafeMutableRawPointer?,
                                       _: UnsafeMutableRawPointer?,
                                       _ client: IOHIDServiceClient?,
                                       event: IOHIDEvent?) {
        guard let client = client else { return }
        guard let event = event else { return }

        guard let device = serviceClientToInputDevice[client] else { return }

        for (_, callback) in observations.eventReceived {
            callback(self, device, event)
        }
    }

    private func propertyChangedCallback(_ property: String, _: AnyObject?) {
        for (_, (observingProperty, callback)) in observations.propertyChanged where property == observingProperty {
            callback(self)
        }
    }

    private func addDevice(forClient client: IOHIDServiceClient) {
        guard serviceClientToInputDevice[client] == nil else { return }

        let device = InputDevice(client)

        serviceClientToInputDevice[client] = device

        for (_, callback) in observations.deviceAdded {
            callback(self, device)
        }

        IOHIDServiceClientRegisterRemovalBlock(client, clientRemovalCallback, nil, nil)
    }

    private func removeDevice(forClient client: IOHIDServiceClient) {
        guard let pointerDevice = serviceClientToInputDevice[client] else { return }

        removeDevice(pointerDevice)
    }

    private func removeDevice(_ device: InputDevice) {
        serviceClientToInputDevice.removeValue(forKey: device.client)

        for (_, callback) in observations.deviceRemoved {
            callback(self, device)
        }
    }

    public func inputDeviceFromIOHIDEvent(_ ioHidEvent: IOHIDEvent) -> InputDevice? {
        guard let eventSystemClient = eventSystemClient else {
            return nil
        }

        let senderID = IOHIDEventGetSenderID(ioHidEvent)
        let serviceClient = IOHIDEventSystemClientCopyServiceForRegistryID(eventSystemClient, senderID)
        return serviceClient.flatMap { serviceClientToInputDevice[$0] }
    }

    public func inputDevicesFromLocationID(_ locationID: Int) -> [InputDevice] {
        devices.filter({ $0.locationID == locationID })
    }
}
