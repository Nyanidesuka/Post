//
//  PostController.swift
//  Post
//
//  Created by Haley Jones on 5/13/19.
//  Copyright © 2019 DevMtnStudent. All rights reserved.
//

import Foundation
class PostController{
    let baseURL = URL(string: "http://devmtn-posts.firebaseio.com/posts")
    var posts: [Post] = []
    
    
    func fetchPosts(reset: Bool = true, completion: @escaping () -> Void){
        let queryEndInterval = reset ? Date().timeIntervalSince1970 : posts.last?.queryTimestamp ?? Date().timeIntervalSince1970
        guard let unwrappedURL = baseURL else {return}
        let urlParameters = [
            "orderBy": "\"timestamp\"",
            "endAt": "\(queryEndInterval)",
            "limitToLast": "15",
        ]
        let queryItems = urlParameters.compactMap( { URLQueryItem(name: $0.key, value: $0.value) } )
        var urlComponents = URLComponents(url: unwrappedURL, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = queryItems
        guard let newURL = urlComponents?.url else {completion(); return}
        let getterEndpoint = newURL.appendingPathExtension("json")
        var request = URLRequest(url: getterEndpoint)
        request.httpBody = nil
        request.httpMethod = "GET"
        var dataTask = URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let anError = error{
                print(anError.localizedDescription)
                completion()
                return
            }
            guard let unwrappedData = data else {completion(); return}
            let decoder = JSONDecoder()
            do{
                let postsDictionary = try decoder.decode([String:Post].self, from: unwrappedData)
                var posts = postsDictionary.compactMap({$0.value})
                posts.sort(by: {$0.timestamp > $1.timestamp})
                if reset == true{
                    self.posts = posts
                } else {
                    //black💎 prevent duplicate posts from loading when we hit the bottom?
                    for post in posts where !self.posts.contains(post){
                        self.posts.append(contentsOf: posts)
                    }
                }
                completion()
            } catch {
                print (error.localizedDescription)
                completion()
                return
            }
        }
        dataTask.resume()
    }
    
    func addPostWith(username: String, text: String, completion: @escaping () -> Void){
        var newPost = Post(text: text, username: username)
        var postData = Data()
        let encoder = JSONEncoder()
        do{
            postData = try encoder.encode(newPost)
        } catch {
            print(error.localizedDescription)
        }
        guard let baseURL = baseURL else {completion(); return}
        let postEndpoint = baseURL.appendingPathExtension("json")
        var request = URLRequest(url: postEndpoint)
        request.httpMethod = "POST"
        request.httpBody = postData
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let anError = error{
                print(anError.localizedDescription)
                completion()
                return
            }
            print(response)
            guard let data = data else {completion(); return}
            let dataString = String(data: data, encoding: .utf8)
            self.fetchPosts {
                completion()
            }
        }.resume()
    }
}
