//
//  ContentView.swift
//  GuessTheFlag
//
//  Created by Mac Van Anh on 5/5/20.
//  Copyright © 2020 Mac Van Anh. All rights reserved.
//

import SwiftUI

struct FlagImage: View {
    let name: String
    
    var body: some View {
        Image(name)
            .renderingMode(.original)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.black, lineWidth: 1))
            .shadow(color: .black, radius: 2)
    }
}

struct WhiteText: ViewModifier {
    func body(content: Content) -> some View {
        content.foregroundColor(.white)
    }
}

struct WhiteBoldText: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(.white)
            .font(Font.body.weight(.heavy))
    }
}

extension Text {
    func whiteText() -> some View {
        self.modifier(WhiteText())
    }
    
    func whiteBoldText() -> some View {
        self.modifier(WhiteBoldText())
    }
}

struct ContentView: View {
    @State private var countries = ["Estonia", "France", "Germany", "Ireland", "Italy", "Nigeria", "Poland", "Russia", "Spain", "UK", "US"].shuffled()
    @State private var correctAnswer = Int.random(in: 0...2)
    
    @State private var showingScore = false
    @State private var wrongMessage = ""

    @State private var score = 0
    
    var body: some View {
        ZStack {
            // Color.blue.edgesIgnoringSafeArea(.all)
            LinearGradient(gradient: Gradient(colors: [.blue, .black]), startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                HStack {
                    Text("Tap the flag of").whiteText()
                    Text(countries[correctAnswer]).whiteBoldText()
                }
                
                HStack {
                    Text("Your score ").whiteText()
                    Text("\(score)").whiteBoldText()
                }

                ForEach(0 ..< 3) { number in
                    Button(action: {
                        self.flagTapped(number)
                    }) {
                        FlagImage(name: self.countries[number])
                    }
                }
            }
        }
        .alert(isPresented: $showingScore) {
            Alert(title: Text("Gameover!"), message: Text(wrongMessage), dismissButton: .default(Text("Again")) {
                self.askQuestion();
                self.score = 0
            })
        }
    }
    
    func flagTapped(_ number: Int) {
        if number == correctAnswer {
            score += 1
            self.askQuestion();
        } else {
            wrongMessage = "Wrong! That's the flag of \(countries[number])"
            showingScore = true
        }
    }
    
    func askQuestion() {
        countries = countries.shuffled()
        correctAnswer = Int.random(in: 0...2)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
