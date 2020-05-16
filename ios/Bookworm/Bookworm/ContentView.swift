//
//  ContentView.swift
//  Bookworm
//
//  Created by Mac Van Anh on 5/14/20.
//  Copyright © 2020 Mac Van Anh. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Book.entity(), sortDescriptors: [
        NSSortDescriptor(keyPath: \Book.title, ascending: true),
        NSSortDescriptor(keyPath: \Book.author, ascending: true)
    ]) var books: FetchedResults<Book>
    
    @State private var showingAddScreen = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(books, id: \.self) { book in
                    NavigationLink(destination: DetailView(book: book)) {
                        EmojiRatingView(rating: book.rating).font(.largeTitle)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text(book.title ?? "Unknown Title").font(.headline).foregroundColor(book.rating == 1 ? .red : .black)
                                Text(book.author ?? "Unknown Author").foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Text(Self.formattedFinishedDate(on: book.date))
                        }
                    }
                }
                .onDelete(perform: deleteBooks)
            }

            .navigationBarTitle("Bookworm")
            .navigationBarItems(leading: EditButton(), trailing: Button(action: {
                self.showingAddScreen.toggle()
            }) {
                Image(systemName: "plus")
            })
            .sheet(isPresented: $showingAddScreen) {
                AddBookView().environment(\.managedObjectContext, self.moc)
            }
        }
    }
    
    static func formattedFinishedDate(on date: Date?) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date ?? Date())
    }
    
    func deleteBooks(at offsets: IndexSet) {
        for offset in offsets {
            let book = books[offset]
            
            moc.delete(book)
        }
        
        try? moc.save()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
