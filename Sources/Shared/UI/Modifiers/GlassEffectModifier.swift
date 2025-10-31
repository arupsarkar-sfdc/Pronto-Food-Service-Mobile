//
//  GlassEffectModifier.swift
//  ProntoFoodDeliveryApp
//
//  Apple's Liquid Glass effect modifier
//  Based on: https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass
//

import SwiftUI

/// View modifier that applies Apple's Liquid Glass effect
struct GlassEffectModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
    }
}

extension View {
    /// Applies Apple's Liquid Glass effect to the view
    /// 
    /// The glass effect uses ultra thin material for a subtle, translucent appearance
    /// that adapts to light and dark modes automatically.
    func glassEffect() -> some View {
        modifier(GlassEffectModifier())
    }
}

