// MIT License
// Copyright (c) 2021-2024 LinearMouse

import SwiftUI

struct MapKeyboardKeysToMouseButtonsSection: View {
    @ObservedObject var state: ButtonsSettingsState = .shared

    var body: some View {
        Section {
            Toggle(isOn: $state.mapKeyboardKeysToMouseButtons) {
                withDescription {
                    Text("Map keyboard keys to mouse buttons")
                    Text(
                        "Map keyboard keys A-Z and F1-F6 to mouse buttons 1 to 32. This brings compatibility for mice that emit non-standard events."
                    )
                }
            }
        }
        .modifier(SectionViewModifier())
    }
}
