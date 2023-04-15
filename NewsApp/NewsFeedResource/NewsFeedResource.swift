//
//  NewsFeedResource.swift
//  NewsApp
//
//  Created by Ravi Dwivedi on 27/02/23.
//

import Foundation


struct NewsFeedResource{
    
    func getNewsFeed(query:String) async throws -> NewsFeedModels{
        guard let url = URL(string:APICollection.getUrlString(type: Collection.newsFeed, queryName: query)) else {
            fatalError("invalid URL types")
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "get"
        
        do{
            return try await HttpUtility.shared.performOperation(request: urlRequest, response: NewsFeedModels.self)
        }
        catch{
            throw error
        }
    }
}
