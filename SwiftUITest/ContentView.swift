//
//  ContentView.swift
//  SwiftUITest
//
//  Created by gavinxqguo on 2020/11/11.
//  Copyright © 2020 郭晓倩. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                HeaderView()
                Text("World!").font(.title)
                List(0..<100) { item in
                    Text("World!").font(.title)
                }
            }.navigationBarTitle(Text("sssss"))
        }
    }
}

struct HeaderView : UIViewRepresentable {
    func makeUIView(context: UIViewRepresentableContext<HeaderView>) -> UIView {
        UIView(frame: CGRect(x:0,y: 0,width: 100,height: 100))
    }
        
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<HeaderView>) {
        uiView.backgroundColor = UIColor.red
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
