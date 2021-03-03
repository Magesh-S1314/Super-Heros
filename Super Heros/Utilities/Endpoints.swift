//
//  Endpoints.swift
//  Super Heros
//
//  Created by magesh on 03/03/21.
//

import Foundation


let internetString = "The Internet connection appears to be offline."
let unauthorized = "Unauthorized"

enum Endpoints: String {

    case baseUrl = "https://superheroapi.com/api/767331994181045/"
    
    func fullUrl(data: Any? = nil) -> String {
        var fullUrl = Endpoints.baseUrl.rawValue
        if let data = data{
            fullUrl += "\(data)"
        }
        return fullUrl
    }

}



