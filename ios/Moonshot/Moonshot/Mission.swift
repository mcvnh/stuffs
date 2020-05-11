//
//  Mission.swift
//  Moonshot
//
//  Created by Mac Van Anh on 5/11/20.
//  Copyright © 2020 Mac Van Anh. All rights reserved.
//

import Foundation

struct Mission: Codable, Identifiable {
    struct CrewRole: Codable {
        let name: String
        let role: String
    }

    let id: Int
    let launchDate: String?
    let crew: [CrewRole]
    let description: String
    
    var displayedName: String {
        "Apollo \(id)"
    }
    
    var image: String {
        "apollo\(id)"
    }
    
    var formattedLaunchDate: String {
        if let launchDate = launchDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            
            if let dateString = formatter.date(from: launchDate) {
                formatter.dateStyle = .long
                return formatter.string(from: dateString)
            }
        }
        
        return "N/A"
    }
    
}
