// MIT License
// Copyright (c) 2021-2024 LinearMouse

import AppKit
import Foundation
import LRUCache

class KeyboardEventView: EventView {
    private static let keyCodeToMouseButton: [CGKeyCode: CGMouseButton] = [
        CGKeyCode.a: CGMouseButton.left,
        CGKeyCode.b: CGMouseButton.right,
        CGKeyCode.c: CGMouseButton.center,
        CGKeyCode.d: CGMouseButton.back,
        CGKeyCode.e: CGMouseButton.forward,
        CGKeyCode.f: CGMouseButton.button5,
        CGKeyCode.g: CGMouseButton.button6,
        CGKeyCode.h: CGMouseButton.button7,
        CGKeyCode.i: CGMouseButton.button8,
        CGKeyCode.j: CGMouseButton.button9,
        CGKeyCode.k: CGMouseButton.button10,
        CGKeyCode.l: CGMouseButton.button11,
        CGKeyCode.m: CGMouseButton.button12,
        CGKeyCode.n: CGMouseButton.button13,
        CGKeyCode.o: CGMouseButton.button14,
        CGKeyCode.p: CGMouseButton.button15,
        CGKeyCode.q: CGMouseButton.button16,
        CGKeyCode.r: CGMouseButton.button17,
        CGKeyCode.s: CGMouseButton.button18,
        CGKeyCode.t: CGMouseButton.button19,
        CGKeyCode.u: CGMouseButton.button20,
        CGKeyCode.v: CGMouseButton.button21,
        CGKeyCode.w: CGMouseButton.button22,
        CGKeyCode.x: CGMouseButton.button23,
        CGKeyCode.y: CGMouseButton.button24,
        CGKeyCode.z: CGMouseButton.button25,
        CGKeyCode.f1: CGMouseButton.button26,
        CGKeyCode.f2: CGMouseButton.button27,
        CGKeyCode.f3: CGMouseButton.button28,
        CGKeyCode.f4: CGMouseButton.button29,
        CGKeyCode.f5: CGMouseButton.button30,
        CGKeyCode.f6: CGMouseButton.button31,
    ]
    
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
    
    var mouseButtonForKeyCode: CGMouseButton? {
        guard let keyCode = keyCode else {
            return nil
        }
        
        return Self.keyCodeToMouseButton[keyCode]
    }
    
    var mouseEventTypeForType: CGEventType? {
        if (type == .keyUp) {
            return .leftMouseUp
        } else if (type == .keyDown) {
            return .leftMouseDown
        } else {
            return nil
        }
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
