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
  
  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Pokemon.id, ascending: true)],
    animation: .default)
  private var pokedex: FetchedResults<Pokemon>
  
  var body: some View {
    NavigationView {
      List {
        ForEach(pokedex) { pokemon in
          NavigationLink {
            Text(pokemon.name ?? "No name")
          } label: {
            Text(pokemon.name ?? "No name")
          }
        }
      }
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          EditButton()
        }
        ToolbarItem {
          Button("Add Item", systemImage: "plus") {}
        }
      }
    }
  }
}

#Preview {
  ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
