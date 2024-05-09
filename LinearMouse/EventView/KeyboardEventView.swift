// MIT License
// Copyright (c) 2021-2024 LinearMouse

import AppKit
import Foundation
import LRUCache

class KeyboardEventView: EventView {
    var type: CGEventType {
        get {
            return event.type
        }

        set {
            event.type = newValue
        }
    }

    var keyCode: CGKeyCode? {
        get {
            guard let keyCode = CGKeyCode(exactly: event.getIntegerValueField(.keyboardEventKeycode)) else {
                return nil
            }
            return keyCode
        }

        set {
            guard let newValue = newValue else {
                return
            }

            event.setIntegerValueField(.keyboardEventKeycode, value: Int64(newValue))
        }
    }

    var keyCodeDescription: String {
        guard let keyCode = keyCode else {
            return "(nil)"
        }

        return "<keyCode \(keyCode)>"
    }

    var sourcePid: pid_t? {
        let pid = pid_t(event.getIntegerValueField(.eventSourceUnixProcessID))
        guard pid > 0 else {
            return nil
        }
        return pid
    }

    var targetPid: pid_t? {
        let pid = pid_t(event.getIntegerValueField(.eventTargetUnixProcessID))
        guard pid > 0 else {
            return nil
        }
        return pid
    }
}
