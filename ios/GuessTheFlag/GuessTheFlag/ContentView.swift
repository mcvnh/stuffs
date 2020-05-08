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
    @State private var correctAnswer : Int = Int.random(in: 0...2)
    
    @State private var gameover : Bool = false

    @State private var score = 0
    
    // animation section
    @State private var shouldAnimatingItemIndex : Int = -1
    
    
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
                        withAnimation {
                            self.shouldAnimatingItemIndex = number
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            self.shouldAnimatingItemIndex = -1
                            self.flagTapped(number)
                        }
                    }) {
                        FlagImage(name: self.countries[number])
                    }
                    .rotation3DEffect(.degrees(self.selectCorrected(number) ? 360 : 0), axis: (x: 0, y: 1, z: 0))
                    .scaleEffect(self.selectIncorrected(number) ? 1.2 : 1)
                    .animation(.default)
                    .opacity(self.notSelected(number) ? 0.25 : 1.0)
                    .animation(.easeIn)
                }
            }
            
            if gameover {
                Color.black.opacity(0.7)
                    .edgesIgnoringSafeArea(.all)
                    .animation(nil)
                    .transition(.asymmetric(insertion: .scale, removal: .opacity))
                    .animation(.default)
                
                Text("Gameover!")
                    .font(.largeTitle)
                    .frame(maxWidth: .infinity)
                    .frame(height: 100)
                    .background(Color.red).foregroundColor(.white)
                    .transition(.asymmetric(insertion: .slide, removal: .slide))
                    .animation(.default)
            }
        }
    }

    func selectCorrected(_ number: Int) -> Bool {
        return self.shouldAnimatingItemIndex == number && number == self.correctAnswer
    }

    func selectIncorrected(_ number: Int) -> Bool {
        return self.shouldAnimatingItemIndex == number && number != self.correctAnswer
    }

    func notSelected(_ number: Int) -> Bool {
        return self.shouldAnimatingItemIndex != number && self.shouldAnimatingItemIndex != -1
    }

    func flagTapped(_ number: Int) {
        if number == correctAnswer {
            score += 1
            self.askQuestion();
        } else {
            score = 0
            gameover = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation(.spring()) {
                    self.gameover = false
                }
            }
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
