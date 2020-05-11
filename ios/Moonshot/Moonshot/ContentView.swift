//
//  ContentView.swift
//  Moonshot
//
//  Created by Mac Van Anh on 5/11/20.
//  Copyright © 2020 Mac Van Anh. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    let astronauts: [Astronaut] = Bundle.main.decode("astronauts.json")
    let missions: [Mission] = Bundle.main.decode("missions.json")
    
    @State private var toggledDate = true
    
    var body: some View {
        NavigationView {
            List(missions) { mission in
                NavigationLink(destination: MissionView(mission: mission, astronauts: self.astronauts)) {
                    Image(mission.image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 44, height: 44)
                    
                    VStack(alignment: .leading) {
                        Text(mission.displayedName).font(.headline)
                        if self.toggledDate {
                            Text(mission.formattedLaunchDate)
                        }
                    }
                }
            }
            .navigationBarItems(trailing: Button("Toggle Date") {
                self.toggledDate.toggle()
            })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
