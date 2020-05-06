//
//  ContentView.swift
//  Converter
//
//  Created by Mac Van Anh on 5/5/20.
//  Copyright © 2020 Mac Van Anh. All rights reserved.
//


import SwiftUI

struct ContentView: View {
    @State private var number: String = ""
    @State private var sourceUnit: Int = 0
    
    var unitToMeasurement: [String: UnitLength] = [
        "Meters": .meters,
        "Kilometers": .kilometers,
        "Feet": .feet,
        "Yards": .yards,
        "Miles": .miles
    ]
    
    var units: [String] { Array(self.unitToMeasurement.keys) }

    var convertedValues: [(String, Double)] {
        let filterredUnits: [String] = self.units
            .enumerated()
            .filter { $0.offset != sourceUnit }
            .map { $0.element }

        let selectedUnit = self.units[self.sourceUnit]
        let sourceValue = Measurement(value: Double(self.number) ?? 0, unit: unitToMeasurement[selectedUnit]!)
        
        return filterredUnits.map {
            ($0, sourceValue.converted(to: unitToMeasurement[$0]!).value)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Please enter the number and select a unit")) {
                    TextField("Number", text: $number).keyboardType(.numberPad)
                    Picker("Source unit", selection: $sourceUnit) {
                        ForEach(0 ..< units.count) {
                            Text("\(self.units[$0])")
                        }
                    }
                }
                
                Section {
                    ForEach(0 ..< convertedValues.count) {
                        LineItem(unitAndValue: self.convertedValues[$0])
                    }
                }
            }
            .navigationBarTitle("Unit Converter", displayMode: .inline)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct LineItem: View {
    let unitAndValue: (String, Double)
    
    var body: some View {
        HStack {
            Text(unitAndValue.0)
            Spacer()
            Text("\(unitAndValue.1, specifier: "%.3f")").foregroundColor(.gray)
        }
    }
}
