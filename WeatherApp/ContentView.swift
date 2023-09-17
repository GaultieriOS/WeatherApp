//
//  ContentView.swift
//  WeatherApp
//
//  Created by Gaultier Moraillon on 15/09/2023.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State private var progressValue: Double = 0.0
       let totalTime: Double = 60.0 // One minute in seconds
       let timerInterval: Double = 1.0 // Update the progress every 1 second
       var timer: Timer?
    
    var body: some View {
        NavigationView {
                    VStack {
                        // Your content here
                        
                        NavigationLink(destination: WeatherPage()) {
                            Text("Allez vers la météo")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .navigationBarTitle("Accueil")
                }
       }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
