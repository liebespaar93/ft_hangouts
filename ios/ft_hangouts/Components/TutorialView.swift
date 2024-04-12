//
//  Tutorial.swift
//  ft_hangouts
//
//  Created by topknell on 4/12/24.
//

import SwiftUI

struct TutorialView : View {
    
    @State var playerCard = "card7"
    @State var cpuCard = "card4"
    
    @State var platerScore = 0
    @State var cpuScore = 0
    func deal() {
        var random = [Int.random(in:2...14), Int.random(in:2...14)]
        playerCard = "card" + random[0]
            .codingKey.stringValue
        cpuCard = "card" + random[1]
            .codingKey.stringValue
        
        if (random[0] > random[1]){
            platerScore += 1
            print("playerCard win")
        } else if (random[0] < random[1]){
            cpuScore += 1
            print("CPU wind")
        } else{
            print("draw")
        }
    }
    
    var body : some View {
        ZStack{
            Image("background-wood-cartoon")
                .resizable()
                .ignoresSafeArea()
            VStack{
                Spacer()
                Image("logo")
                Spacer()
                HStack {
                    Spacer()
                    Image(playerCard)
                    Spacer()
                    Image(cpuCard)
                    Spacer()
                }
                Spacer()
                
                Button(action: {deal()}, label: {
                    Image("button")
                })
                
                Spacer()
                
                HStack {
                    Spacer()
                    VStack{
                        Text("Player")
                            .font(.headline)
                            .padding(.bottom, 10)
                        Text(platerScore.codingKey.stringValue)
                            .font(.largeTitle)
                    }
                    Spacer()
                    VStack{
                        Text("CPU")
                            .font(.headline)
                            .padding(.bottom, 10)
                        Text(cpuScore.codingKey.stringValue)
                            .font(.largeTitle)
                    }
                    Spacer()
                }.foregroundColor(.white)
                Spacer()
            }
        }
    }
    
}

#Preview {
    TutorialView()
}
