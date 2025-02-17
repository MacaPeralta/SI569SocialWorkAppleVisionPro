//
//  ContentView.swift
//  Apple_Workshop
//
//  Created by Macarena Peralta on 1/30/25.
//

import SwiftUI

struct ContentView: View {
    @State private var turnedOn = false
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, UM!")
            Text("I am Maca")
                .font(.system(size:48))
            Button("THIS IS THE TITLE"){
                print("button tapped")
            }
            if turnedOn{
                Text("Neat!")
            }
            Toggle("Show it", isOn: $turnedOn)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
