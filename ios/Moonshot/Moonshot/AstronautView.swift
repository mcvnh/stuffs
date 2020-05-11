//
//  AstronautView.swift
//  Moonshot
//
//  Created by Mac Van Anh on 5/11/20.
//  Copyright © 2020 Mac Van Anh. All rights reserved.
//

import SwiftUI

struct AstronautView: View {
    static let allMissions: [Mission] = Bundle.main.decode("missions.json")
    static let allAstronauts: [Astronaut] = Bundle.main.decode("astronauts.json")
    
    let astronaut: Astronaut
    
    var missions: [Mission] {
        Self.allMissions.filter { mission in
            mission.crew.contains(where: { $0.name == self.astronaut.id })
        }
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical) {
                VStack {
                    Image(self.astronaut.id)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width)
                    
                    Text(self.astronaut.description).padding().layoutPriority(1)
                    
                    Text("Missions").font(.headline)
                    
                    if self.missions.count > 0 {
                        VStack(alignment: .leading) {
                            ForEach(self.missions, id: \.id) { mission in
                                NavigationLink(destination: MissionView(mission: mission, astronauts: Self.allAstronauts)) {
                                    HStack {
                                        Image(mission.image)
                                            .resizable()
                                            .frame(width: 40, height: 40)
                                            .clipShape(Circle())
                                            .overlay(Capsule().stroke(Color.primary, lineWidth: 1))
                                        
                                        Text(mission.displayedName)
                                        
                                        Spacer()
                                    }
                                    .padding(.horizontal)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.bottom)
                    }
                }
            }
        }
        .navigationBarTitle(Text(astronaut.name), displayMode: .inline)
    }
}

struct AstronautView_Previews: PreviewProvider {
    static let astronauts: [Astronaut] = Bundle.main.decode("astronauts.json")

    static var previews: some View {
        AstronautView(astronaut: astronauts[0])
    }
}
