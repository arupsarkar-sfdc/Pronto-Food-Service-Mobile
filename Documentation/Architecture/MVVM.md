# MVVM Architecture Guide

## Overview

This application follows the Model-View-ViewModel (MVVM) architectural pattern with SwiftUI.

## Structure

### Models
- Pure data structures
- No UI dependencies
- Conform to Codable for serialization

### Views
- SwiftUI views
- Declarative UI
- Observe ViewModels via @StateObject/@ObservedObject

### ViewModels
- Business logic
- State management
- Conform to ObservableObject
- Use @Published for reactive properties

## Best Practices

1. Keep Views lightweight
2. Put business logic in ViewModels
3. Use dependency injection
4. Make ViewModels testable
