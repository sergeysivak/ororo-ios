//
//  Show.swift
//  ororo
//
//  Created by Andrey Tsarevskiy on 23/07/2017.
//  Copyright © 2017 Andrey Tsarevskiy. All rights reserved.
//

import Foundation
import RealmSwift

class Episode: Object {
    dynamic var id = -1
    dynamic var name = ""
    dynamic var plot = ""
    dynamic var season = 1
    dynamic var number = 1
    dynamic var airdate = ""
}

class Show: Content {
    
}

class ShowDetailed: Show {
    var episodes = List<Episode>()
}

class EpisodeDetailed: Episode {
    dynamic var downloadUrl = ""
    var subtitles = List<Subtitle>()
    
    internal func getPreparedDownloadUrl() -> URL {
        return URL(string: downloadUrl)!
    }
    
    internal func getPreparedSubtitlesDownloadUrl(lang: String) -> URL {
        let subtitle = subtitles.filter {$0.lang == lang}.first
        return URL(string: subtitle!.url)!
    }
}