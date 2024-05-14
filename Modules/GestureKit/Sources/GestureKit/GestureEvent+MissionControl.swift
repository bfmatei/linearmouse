// MIT License
// Copyright (c) 2021-2024 LinearMouse

import CoreGraphics
import os.log
import AppKit

public extension GestureEvent {
    static let UnixProcessID = Int64(33231)
    
    convenience init?(dockSwipeSource: CGEventSource?, type: IOHIDDockSwipeType, phase: CGSGesturePhase, originOffset: Double, lastDelta: Double) {
        guard let gestureEvent = CGEvent(source: dockSwipeSource) else {
            return nil
        }

        guard let magnifyEvent = CGEvent(source: dockSwipeSource) else {
            return nil
        }
        
        var ofsFloat32 = Float32(originOffset)
        var ofsInt32 = UInt32()
        memcpy(&ofsInt32, &ofsFloat32, MemoryLayout.size(ofValue: ofsFloat32))
        let originValueInt =  Int64(ofsInt32);

        gestureEvent.type = .init(nsEventType: .gesture)!
        gestureEvent.setDoubleValueField(.gestureUnixProcessID, value: Self.UnixProcessID)
        
        magnifyEvent.type = .init(nsEventType: .magnify)!
        magnifyEvent.setIntegerValueField(.gestureHIDType, value: Int64(IOHIDEventType.dock.rawValue))
        magnifyEvent.setIntegerValueField(.gesturePhase, value: Int64(phase.rawValue))
//        magnifyEvent.setDoubleValueField(.gesturePhase2, value: Double(phase.rawValue))
        magnifyEvent.setDoubleValueField(.gestureDockOriginOffset, value: originOffset)
//        magnifyEvent.setIntegerValueField(.gestureDockOriginOffset2, value: originValueInt)
        magnifyEvent.setIntegerValueField(.gestureUnixProcessID, value: Self.UnixProcessID)
        
        let weirdTypeOrSum: Double
        
        if (type == .horizontal) {
            weirdTypeOrSum = 1.401298464324817e-45;
        } else if (type == .vertical) {
            weirdTypeOrSum = 2.802596928649634e-45;
        } else if (type == .pinch) {
            weirdTypeOrSum = 4.203895392974451e-45;
        } else {
            self.init(cgEvents: [])
            
            return
        }
        
//        magnifyEvent.setDoubleValueField(.gestureDockWeirdType, value: weirdTypeOrSum)
//        magnifyEvent.setDoubleValueField(.gestureDockWeirdType2, value: weirdTypeOrSum)
        magnifyEvent.setDoubleValueField(.gestureDockType, value: Double(type.rawValue))
        magnifyEvent.setDoubleValueField(.gestureDockType2, value: Double(type.rawValue))
//        magnifyEvent.setIntegerValueField(.gestureDockInverted, value: 0)
        
        if (phase == .ended || phase == .cancelled) {
            let exitSpeed = lastDelta * 100
            
            magnifyEvent.setDoubleValueField(.gestureExitSpeed, value: exitSpeed)
            magnifyEvent.setDoubleValueField(.gestureExitSpeed2, value: exitSpeed)
        }
        
        self.init(cgEvents: [magnifyEvent, gestureEvent])
    }
}
