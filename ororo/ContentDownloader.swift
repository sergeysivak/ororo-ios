//
//  ContentDownloader.swift
//  ororo
//
//  Created by Andrey Tsarevskiy on 11/07/2017.
//  Copyright © 2017 Andrey Tsarevskiy. All rights reserved.
//

import Foundation

class ContentDownloader {
    static func load(url: URL, movie: Movie) {
//        let sessionConfig = URLSessionConfiguration.default
//        let session = URLSession(configuration: sessionConfig)
//        let request = try! URLRequest(url: url, method: .get)
//        
//        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!as NSURL
//        let toUrl = documentsUrl.appendingPathComponent("movie_\(movie.id)")!
//        
        let dMovie = DownloadedMovie()
        dMovie.name = movie.name
        dMovie.id = movie.id
//        dMovie.downloadUrl = toUrl.absoluteString
//        DispatchQueue.main.async() { () -> Void in
            DbHelper.storeMovie(movie: dMovie)
//        }
        
//        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
//            if let tempLocalUrl = tempLocalUrl, error == nil {
//                // Success
//                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
//                    print("Success: \(statusCode)")
//                }
//                do {
//                    try FileManager.default.copyItem(at: tempLocalUrl, to: toUrl)
////                    let dMovie = DownloadedMovie()
////                    dMovie.name = movie.name
////                    dMovie.id = movie.id
////                    dMovie.downloadUrl = toUrl.absoluteString
////                    DispatchQueue.main.async() { () -> Void in
////                         DbHelper.storeMovie(movie: dMovie)
////                    }
//                } catch (let writeError) {
//                    print("error writing file \(toUrl) : \(writeError)")
//                }
//                
//            } else {
//                print("Failure: %@", error?.localizedDescription ?? "unknown");
//            }
//        }
//        task.resume()
    }
}