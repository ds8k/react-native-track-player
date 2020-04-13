//
//  Metadata.swift
//  RNTrackPlayer
//
//  Created by David Chavez on 23.06.19.
//  Copyright © 2019 David Chavez. All rights reserved.
//

import Foundation
import MediaPlayer

struct Metadata {
    private static var currentImageTask: URLSessionDataTask?

    static func update(for player: AudioPlayer, with metadata: [String: Any]) {
        currentImageTask?.cancel()
        var ret: [NowPlayingInfoKeyValue] = []
        
        if let title = metadata["title"] as? String {
            ret.append(MediaItemProperty.title(title))
        }
        
        if let artist = metadata["artist"] as? String {
            ret.append(MediaItemProperty.artist(artist))
        }
        
        if let album = metadata["album"] as? String {
            ret.append(MediaItemProperty.albumTitle(album))
        }
        
        if let duration = metadata["duration"] as? Double {
            ret.append(MediaItemProperty.duration(duration))
        }
        
        if let elapsedTime = metadata["elapsedTime"] as? Double {
            ret.append(NowPlayingInfoProperty.elapsedPlaybackTime(elapsedTime))
        }

        ret.forEach { (keyValue) in
            let key = try? keyValue.getKey()
            let value = try? keyValue.getValue()
            
            if (key != nil && value != nil) {
                try? player.nowPlayingInfoController.set(keyValue: keyValue)
            }
        }

        if let artworkURL = MediaURL(object: metadata["artwork"]) {
            currentImageTask = URLSession.shared.dataTask(with: artworkURL.value, completionHandler: { [weak player] (data, _, error) in
                if let data = data, let image = UIImage(data: data), error == nil {
                    let artwork = MPMediaItemArtwork(boundsSize: image.size, requestHandler: { (size) -> UIImage in
                        return image
                    })

                    let artworkKeyValue = MediaItemProperty.artwork(artwork)
                    let artworkKey = try? artworkKeyValue.getKey()
                    let artworkValue = try? artworkKeyValue.getValue()

                    if (artworkKeyValue != nil) {
                        player?.nowPlayingInfoController.set(keyValue: artworkKeyValue)
                    }
                }
            })
            
            currentImageTask?.resume()
        }
    }
}
