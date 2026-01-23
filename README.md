# SongCapture (WIP)
SongCapture is an iOS app for quickly saving songs, captured either from music playing nearby or from music app screenshots, and adding them to pre-selected playlists in one go.

The goal of this project is both educational and functional - learning best modern iOS development practices and creating an app that helps bulk add songs from screenshots that I aquire from scrolling online to my music library. 

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

### Combine
Binding view models to UI

### ShazamKit
Song recognition from the microphone

### Vision
On-device Optical Character Recognizition (OCR) from screenshots

### MusicKit and Spotify Web API
Catalog searching and playlist adding

## AI & ML Transparency
With major goals for this project being educational (learning modern iOS development practices, learning to work with new (to me) frameworks, learning how to work with an AI pair programmer) AI is being used carefully and with clear intent. 
- UI layout assistance
- Debugging and error resolution
- Pattern-consistent code generation where understanding is already established

Core logic and architecture are written by hand. There is no blind copy-paste AI-generated code.

This project uses machine learning only through Apple-provided, on-device frameworks (Vision and ShazamKit). No custom models are trained or deployed.

## Architecture
This codebase will follow a "clean"-inspired architecture. What this actually means will be better defined as the project grows, but today's goals are: 
- Clear separation between UI, business logic, and data.
- Protocol driven abstractions where appropriate
- Easily Testable

Current architecture involves the following:
- **Presentation layer**
  - App Coordinator - handles dependency injection and navigation between view controllers
  - View Models/View Controllers
    - UploadViewModel/ViewController
    - ListenViewModel/ViewController
    - PlaylistsAndGroupsViewModel/ViewController
    - GroupEditorViewModel/ViewController
    - RemotePlaylistsSelectionViewModel/ViewController
- **Domain**
  - Repository Protocols
    - LibraryRepository - Conforming type should save and fetch saved playlists and playlist groups 
    - MusicRemoteRepository - Conforming type should provide playlists from remote music service
    - MusicAuthRepository - Conforming type should fetch music service authorization status and request authorization
  - Use Cases protocols & Impls
    - LoadLibraryUseCase - Depended on by PlaylistsAndGroupsVM/VC to show user's saved playlists and playlist groups. Depends on LibraryRepository
    - ConnectServiceUseCase - Depended on by GroupEditorVM/VC to connect to user's music service. Depends on MusicAuthRepository
    - LoadGroupUseCase - Depended on by GroupEditorVM/VC to load a user's saved playlist group details. Depends on LibraryRepository
    - SavePlaylistsUseCase - Depended on by GroupEditorVM/VC to save playlists selected from RemotePlaylistsSelectionVM/VC. Depends on LibraryRepository
    - SaveGroupUseCase - Depended on by GroupEditorVM/VC to save playlists selected from RemotePlaylistsSelectionVM/VC to the current playlist group. Depends on LibraryRepository
    - LoadRemoteUseCase - Depended on by RemotePlaylistsSelectionVM/VC to load user's playlists from music service. Depends on MusicRemoteRepository
- **Data**
  - Repository: LibraryRepository, MusicRemoteRepository, MusicAuthRepository
  - MusicLibraryRemote protocol - Conforming type should fetch playlists from music service
    - AppleMusicRemote: MusicLibraryRemote - fetches user's playlist from Apple Music
    - SpotifyRemote: MusicLibraryRemote - fetches user's playlists from Spotify 
  - MusicAuthRemote protocol & Impl - fetches music service authorization status and requests authorization

## Work Log
### Current Work
#### Playlists/Playlist Groups Flow cont.
- Edit group titles
- Pagination for remote playlists
    - Caching
- Disk storage 
  
### Next Up
#### Song Matching Flow
- Present UI upon song match
  - Show matched song and artwork
  - Show playlists and groups UI for selecting
  - Add matched song to selected playlist and group
  

### Previous Work
#### Playlist Groups Flow [[PR](https://github.com/jtjones98/SongCapture/pull/4)]
- User should be able to create a new playlist group, connect to Apple Music and/or Spotify, and add playlists from either service to group.
![PlaylistGroupsFlow](https://github.com/user-attachments/assets/5a6c7503-bdf1-4cac-a5d7-ea17b1c1496c)









