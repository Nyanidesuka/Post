//
//  Post.swift
//  Post
//
//  Created by Haley Jones on 5/13/19.
//  Copyright © 2019 DevMtnStudent. All rights reserved.
//

import Foundation
class Post: Codable{
    var text: String
    var timestamp: TimeInterval
    var username: String
    var queryTimestamp: TimeInterval{
        return self.timestamp * 0.00001
    }
    
    init(text: String, username: String, time: TimeInterval = Date().timeIntervalSince1970){
        self.text = text
        self.timestamp = time
        self.username = username
    }
}

extension Post: Equatable{
    static func == (lhs: Post, rhs: Post) -> Bool {
        return lhs.text == rhs.text &&
        lhs.timestamp == rhs.timestamp &&
        lhs.username == rhs.username
    }
}
