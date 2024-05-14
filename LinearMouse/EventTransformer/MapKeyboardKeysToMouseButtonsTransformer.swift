// MIT License
// Copyright (c) 2021-2024 LinearMouse

import Foundation
import os.log
import KeyKit
import InputKit

class MapKeyboardKeysToMouseButtonsTransformer: EventTransformer {
    static let log = OSLog(
        subsystem: Bundle.main.bundleIdentifier!,
        category: "MapKeyboardKeysToMouseButtonsTransformer"
    )

    let device: Device?
    
    var pressedButtons = [CGMouseButton]()
    var lastLocationDragged: CGPoint?
    var lastDeltaX: Double?
    var lastDeltaY: Double?

    init(_ device: Device?) {
        self.device = device
    }

    func transform(_ event: CGEvent) -> CGEvent? {
       guard let device = self.device else {
            return nil
        }

        guard let eventDevice = DeviceManager.shared.inputDeviceFromCGEvent(event) else {
            return event
        }

        guard device.locationID == eventDevice.locationID else {
            return event
        }
        
        switch (event.type) {
        case .mouseMoved:
            return transformToDragged(event)

        case .keyUp:
            return transformToUp(event)
            
        case .keyDown:
            return transformToDown(event)
            
        default:
            return event
        }
    }
    
    func transformToDragged(_ event: CGEvent) -> CGEvent? {
        guard event.location != lastLocationDragged else {
            return nil
        }
        
        guard let mouseButton = pressedButtons.first else {
            return event
        }

        guard let mouseEvent = CGEvent(
            mouseEventSource: nil,
            mouseType: mouseButton.fixedCGEventType(of: .leftMouseDragged),
            mouseCursorPosition: event.location,
            mouseButton: mouseButton
        ) else {
            return nil
        }
        
        mouseEvent.setIntegerValueField(.mouseEventDeltaX, 
                                        value: event.getIntegerValueField(.mouseEventDeltaX))
        mouseEvent.setIntegerValueField(.mouseEventDeltaY,
                                        value: event.getIntegerValueField(.mouseEventDeltaY))
        
        lastLocationDragged = event.location

        switchToDevice()

        mouseEvent.post(tap: .cghidEventTap)

        return nil
    }
    
    func transformToUp(_ event: CGEvent) -> CGEvent? {
        let keyboardEventView = KeyboardEventView(event)
        
        guard let mouseButton = keyboardEventView.mouseButtonForKeyCode else {
            return nil
        }
        
        guard let pressedButtonIndex = pressedButtons.firstIndex(of: mouseButton) else {
            os_log("here")
            return nil
        }
        
        guard let mouseEvent = CGEvent(
            mouseEventSource: nil,
            mouseType: mouseButton.fixedCGEventType(of: .leftMouseUp),
            mouseCursorPosition: event.location,
            mouseButton: mouseButton
        ) else {
            return nil
        }
        
        lastLocationDragged = nil
        
        switchToDevice()

        mouseEvent.post(tap: .cghidEventTap)
        
        pressedButtons.remove(at: pressedButtonIndex)
        
        return nil
    }
    
    func transformToDown(_ event: CGEvent) -> CGEvent? {
        let keyboardEventView = KeyboardEventView(event)
        
        guard let mouseButton = keyboardEventView.mouseButtonForKeyCode else {
            return nil
        }
        
        guard !pressedButtons.contains(mouseButton) else {
            return nil
        }

        guard let mouseEvent = CGEvent(
            mouseEventSource: nil,
            mouseType: mouseButton.fixedCGEventType(of: .leftMouseDown),
            mouseCursorPosition: event.location,
            mouseButton: mouseButton
        ) else {
            return nil
        }
        
        mouseEvent.setIntegerValueField(.mouseEventClickState, value: 1)
        
        switchToDevice()
        
        lastLocationDragged = nil

        mouseEvent.post(tap: .cghidEventTap)
        
        pressedButtons.append(mouseButton)
        
        return nil
    }
    
    func switchToDevice() {
        if (DeviceManager.shared.lastActiveDeviceRef?.value != device) {
            DeviceManager.shared.lastActiveDeviceRef = .init(device!)
            os_log("""
                   Last active device changed: %{public}@, category=%{public}@ \
                   (Reason: Mapped key to button)
                   """,
                   log: Self.log, type: .info,
                   String(describing: device),
                   String(describing: device!.category))
        }
    }
}
