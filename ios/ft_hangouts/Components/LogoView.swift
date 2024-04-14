//
//  LogoView.swift
//  ft_hangouts
//
//  Created by topknell on 4/12/24.
//

import SwiftUI

struct LogoView: View {
    var body : some View {
        ZStack(content: {
            Color(.lightDark)
                .ignoresSafeArea()
            VStack(alignment: .leading, spacing: 10){
                Image("42_Logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.all)
                    .background(.white)
                    .border(.reLightBlue, width: 2)
                    .cornerRadius(30)
                HStack {
                    
                    Text("42 Logo")
                        .font(.largeTitle)
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        .foregroundColor(.reLightBlue)
                    
                    Spacer()
                    VStack{
                        HStack{
                            Image(systemName: "star.fill")
                            Image(systemName: "star.fill")
                            Image(systemName: "star.fill")
                            Image(systemName: "star.leadinghalf.filled")
                            Image(systemName: "star")
                        }
                        .foregroundColor(.star)
                        .font(.caption)
                        Text("PreViews 42")
                            .foregroundColor(.star)
                        
                    }
                }
                Text("This is for 42 students")
                    .foregroundColor(.reLightBlue)
                
                HStack{
                    Spacer()
                    Image(systemName: "fork.knife")
                    Image(systemName: "binoculars.fill")
                }
                .foregroundColor(.gray)
            }
            .padding()
            .background(Rectangle()
                .cornerRadius(15)
                .foregroundColor(.lightDark)
                .shadow(color: .reLightBlue, radius: 20))
            .padding()
        })
    }
}

#Preview {
    LogoView()
}
