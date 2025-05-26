//
//  ContentView.swift
//  Dex
//
//  Created by Juan Camilo Victoria Pacheco on 20/05/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
  @Environment(\.managedObjectContext) private var viewContext
  
  @FetchRequest<Pokemon>(
    sortDescriptors: [SortDescriptor(\.id)],
    animation: .default) private var pokedex
  @State private var searchText: String = ""
  @State private var filterByFavorites: Bool = false
  
  private let fetcher = FetchService()
  private var dynamicPredicate: NSPredicate {
    var predicates: [NSPredicate] = []
    
    // Search predicate
    if !searchText.isEmpty {
      predicates.append(NSPredicate(format: "name contains[c] %@", searchText))
    }
    // Filter by favorite predicate
    if filterByFavorites {
      predicates.append(NSPredicate(format: "favorite == %d", true))
    }
    // Combine predicates
    return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
  }
  
  var body: some View {
    NavigationStack {
      List {
        ForEach(pokedex) { pokemon in
          NavigationLink(value: pokemon) {
            AsyncImage(url: pokemon.sprite) { image in
              image
                .resizable()
                .scaledToFit()
            } placeholder: {
              ProgressView()
            }
            .frame(width: 100, height: 100)
            VStack(alignment: .leading) {
              HStack {
                Text(pokemon.name?.capitalized ?? "No name")
                  .fontWeight(.bold)
                
                if pokemon.favorite {
                  Image(systemName: "star.fill")
                    .foregroundStyle(Color.yellow)
                }
              }
              HStack {
                ForEach(pokemon.types ?? [], id: \.self) { type in
                  Text(type.capitalized)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.black)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color(type.capitalized))
                    .clipShape(.capsule)
                }
              }
            }
          }
        }
      }
      .navigationTitle("Pokedex")
      .searchable(text: $searchText, prompt: "Find a Pokemon")
      .autocorrectionDisabled()
      .onChange(of: searchText) {
        pokedex.nsPredicate = dynamicPredicate
      }
      .onChange(of: filterByFavorites) {
        pokedex.nsPredicate = dynamicPredicate
      }
      .navigationDestination(for: Pokemon.self) { pokemon in
        Text(pokemon.name ?? "No name")
      }
      .toolbar {
        ToolbarItem {
          Button {
            filterByFavorites.toggle()
          } label: {
            Label(
              "Filter by favorites",
              systemImage: filterByFavorites ? "star.fill" : "star"
            )
          }
          .tint(Color.yellow)
        }
        ToolbarItem {
          Button("add", systemImage: "plus") {
            getPokemon()
          }
        }
      }
    }
  }
  private func getPokemon() {
    Task {
      for id in 1..<152 {
        do {
          let fetchedPokemon = try await fetcher.fetchPokemon(id)
          let pokemon = Pokemon(context: viewContext)
          pokemon.id = fetchedPokemon.id
          pokemon.name = fetchedPokemon.name
          pokemon.types = fetchedPokemon.types
          pokemon.hp = fetchedPokemon.hp
          pokemon.attack = fetchedPokemon.attack
          pokemon.defense = fetchedPokemon.defense
          pokemon.specialAttack = fetchedPokemon.specialAttack
          pokemon.specialDefense = fetchedPokemon.specialDefense
          pokemon.speed = fetchedPokemon.speed
          pokemon.sprite = fetchedPokemon.sprite
          pokemon.shiny = fetchedPokemon.shiny
          
          try viewContext.save()
        } catch {
          print(error)
        }
      }
    }
  }
}

#Preview {
  ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
