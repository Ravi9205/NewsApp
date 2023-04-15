//
//  NewsFeedViewModel.swift
//  NewsApp
//
//  Created by Ravi Dwivedi on 27/02/23.
//

import Foundation


struct NewsFeedViewModel{
    
    private let newsFeedResource = NewsFeedResource()
    
    func callNewsFeedApi(query:String) async throws -> NewsFeedModels{
        do{
            return  try await newsFeedResource.getNewsFeed(query: query)
        }
        catch let serviceError{
            throw serviceError
        }
    }
}
