//
//  ContentView.swift
//  iExpense
//
//  Created by Mac Van Anh on 5/8/20.
//  Copyright © 2020 Mac Van Anh. All rights reserved.
//
import SwiftUI

struct ExpenseItem: Identifiable, Codable {
    let id = UUID()
    let name: String
    let type: String
    let amount: Int
}

class Expenses: ObservableObject {
    @Published var items: [ExpenseItem] {
        didSet {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(items) {
                UserDefaults.standard.set(encoded, forKey: "Items")
            }
        }
    }
    
    init() {
        if let items = UserDefaults.standard.data(forKey: "Items") {
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode([ExpenseItem].self, from: items) {
                self.items = decoded
                return
            }
        }
        
        self.items = []
    }
}

struct Coloring: ViewModifier {
    let color: Color
    
    func body(content: Content) -> some View {
        content.foregroundColor(color)
    }
}

extension View {
    func coloring(price: Int) -> some View {
        var color: Color = Color.white
        
        if price < Int.max {
            color = Color.red
        }
        
        if price < 100000 {
            color = Color.yellow
        }
        
        if price < 20000 {
            color = Color.green
        }
        
        return self.modifier(Coloring(color: color))
    }
}

struct ContentView: View {
    @ObservedObject var expenses = Expenses()
    @State private var showingAddExpense = false
    
    var totalSpent: Int {
        expenses.items.map { $0.amount }.reduce(0, +)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack() {
                    Text("Total Spent")
                    Spacer()
                    Text("-\(totalSpent)").font(.headline).foregroundColor(.red)
                }
                .padding()
                
                List {
                    ForEach(expenses.items) { item in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.name).font(.headline)
                                Text(item.type).font(.subheadline)
                            }
                            
                            Spacer()
                            
                            Text("-\(item.amount)")
                        }
                        .coloring(price: item.amount)
                    }
                    .onDelete(perform: removeItems)
                }
            }

            .navigationBarTitle("iExpense")
            .navigationBarItems(
                leading: EditButton(),
                trailing: Button(action: {
                    self.showingAddExpense = true
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "plus")
                        Text("Add")
                    }
                }
            )
            .sheet(isPresented: $showingAddExpense) {
                AddView(expenses: self.expenses)
            }
        }
    }
    
    func removeItems(at indexes: IndexSet) {
        self.expenses.items.remove(atOffsets: indexes)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
