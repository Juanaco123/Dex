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
  var speacialDefense: Int16
  var speed: Int16
  var sprite: URL
  var shiny: URL
  
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
    
    enum StatDictionaryKeys: CodingKey {
      case baseStat
    }
    
    enum SpriteDictionaryKeys: String, CodingKey {
      case sprite = "front_default"
      case shiny = "front_shiny"
    }
  }
  
  init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.id = try container.decode(Int16.self, forKey: .id)
    self.name = try container.decode(String.self, forKey: .name)
    self.types = try container.decode([String].self, forKey: .types)
    self.hp = try container.decode(Int16.self, forKey: .hp)
    self.attack = try container.decode(Int16.self, forKey: .attack)
    self.defense = try container.decode(Int16.self, forKey: .defense)
    self.specialAttack = try container.decode(Int16.self, forKey: .specialAttack)
    self.speacialDefense = try container.decode(Int16.self, forKey: .speacialDefense)
    self.speed = try container.decode(Int16.self, forKey: .speed)
    self.sprite = try container.decode(URL.self, forKey: .sprite)
    self.shiny = try container.decode(URL.self, forKey: .shiny)
  }
}
