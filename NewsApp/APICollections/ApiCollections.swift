//
//  ApiCollections.swift
//  NewsApp
//
//  Created by Ravi Dwivedi on 27/02/23.
//

import Foundation


struct ApiKeys{
    static let key = "d209d9c86a4741e8950181b589ce3b08"
}

//MARK:- API CollectionTypes
enum Collection{
    case newsFeed
}

struct APICollection{
    
    public static func getUrlString(type:Collection,queryName:String) -> String{
        switch type {
        case .newsFeed:
            let newsFeed = "https://newsapi.org/v2/everything?q=\(queryName)&from=\(DateConverter.dateString())&sortBy=publishedAt&apiKey=\(ApiKeys.key)"
            return newsFeed
        }
    }
}


//MARK:- Date to String Conversions
struct DateConverter{
    static func dateString() -> String{
        //let dateFormatter = DateFormatter()
       // dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = "27-01-2023"
        //let date = dateFormatter.date(from: dateString)
        //dateFormatter.dateFormat = "yyyy-MM-dd"
        //let dateStr = dateFormatter.string(from: date!)
        return dateString
    }
}
