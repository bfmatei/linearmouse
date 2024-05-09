// MIT License
// Copyright (c) 2021-2024 LinearMouse

import AppKit
import Foundation
import LRUCache
import SwiftUI

extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(range.lowerBound, self), range.upperBound)
    }
}

extension BinaryInteger {
    func normalized(fromLowerBound: Self = 0, fromUpperBound: Self = 1, toLowerBound: Self = 0,
                    toUpperBound: Self = 1) -> Self {
        let k = (toUpperBound - toLowerBound) / (fromUpperBound - fromLowerBound)
        return (self - fromLowerBound) * k + toLowerBound
    }

    func normalized(from: ClosedRange<Self> = 0 ... 1, to: ClosedRange<Self> = 0 ... 1) -> Self {
        normalized(fromLowerBound: from.lowerBound, fromUpperBound: from.upperBound,
                   toLowerBound: to.lowerBound, toUpperBound: to.upperBound)
    }
}

extension BinaryFloatingPoint {
    func normalized(fromLowerBound: Self = 0, fromUpperBound: Self = 1, toLowerBound: Self = 0,
                    toUpperBound: Self = 1) -> Self {
        let k = (toUpperBound - toLowerBound) / (fromUpperBound - fromLowerBound)
        return (self - fromLowerBound) * k + toLowerBound
    }

    func normalized(from: ClosedRange<Self> = 0 ... 1, to: ClosedRange<Self> = 0 ... 1) -> Self {
        normalized(fromLowerBound: from.lowerBound, fromUpperBound: from.upperBound,
                   toLowerBound: to.lowerBound, toUpperBound: to.upperBound)
    }
}

extension Decimal {
    var asTruncatedDouble: Double {
        Double(truncating: self as NSNumber)
    }

    func rounded(_ scale: Int) -> Self {
        var roundedValue = Decimal()
        var mutableSelf = self
        NSDecimalRound(&roundedValue, &mutableSelf, scale, .plain)
        return roundedValue
    }
}

extension pid_t {
    private static var bundleIdentifierCache = LRUCache<Self, String>(countLimit: 16)

    var bundleIdentifier: String? {
        guard let bundleIdentifier = Self.bundleIdentifierCache.value(forKey: self)
            ?? NSRunningApplication(processIdentifier: self)?.bundleIdentifier
        else {
            return nil
        }

        Self.bundleIdentifierCache.setValue(bundleIdentifier, forKey: self)

        return bundleIdentifier
    }

    var parent: pid_t? {
        let pid = getProcessInfo(self).ppid

        guard pid > 0 else {
            return nil
        }

        return pid
    }

    var group: pid_t? {
        let pid = getProcessInfo(self).pgid

        guard pid > 0 else {
            return nil
        }

        return pid
    }
}

extension CGKeyCode {
    static let a = CGKeyCode(0x00)
    static let b = CGKeyCode(0x0B)
    static let c = CGKeyCode(0x08)
    static let d = CGKeyCode(0x02)
    static let e = CGKeyCode(0x0E)
    static let f = CGKeyCode(0x03)
    static let g = CGKeyCode(0x05)
    static let h = CGKeyCode(0x04)
    static let i = CGKeyCode(0x22)
    static let j = CGKeyCode(0x26)
    static let k = CGKeyCode(0x28)
    static let l = CGKeyCode(0x25)
    static let m = CGKeyCode(0x2E)
    static let n = CGKeyCode(0x2D)
    static let o = CGKeyCode(0x1F)
    static let p = CGKeyCode(0x23)
    static let q = CGKeyCode(0x0C)
    static let r = CGKeyCode(0x0F)
    static let s = CGKeyCode(0x01)
    static let t = CGKeyCode(0x11)
    static let u = CGKeyCode(0x20)
    static let v = CGKeyCode(0x09)
    static let w = CGKeyCode(0x0D)
    static let x = CGKeyCode(0x07)
    static let y = CGKeyCode(0x10)
    static let z = CGKeyCode(0x06)
    static let f1 = CGKeyCode(0x7A)
    static let f2 = CGKeyCode(0x78)
    static let f3 = CGKeyCode(0x63)
    static let f4 = CGKeyCode(0x76)
    static let f5 = CGKeyCode(0x60)
    static let f6 = CGKeyCode(0x61)

}

extension CGMouseButton {
    static let back = CGMouseButton(rawValue: 3)!
    static let forward = CGMouseButton(rawValue: 4)!
    static let button5 = CGMouseButton(rawValue: 5)!
    static let button6 = CGMouseButton(rawValue: 6)!
    static let button7 = CGMouseButton(rawValue: 7)!
    static let button8 = CGMouseButton(rawValue: 8)!
    static let button9 = CGMouseButton(rawValue: 9)!
    static let button10 = CGMouseButton(rawValue: 10)!
    static let button11 = CGMouseButton(rawValue: 11)!
    static let button12 = CGMouseButton(rawValue: 12)!
    static let button13 = CGMouseButton(rawValue: 13)!
    static let button14 = CGMouseButton(rawValue: 14)!
    static let button15 = CGMouseButton(rawValue: 15)!
    static let button16 = CGMouseButton(rawValue: 16)!
    static let button17 = CGMouseButton(rawValue: 17)!
    static let button18 = CGMouseButton(rawValue: 18)!
    static let button19 = CGMouseButton(rawValue: 19)!
    static let button20 = CGMouseButton(rawValue: 20)!
    static let button21 = CGMouseButton(rawValue: 21)!
    static let button22 = CGMouseButton(rawValue: 22)!
    static let button23 = CGMouseButton(rawValue: 23)!
    static let button24 = CGMouseButton(rawValue: 24)!
    static let button25 = CGMouseButton(rawValue: 25)!
    static let button26 = CGMouseButton(rawValue: 26)!
    static let button27 = CGMouseButton(rawValue: 27)!
    static let button28 = CGMouseButton(rawValue: 28)!
    static let button29 = CGMouseButton(rawValue: 29)!
    static let button30 = CGMouseButton(rawValue: 30)!
    static let button31 = CGMouseButton(rawValue: 31)!
    static let button32 = CGMouseButton(rawValue: 32)!

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

    func fixedCGEventType(of eventType: CGEventType) -> CGEventType {
        func fixed(of type: CGEventType, _ l: CGEventType, _ r: CGEventType, _ o: CGEventType) -> CGEventType {
            guard type == l || type == r || type == o else {
                return type
            }
            return self == .left ? l : self == .right ? r : o
        }

        var eventType = eventType
        eventType = fixed(of: eventType, .leftMouseDown, .rightMouseDown, .otherMouseDown)
        eventType = fixed(of: eventType, .leftMouseUp, .rightMouseUp, .otherMouseUp)
        eventType = fixed(of: eventType, .leftMouseDragged, .rightMouseDragged, .otherMouseDragged)
        return eventType
    }

    static func fromKeyCode(_ keyCode: CGKeyCode) -> CGMouseButton? {
        return Self.keyCodeToMouseButton[keyCode]
    }
    
    static func canGetFromKeyCode(_ keyCode: CGKeyCode) -> Bool {
        return Self.fromKeyCode(keyCode) != nil
    }
}

extension CGMouseButton: Codable {}

extension Binding {
    func `default`<UnwrappedValue>(_ value: UnwrappedValue) -> Binding<UnwrappedValue> where Value == UnwrappedValue? {
        Binding<UnwrappedValue>(get: { wrappedValue ?? value }, set: { wrappedValue = $0 })
    }
}
