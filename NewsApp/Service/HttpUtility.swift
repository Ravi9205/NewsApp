//
//  HttpUtility.swift
//  NewsApp
//
//  Created by Ravi Dwivedi on 27/02/23.
//

import Foundation

enum httpError : Error {
    case jsonDecoding
    case noData
    case nonSuccessStatusCode
    case serverError
    case emptyCollection
    case emptyObject
}



final class HttpUtility{
    
    static let shared = HttpUtility()
    private init(){}
    
    // Using Traditional approach  of network call using escaping closures
    func performOperation<T:Decodable>(request: URLRequest, response: T.Type,
                                       completionHandler:
                                       @escaping(T?, Error?)->Void) {

        URLSession.shared.dataTask(with: request) { serverData, serverResponse, serverError in

            // check for error
            guard serverError == nil else { return completionHandler(nil,httpError.serverError) }

            // check for success staus code
            guard let httpStausCode = (serverResponse as? HTTPURLResponse)?.statusCode,
                  (200...299).contains(httpStausCode) else {
                      return completionHandler(nil, httpError.nonSuccessStatusCode)
                  }

            // check if serverData is not empty
            guard serverData?.isEmpty == false else {
                return completionHandler(nil,httpError.noData)

            }

            // decode the result
            do {
                let result = try JSONDecoder().decode(response.self, from: serverData!)
                completionHandler(result,nil) // return success
            }catch {
                // return decode error
                completionHandler(nil,error)
            }
        }.resume()
    }
    

    // Using aysnc Await
    func performOperation<T:Decodable>(request: URLRequest, response: T.Type) async throws -> T{

        do {
            let (serverData, serverUrlResponse) = try await URLSession.shared.data(for:request)

            guard let httpStausCode = (serverUrlResponse as? HTTPURLResponse)?.statusCode,
                  (200...299).contains(httpStausCode) else {
                      throw httpError.nonSuccessStatusCode
                  }

            return try JSONDecoder().decode(response.self, from: serverData)

        } catch  {
            throw error
        }
    }
    
}
