//
//  ChatPersonalizationWidget.swift
//  ProntoFoodDeliveryApp
//
//  Dynamic personalization widget that appears in the Agentforce chat
//  and updates in real-time based on detected keywords.
//

import SwiftUI

// MARK: - Chat Personalization Widget

struct ChatPersonalizationWidget: View {
    @ObservedObject var viewModel: ChatPersonalizationViewModel
    let onDismiss: () -> Void
    let onAction: (String) -> Void
    
    @State private var isExpanded = true
    
    var body: some View {
        if let decision = viewModel.currentDecision {
            expandedWidget(decision: decision)
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .move(edge: .top).combined(with: .opacity)
                ))
        }
    }
    
    // MARK: - Expanded Widget
    
    private func expandedWidget(decision: ChatPersonalizationDecision) -> some View {
        VStack(spacing: 0) {
            // Header
            headerView(decision: decision)
            
            // Content
            contentView(decision: decision)
            
            // Action Button
            actionButton(decision: decision)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.3), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .padding(.horizontal, 16)
    }
    
    // MARK: - Header View
    
    private func headerView(decision: ChatPersonalizationDecision) -> some View {
        HStack(spacing: 12) {
            // Animated indicator
            Circle()
                .fill(
                    RadialGradient(
                        colors: [.green, .green.opacity(0.5)],
                        center: .center,
                        startRadius: 0,
                        endRadius: 6
                    )
                )
                .frame(width: 8, height: 8)
                .overlay(
                    Circle()
                        .stroke(.green.opacity(0.3), lineWidth: 2)
                        .scaleEffect(1.5)
                )
            
            Text("Personalized for You")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)
            
            Spacer()
            
            // Confidence badge
            if decision.confidence > 0.8 {
                Text("🎯 \(Int(decision.confidence * 100))% match")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(.green)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(.green.opacity(0.15))
                    )
            }
            
            // Dismiss button
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
                    .padding(6)
                    .background(Circle().fill(.quaternary))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
        )
    }
    
    // MARK: - Content View
    
    private func contentView(decision: ChatPersonalizationDecision) -> some View {
        HStack(spacing: 16) {
            // Emoji/Image
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.orange.opacity(0.3), .pink.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 64, height: 64)
                
                Text(decision.emoji)
                    .font(.system(size: 32))
            }
            
            // Details
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(decision.name)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                    
                    if let discount = decision.discount {
                        Text(discount)
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [.red, .orange],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                    }
                }
                
                if let subheader = decision.subheader {
                    Text(subheader)
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
        }
        .padding(16)
    }
    
    // MARK: - Action Button
    
    private func actionButton(decision: ChatPersonalizationDecision) -> some View {
        Button(action: {
            onAction(decision.callToActionUrl ?? "")
            
            // Haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }) {
            HStack {
                Text(decision.callToActionText ?? "View")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 13, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                LinearGradient(
                    colors: [.blue, .purple],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
}

// MARK: - Minimized Floating Button

struct PersonalizationFloatingButton: View {
    @ObservedObject var viewModel: ChatPersonalizationViewModel
    let onTap: () -> Void
    
    var body: some View {
        if viewModel.currentDecision != nil && !viewModel.isWidgetVisible {
            Button(action: onTap) {
                HStack(spacing: 8) {
                    if let decision = viewModel.currentDecision {
                        Text(decision.emoji)
                            .font(.system(size: 20))
                        
                        Text(decision.name)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        if let discount = decision.discount {
                            Text(discount)
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(.red)
                        }
                    }
                    
                    Image(systemName: "chevron.up")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                )
            }
            .transition(.scale.combined(with: .opacity))
        }
    }
}

// MARK: - Loading Indicator

struct PersonalizationLoadingIndicator: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(.blue)
                    .frame(width: 8, height: 8)
                    .scaleEffect(isAnimating ? 1.0 : 0.5)
                    .animation(
                        .easeInOut(duration: 0.6)
                        .repeatForever()
                        .delay(Double(index) * 0.2),
                        value: isAnimating
                    )
            }
            
            Text("Finding recommendations...")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
        )
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Keyword Input Field

struct KeywordInputField: View {
    @Binding var text: String
    let onSubmit: () -> Void
    let onTextChange: (String) -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 16))
                .foregroundColor(.blue)
            
            TextField("Type a food (pizza, sushi...)", text: $text)
                .font(.system(size: 15, design: .rounded))
                .textFieldStyle(.plain)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .onChange(of: text) { _, newValue in
                    onTextChange(newValue)
                }
                .onSubmit(onSubmit)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.quaternary, lineWidth: 1)
        )
        .padding(.horizontal, 16)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color(.systemGroupedBackground)
            .ignoresSafeArea()
        
        VStack {
            Spacer()
            
            ChatPersonalizationWidget(
                viewModel: {
                    let vm = ChatPersonalizationViewModel()
                    Task { @MainActor in
                        vm.fetchPersonalization(for: "pizza")
                    }
                    return vm
                }(),
                onDismiss: {},
                onAction: { _ in }
            )
            
            Spacer()
        }
    }
}

