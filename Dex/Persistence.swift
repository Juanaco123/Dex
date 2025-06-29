//
//  Persistence.swift
//  Dex
//
//  Created by Juan Camilo Victoria Pacheco on 20/05/25.
//

import SwiftData
import Foundation

@MainActor
struct PersistenceController {
  static var previewPokemon: Pokemon {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    
    let pokemonData: Data = try! Data(contentsOf: Bundle.main.url(forResource: "samplepokemon", withExtension: "json")!)
    let pokemon: Pokemon = try! decoder.decode(Pokemon.self, from: pokemonData)
    
    return pokemon
  }
  
  // Our sample preview database
  static let preview: ModelContainer = {
    let container: ModelContainer = try! ModelContainer(for: Pokemon.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    
    container.mainContext.insert(previewPokemon)
    
    return container
  }()
  
}
