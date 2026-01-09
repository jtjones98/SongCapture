# SongCapture (WIP)
SongCapture is an iOS app for quickly saving songs, captured either from music playing nearby or from music app screenshots, and adding them to pre-selected playlists in one go.

The goal of this project is both educational and functional - learning best modern iOS development practices and creating an app that helps bulk add songs from screenshots that are aquired from scrolling online to a music library. 

When completed, SongCapture will include the following features:
- Identify songs playing nearby
- Identify songs from music app screenshots such as Apple Music and Spotify
- Automatically add identified songs to any number of playlists across Apple Music and Spotify
- An app extension to quickly add songs to specific playlists upon taking a screenshot

## Frameworks
### UIKit & SwiftUI
This project will start off fully UIKit with plans to slowly replace views with SwiftUI throughout project development. Reasoning for this is purely educational, ensuring there's a clear understanding of:
- UIKit essentials, lifecycle, UI creation, etc
- How to bridge between UIKit code and SwiftUI
- Gradual UI modernization strategies 

### ShazamKit
Song recognition from the microphone

### Vision
On-device Optical Character Recognizition (OCR) from screenshots

### MusicKit and Spotify Web API
Catalog searching and playlist adding

## Architecture
This codebase will follow a "clean"-inspired architecture. What this actually means will be better defined as the project grows, but today's goals are: 
- Clear separation between UI, business logic, and data.
- Protocol driven abstractions where appropriate
- Easily Testable

## AI & ML Transparency
With major goals for this project being educational (learning modern iOS development practices, learning to work with new (to me) frameworks, learning how to work with an AI pair programmer) AI is being used carefully and with clear intent. 
- UI layout assistance
- Debugging and error resolution
- Pattern-consistent code generation where understanding is already established

Core logic and architecture are written by hand. There is no blind copy-paste AI-generated code.

This project uses machine learning only through Apple-provided, on-device frameworks (Vision and ShazamKit). No custom models are trained or deployed.







