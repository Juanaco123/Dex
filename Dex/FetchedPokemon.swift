//
//  FetchedPokemon.swift
//  Dex
//
//  Created by Juan Camilo Victoria Pacheco on 26/05/25.
//

import Foundation

struct FetchedPokemon: Decodable {
  var id: Int16
  var name: String
  let types: [String]
  var hp: Int16
  var attack: Int16
  var defense: Int16
  var specialAttack: Int16
  var specialDefense: Int16
  var speed: Int16
  var spriteURL: URL
  var shinyURL: URL
  
  enum CodingKeys: CodingKey {
    case id
    case name
    case types
    case stats
    case sprites
    
    enum TypeDictionaryKeys: CodingKey {
      case type
      
      enum TypeKeys: CodingKey {
        case name
      }
    }
    
    enum StatDictionaryKeys: String, CodingKey {
      case baseStat = "base_stat"
    }
    
    enum SpriteDictionaryKeys: String, CodingKey {
      case spriteURL = "front_default"
      case shinyURL = "front_shiny"
    }
  }
  
  init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    id = try container.decode(Int16.self, forKey: .id)
    name = try container.decode(String.self, forKey: .name)
    var decodedTypes: [String] = []
    var typesContainer = try container.nestedUnkeyedContainer(forKey: .types)
    while !typesContainer.isAtEnd {
      // Decode types
      let typesDictionaryContainer = try typesContainer.nestedContainer(keyedBy: CodingKeys.TypeDictionaryKeys.self)
      let typeContainer = try typesDictionaryContainer.nestedContainer(keyedBy: CodingKeys.TypeDictionaryKeys.TypeKeys.self, forKey: .type)
      
      let type = try typeContainer.decode(String.self, forKey: .name)
      decodedTypes.append(type)
    }
    
    if decodedTypes.count == 2 && decodedTypes[0] == "normal" {
      decodedTypes.swapAt(0, 1)
    }
    
    types = decodedTypes
    
    var decodedStats: [Int16] = []
    var statsContainer = try container.nestedUnkeyedContainer(forKey: .stats)
    while !statsContainer.isAtEnd {
      // Decode types
      let statsDictionaryContainer = try statsContainer.nestedContainer(keyedBy: CodingKeys.StatDictionaryKeys.self)
      
      let stat = try statsDictionaryContainer.decode(Int16.self, forKey: .baseStat)
      decodedStats.append(stat)
    }
    hp = decodedStats[0]
    attack = decodedStats[1]
    defense = decodedStats[2]
    specialAttack = decodedStats[3]
    specialDefense = decodedStats[4]
    speed = decodedStats[5]
    
    let spritesContainer = try container.nestedContainer(keyedBy: CodingKeys.SpriteDictionaryKeys.self, forKey: .sprites)
    spriteURL = try spritesContainer.decode(URL.self, forKey: .spriteURL)
    shinyURL = try spritesContainer.decode(URL.self, forKey: .shinyURL)
  }
}
