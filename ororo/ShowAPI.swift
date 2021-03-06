//
//  ShowsAPI.swift
//  ororo
//
//  Created by Andrey Tsarevskiy on 18/07/2017.
//  Copyright © 2017 Andrey Tsarevskiy. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class ShowAPI {
    
    static let showsURL = "https://ororo.tv/api/v2/shows"
    static let showURL = "\(showsURL)/"
    static let episodeURL = "https://ororo.tv/api/v2/episodes/"

    static func getAllShows(completionHandler: @escaping (_ result: Result<Any>, [Show]) -> Void) {
        
        Alamofire.request(showsURL, headers: OroroAPI.getHeader())
            .responseJSON { response in
                switch response.result {
                case .success:
                    if let data = response.data {
                        let showsJSON = JSON(data: data)["shows"]
                        let shows = showsJSON.arrayValue.map({ (json) -> Show in
                            let show = Show()
                            Parser.parseContent(json: json, content: show)
                            return show
                        })
                        completionHandler(response.result, shows)
                    }
                case .failure(let error):
                    completionHandler(response.result, [])
                    print(error)
                }
                
        }
    }
    
    static func getShow(id: Int, viewController: UIViewController, completionHandler: @escaping (ShowDetailed) -> Void) {
        
        Alamofire.request(showURL + String(id), headers: OroroAPI.getHeader())
            .responseJSON { response in
                switch response.result {
                case .success:
                    if let data = response.data {
                        let movieJSON = JSON(data: data)
                        completionHandler(Parser.parseShowDetailed(json: movieJSON))
                    }
                case .failure(let error):
                    print(error)
                    MessageHelper.connectionError(viewController: viewController)
                }
                
        }
    }
    
    static func getEpisodeDetailed(id: Int, viewController: UIViewController, completionHandler: @escaping (EpisodeDetailed) -> Void) {
        Alamofire.request(episodeURL + String(id), headers: OroroAPI.getHeader()).responseJSON { (response) in
            switch response.result {
                case .success:
                    if let data = response.data {
                        let episodeJson = JSON(data: data)
                        completionHandler(Parser.parseEpisodeDetailed(json: episodeJson))
                    }
                case .failure(let error):
                    print(error)
                    if let data = response.data,
                        let error = String(data: data, encoding: .utf8) {
                        print(error)
                        MessageHelper.connectionError(viewController: viewController, data: error)
                    } else {
                        MessageHelper.connectionError(viewController: viewController)
                    }
                
            }
        }
    }
    
}


