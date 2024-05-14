// MIT License
// Copyright (c) 2021-2024 LinearMouse

import CoreGraphics

// - SeeAlso:
// https://github.com/WebKit/WebKit/blob/ab59722dc517c798f7d88bfe4dcb7b33b8473e7e/Tools/TestRunnerShared/spi/CoreGraphicsTestSPI.h#L39
extension CGEventField {
    static let gestureUnixProcessID = Self(rawValue: 41)!
    static let gestureHIDType = Self(rawValue: 110)!
    static let gestureZoomValue = Self(rawValue: 113)!
    static let gestureSwipeValue = Self(rawValue: 115)!
    static let gestureDockWeirdType = Self(rawValue: 119)!
    static let gestureDockType = Self(rawValue: 123)!
    static let gestureDockOriginOffset = Self(rawValue: 124)!
    static let gestureExitSpeed = Self(rawValue: 129)!
    static let gestureExitSpeed2 = Self(rawValue: 130)!
    static let gesturePhase = Self(rawValue: 132)!
    static let gesturePhase2 = Self(rawValue: 134)!
    static let gestureDockOriginOffset2 = Self(rawValue: 135)!
    static let gestureDockInverted = Self(rawValue: 136)!
    static let gestureDockWeirdType2 = Self(rawValue: 139)!
    static let gestureDockType2 = Self(rawValue: 165)!
}

// - SeeAlso:
// https://github.com/WebKit/WebKit/blob/ab59722dc517c798f7d88bfe4dcb7b33b8473e7e/Tools/TestRunnerShared/spi/CoreGraphicsTestSPI.h#L87
public enum CGSGesturePhase: UInt8 {
    case none = 0
    case began = 1
    case changed = 2
    case ended = 4
    case cancelled = 8
    case mayBegin = 128
}

// - SeeAlso:
// https://github.com/WebKit/WebKit/blob/52d85940c6acce0f6b25fe1f8155c25283058e27/Source/WebCore/PAL/pal/spi/mac/IOKitSPIMac.h#L74
enum IOHIDEventType: UInt32 {
    case none
    case vendorDefined
    case keyboard = 3
    case rotation = 5
    case scroll = 6
    case zoom = 8
    case digitizer = 11
    case navigationSwipe = 16
    case zoomToggle = 22
    case dock = 23
    case force = 32
}

// - SeeAlso: https://opensource.apple.com/source/IOHIDFamily/IOHIDFamily-368.13/IOHIDFamily/IOHIDEventTypes.h.auto.html
public enum IOHIDSwipeMask: UInt32 {
    case swipeUp = 0x01
    case swipeDown = 0x02
    case swipeLeft = 0x04
    case swipeRight = 0x08
    case scaleExpand = 0x10
    case scaleContract = 0x20
    case rotateCW = 0x40
    case rotateCCW = 0x80
}

// - SeeAlso:
// https://github.com/noah-nuebling/mac-mouse-fix/blob/7a35c03b90933dc5b8176893f932a0f937fde04a/Helper/Core/Touch/TouchSimulator.h#L17
public enum IOHIDDockSwipeType: UInt32 {
    case horizontal = 1
    case vertical = 2
    case pinch = 3
}
