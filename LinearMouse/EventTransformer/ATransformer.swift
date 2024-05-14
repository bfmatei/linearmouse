// MIT License
// Copyright (c) 2021-2024 LinearMouse

import Foundation
import os.log
import KeyKit
import InputKit
import DockKit
import GestureKit
import AppKit

class ATransformer: EventTransformer {
    static let log = OSLog(
        subsystem: Bundle.main.bundleIdentifier!,
        category: "ATransformer"
    )
    
    var originOffset: Double?
    var lastDelta: Double?
    var type: IOHIDDockSwipeType?
    
    let keySimulator = KeySimulator()

    init() {}

    func transform(_ event: CGEvent) -> CGEvent? {
        let eventView = MouseEventView(event)
        
        switch (event.type) {
        case .otherMouseDragged:
            if originOffset != nil {
                let isHorizontal = type == .horizontal
                let d = isHorizontal ? -Double(eventView.deltaXX!) * getHorizontalMultiplier() : Double(eventView.deltaYY!) * getVerticalMultiplier()
                if (d == 0) {
                    return nil
                }
                originOffset! += d
                GestureEvent(dockSwipeSource: nil, type: type!, phase: .changed, originOffset: originOffset!, lastDelta: lastDelta!)?.post(tap: .cgSessionEventTap)
                lastDelta = d
            } else {
                let isHorizontal = eventView.deltaXX != nil && eventView.deltaXX != 0
                type = isHorizontal ? .horizontal : .vertical
                originOffset = isHorizontal ? -Double(eventView.deltaXX!) * getHorizontalMultiplier() : Double(eventView.deltaYY!) * getVerticalMultiplier()
                GestureEvent(dockSwipeSource: nil, type: type!, phase: .began, originOffset: originOffset!, lastDelta: 0)?.post(tap: .cgSessionEventTap)
                lastDelta = originOffset
            }
 
        case .otherMouseUp:
            guard type != nil else {
                return nil
            }
            
            GestureEvent(dockSwipeSource: nil, type: type!, phase: originOffset == lastDelta ? .cancelled : .ended, originOffset: originOffset!, lastDelta: lastDelta!)?.post(tap: .cgSessionEventTap)
            
            originOffset = nil
            lastDelta = nil
            type = nil
            
        default:
            return event
        }

        return nil
    }
    
    private func getVerticalMultiplier() -> Double {
        let screenSize = NSScreen.main?.frame.size.height ?? 1080
        return 1.0 / screenSize
    }
    
    private func getHorizontalMultiplier() -> Double {
        let screenSize = NSScreen.main?.frame.size.width ?? 1920
        let originOffsetForOneSpace: Double = 2;
        let spaceSeparatorWidth: Double = 63;
        return originOffsetForOneSpace / (screenSize + spaceSeparatorWidth);
    }
}
