//
//  ContentView.swift
//  Dex
//
//  Created by Juan Camilo Victoria Pacheco on 20/05/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
  @Environment(\.modelContext) private var modelContext
  
  @Query(sort: \Pokemon.id, animation: .default) private var pokedex: [Pokemon]
  
  @State private var searchText: String = ""
  @State private var filterByFavorites: Bool = false
  
  private let fetcher = FetchService()
  private var dynamicPredicate: Predicate<Pokemon> {
    #Predicate<Pokemon> { pokemon in
      if filterByFavorites && !searchText.isEmpty {
        pokemon.favorite && pokemon.name.localizedStandardContains(searchText)
      } else if !searchText.isEmpty {
        pokemon.name.localizedStandardContains(searchText)
      } else if filterByFavorites {
        pokemon.favorite
      } else {
        true
      }
    }
  }
  
  var body: some View {
    if pokedex.isEmpty {
      ContentUnavailableView {
        Label("No pokemon", image: .nopokemon)
      } description: {
        Text("There aren't any pokemon yet.\nFetch some pokemon to get started!")
      } actions: {
        Button("Fetch pokemon", systemImage: "antenna.radiowaves.left.and.right") {
          getPokemon(from: 1)
        }
        .buttonStyle(.borderedProminent)
        
      }
      
    } else {
      NavigationStack {
        List {
          Section {
            ForEach((try? pokedex.filter(dynamicPredicate)) ?? pokedex) { pokemon in
              NavigationLink(value: pokemon) {
                if pokemon.sprite == nil {
                  AsyncImage(url: pokemon.spriteURL) { image in
                    image
                      .resizable()
                      .scaledToFit()
                  } placeholder: {
                    ProgressView()
                  }
                  .frame(width: 100, height: 100)
                } else {
                  pokemon.spriteImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                }
                VStack(alignment: .leading) {
                  HStack {
                    Text(pokemon.name)
                      .fontWeight(.bold)
                    
                    if pokemon.favorite {
                      Image(systemName: "star.fill")
                        .foregroundStyle(Color.yellow)
                    }
                  }
                  HStack {
                    ForEach(pokemon.types, id: \.self) { type in
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
              .swipeActions(edge: .leading) {
                Button(pokemon.favorite ? "Remove from favorites" : "Add to favorites", systemImage: "star") {
                  pokemon.favorite.toggle()
                  do {
                    try modelContext.save()
                  } catch {
                    print(error)
                  }
                }
                .tint(pokemon.favorite ? .gray : .yellow)
              }
            }
          } footer: {
            if pokedex.count < 151 {
              ContentUnavailableView {
                Label("No pokemon", image: .nopokemon)
              } description: {
                Text("The fetch was interrupted!\nFetch the rest of the pokemon.")
              } actions: {
                Button("Fetch pokemon", systemImage: "antenna.radiowaves.left.and.right") {
                  getPokemon(from: pokedex.count + 1)
                }
                .buttonStyle(.borderedProminent)
              }
            }
          }
        }
        .navigationTitle("pokemon")
        .searchable(text: $searchText, prompt: "Find a Pokemon")
        .autocorrectionDisabled()
        .animation(.default, value: searchText)
        .navigationDestination(for: Pokemon.self) { pokemon in
          PokemonDetail(pokemon: pokemon)
        }
        .toolbar {
          ToolbarItem {
            Button {
              withAnimation {
                filterByFavorites.toggle()
              }
            } label: {
              Label(
                "Filter by favorites",
                systemImage: filterByFavorites ? "star.fill" : "star"
              )
            }
            .tint(Color.yellow)
          }
        }
      }
    }
  }
  
  private func getPokemon(from id: Int) {
    Task {
      for i in id..<152 {
        do {
          let fetchedPokemon = try await fetcher.fetchPokemon(i)
          modelContext.insert(fetchedPokemon)
        } catch {
          print(error)
        }
      }
      
      storeSprites()
    }
  }
  
  private func storeSprites() {
    Task {
      do {
        for pokemon in pokedex {
          pokemon.sprite = try await URLSession.shared.data(from: pokemon.spriteURL).0
          pokemon.shiny = try await URLSession.shared.data(from: pokemon.shinyURL).0
          
          try modelContext.save()
        }
      } catch {
        print("🛑 \(error)")
      }
    }
  }
}

#Preview {
  ContentView()
    .modelContainer(PersistenceController.preview)
}
