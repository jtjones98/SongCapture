//
//  ArtworkThumbnailView.swift
//  SongCapture
//
//  Created by John Jones on 1/17/26.
//

import MusicKit
import SwiftUI

struct ArtworkThumbnailView: View {
    let artwork: Artwork?
    let size: CGFloat
    
    var body: some View {
        if let artwork {
            ArtworkImage(artwork, width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        } else {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.tertiarySystemFill))
        }
    }
}
