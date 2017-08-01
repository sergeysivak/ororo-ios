//
//  ContentDownloader.swift
//  ororo
//
//  Created by Andrey Tsarevskiy on 11/07/2017.
//  Copyright © 2017 Andrey Tsarevskiy. All rights reserved.
//

import Foundation
import Alamofire

protocol ContentDownloadListenerProtocol {
    func updateProgress(percent: Int64)
    func finished()
}

class ContentDownloader {
    
    static let EPISODE_PREFIX = "episode"
    static let MOVIE_PREFIX = "movie"
    static let SHOW_PREFIX = "show"
    
    static var jobsQueue: DispatchQueue? = nil
    static var downloads: [String:DownloadJob] = [:]
    
    class DownloadJob {
        var progress: Progress? = nil
        let onFinish: () -> Void
        
        init(onFinish: @escaping () -> Void) {
            self.onFinish = onFinish
        }
    }
    
    static func cleanDownloads() {
        downloads = [:]
    }
    
    static func load(movie: MovieDetailed) {
        
        let dMovie = DownloadedMovie()
        movie.copyFieldsTo(content: dMovie)
        dMovie.isDownloadFinished = false
        
        let contentDir = getDocumentDir().appendingPathComponent("ororo/\(MOVIE_PREFIX)_\(movie.id)/")
        
        let movieId = movie.id
        let downloadJob = DownloadJob {
            DbHelper.update(updateBlock: { () in
                let dMovie = MovieDAO.getDownloadedMovie(movieId)
                dMovie?.isDownloadFinished = true
            })
        }
        
        load(downloadFrom: movie,
             downloadTo: dMovie,
             contentDir: contentDir,
             downloadJob: downloadJob)
        
        addDownload(id: MOVIE_PREFIX + String(movie.id), downloadJob: downloadJob)
        
        DbHelper.storeMovie(movie: dMovie)
    }
    
    static func load(show: Show, episode: EpisodeDetailed) {
        var dShow = ShowDAO.getDownloadedShow(id: show.id)
        
        if (dShow == nil) {
            dShow = DownloadedShow()
            show.copyFieldsTo(content: dShow!)
            ShowDAO.saveShow(show: dShow!)
        }
        
        ShowDAO.updateShow {
            dShow?.isDownloadFinished = false
        }
        
        let dEpisode = DownloadedEpisode()
        episode.copyFieldsTo(content: dEpisode)
        
        let showId = show.id
        let episodeId = episode.id
        
        let downloadJob = DownloadJob {
            DbHelper.update(updateBlock: { () in
                let refreshedShow = ShowDAO.getDownloadedShow(id: showId)
                let refreshedEpisode = ShowDAO.getDownloadedEpisode(episodeId)
                
                refreshedEpisode?.isDownloadFinished = true
                refreshedShow?.isDownloadFinished = true
            })
        }
        
        let contentDir = getDocumentDir().appendingPathComponent("ororo/\(EPISODE_PREFIX)_\(episode.id)/")
        
        load(downloadFrom: episode,
             downloadTo: dEpisode,
             contentDir: contentDir,
             downloadJob: downloadJob)
        
        addDownload(id: EPISODE_PREFIX + String(episode.id), downloadJob: downloadJob)
        addDownload(id: SHOW_PREFIX + String(show.id), downloadJob: downloadJob)
        
        ShowDAO.saveEpisode(episode: dEpisode)
    }
    
    static internal func getDocumentDir() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as URL
    }
    
    static internal func load(downloadFrom: DetailedContent, downloadTo: DetailedContent, contentDir: URL, downloadJob: DownloadJob) {
        
        let request = try! URLRequest(url: downloadFrom.getPreparedDownloadUrl(), method: .get)
        
        let contentUrl = contentDir.appendingPathComponent("content.mp4")
        
        downloadTo.setDownloadUrl(url: contentUrl.path)
        
        downloadJob.progress = Alamofire.download(request) { (temporaryURL: URL, response: HTTPURLResponse) in
            (contentUrl, [.removePreviousFile, .createIntermediateDirectories])
            }.progress
        
        loadSubtitles(downloadFrom: downloadFrom,
                      downloadTo: downloadTo,
                      contentDir: contentDir,
                      downloadJob: downloadJob)
    }
    
    static internal func addDownload(id: String, downloadJob: DownloadJob) {
        if let progress = downloads[id]?.progress {
            progress.addChild(downloadJob.progress!, withPendingUnitCount: 0)
        } else {
            downloads[id] = downloadJob
        }
    }
    
    static internal func loadSubtitles(downloadFrom: DetailedContent, downloadTo: DetailedContent, contentDir: URL, downloadJob: DownloadJob) {
        var count: Int64 = 1
        let subtitles = downloadFrom.subtitles.map { (subtile) -> Subtitle in
            let lang = subtile.lang
            let subtitleUrl = contentDir.appendingPathComponent("subtitle_\(lang).srt")
            
            let request = try! URLRequest(url: downloadFrom.getPreparedSubtitlesDownloadUrl(lang: lang), method: .get)
            let progress = Alamofire.download(request) { (temporaryURL: URL, response: HTTPURLResponse) in
                (subtitleUrl, [.removePreviousFile, .createIntermediateDirectories])
            }.progress
            
            downloadJob.progress?.addChild(progress, withPendingUnitCount: count)
            let result = Subtitle()
            result.lang = lang
            result.url = subtitleUrl.path
            count += 1
            return result
        }
        subtitles.forEach { (subtitle) in
            downloadTo.subtitles.append(subtitle)
        }
    }
    
    static func subscribeToDownloadProgress(id: Int, requester: SimpleContent, listener : ContentDownloadListenerProtocol) {
        startAsyncIfNotStarted()
        let identifier = getPrefix(requester: requester) + String(id)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "downloadProgress" + identifier), object: nil, queue: nil, using: { (notify) in
                if let progress = notify.userInfo?["progress"] as? Int64 {
                    listener.updateProgress(percent: progress)
                }
                                                
            });
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "downloadFinished" + identifier), object: nil, queue: nil, using: { _ in listener.finished() });
        

        if let download = downloads[identifier] {
            notifyListener(identifier: identifier, downloadJob: download)
        }
    }
    
    static internal func getPrefix(requester: SimpleContent) -> String {
        switch requester {
        case is Show:
            return SHOW_PREFIX
        case is Movie:
            return MOVIE_PREFIX
        case is Episode:
            return EPISODE_PREFIX
        default:
            return "unknown"
        }
    }
    
    static internal func startAsyncIfNotStarted() {
        if (jobsQueue == nil) {
            jobsQueue = DispatchQueue(label: "Content Downloader Jobs Queue")
            jobsQueue?.async {
                while(true) {
                    sleep(3)
                    downloads.forEach({ (download) in
                        notifyListener(identifier: download.0, downloadJob: download.1)
                    })
                }
            }
        }
    }
    
    static internal func notifyListener(identifier: String, downloadJob: DownloadJob) {
        if let progress = downloadJob.progress {
         
            let fractionCompleted = progress.fractionCompleted
            let totalUnitCount = progress.totalUnitCount
            let completedUnitCount = progress.completedUnitCount
            
            let isCancled = progress.isCancelled
            print(isCancled)
        
            if completedUnitCount >= totalUnitCount {
                downloadJob.onFinish()
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "downloadFinished" + identifier), object: nil)
                }

                self.downloads.removeValue(forKey: identifier)
            } else {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "downloadProgress" + identifier), object: nil, userInfo: ["progress" : Int64(fractionCompleted * 100)])
                }
            }
        }
    }
    
}
