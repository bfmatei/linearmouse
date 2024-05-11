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

    let interestedKeyboardEvents = [
        CGEventType.keyUp,
        CGEventType.keyDown,
    ]

    let device: Device?

    init(_ device: Device?) {
        self.device = device
    }

    func transform(_ event: CGEvent) -> CGEvent? {
        let keyboardEventView = KeyboardEventView(event)

        guard shouldHandleEvent(keyboardEventView) else {
            return event
        }

        let mouseButton = CGMouseButton.fromKeyCode(keyboardEventView.keyCode!)!

        guard let mouseEvent = CGEvent(
            mouseEventSource: CGEventSource(event: event),
            mouseType: mouseButton.fixedCGEventType(of: keyboardEventView.type == .keyDown ? .leftMouseDown : .leftMouseUp),
            mouseCursorPosition: event.location,
            mouseButton: mouseButton
        ) else {
            return nil
        }

        mouseEvent.post(tap: .cghidEventTap)

        let mouseEventView = MouseEventView(mouseEvent)

        os_log(
            "Mapped %{public}s to %{public}s",
            log: Self.log,
            type: .info,
            keyboardEventView.keyCodeDescription,
            mouseEventView.mouseButtonDescription
        )

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

        return nil
    }

    private func shouldHandleEvent(_ view: KeyboardEventView) -> Bool {
        guard let device = self.device else {
            return false
        }

        guard interestedKeyboardEvents.contains(view.type) else {
            return false
        }

        guard let eventDevice = DeviceManager.shared.inputDeviceFromCGEvent(view.event) else {
            return false
        }

        guard device.locationID == eventDevice.locationID else {
            return false
        }

        guard let keyCode = view.keyCode else {
            return false
        }

        guard CGMouseButton.canGetFromKeyCode(keyCode) else {
            return false
        }

        guard view.targetPid?.bundleIdentifier != nil else {
            return false
        }

        return true
    }
}
