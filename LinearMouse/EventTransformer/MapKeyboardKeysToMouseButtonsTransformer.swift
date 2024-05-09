// MIT License
// Copyright (c) 2021-2024 LinearMouse

import Foundation
import os.log
import KeyKit
import PointerKit

class MapKeyboardKeysToMouseButtonsTransformer: EventTransformer {
    static let log = OSLog(
        subsystem: Bundle.main.bundleIdentifier!,
        category: "MapKeyboardKeysToMouseButtonsTransformer"
    )

    let interestedKeyboardEvents = [
        CGEventType.keyUp,
        CGEventType.keyDown,
    ]

    init() {}

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

        mouseEvent.post(tap: .cgSessionEventTap)

        let mouseEventView = MouseEventView(mouseEvent)

        os_log(
            "Mapped %{public}s to %{public}s",
            log: Self.log,
            type: .info,
            keyboardEventView.keyCodeDescription,
            mouseEventView.mouseButtonDescription
        )

        return nil
    }

    private func shouldHandleEvent(_ view: KeyboardEventView) -> Bool {
        guard interestedKeyboardEvents.contains(view.type) else {
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
