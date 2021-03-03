//
//  SuperHeroModel.swift
//  Super Heros
//
//  Created by magesh on 03/03/21.
//


import Foundation


// MARK: - SuperHeroModel
struct SuperHeroSearchModel: Codable{
    let results: [SuperHeroModel]
}

// MARK: - SuperHeroModel
struct SuperHeroModel: Codable, Hashable, Identifiable {
    
    static func == (lhs: SuperHeroModel, rhs: SuperHeroModel) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name && lhs.powerstats == rhs.powerstats && lhs.biography == rhs.biography && lhs.appearance == rhs.appearance && lhs.image == rhs.image
    }
    
    let id: String
    let name: String
    let powerstats: Powerstats
    let biography: Biography
    let appearance: Appearance
    let image: HeroImage
}

// MARK: - Appearance
struct Appearance: Codable, Hashable {
    let gender, race: String
    let height, weight: [String]
    let eyeColor: String

    enum CodingKeys: String, CodingKey {
        case gender, race, height, weight
        case eyeColor = "eye-color"
    }
}

// MARK: - Biography
struct Biography: Codable, Hashable {
    let fullName, placeOfBirth, publisher, alignment: String

    enum CodingKeys: String, CodingKey {
        case fullName = "full-name"
        case placeOfBirth = "place-of-birth"
        case publisher, alignment
    }
}

// MARK: - Image
struct HeroImage: Codable, Hashable {
    let url: String
}

// MARK: - Powerstats
struct Powerstats: Codable, Hashable {
    let intelligence, strength, speed, power: String
}
