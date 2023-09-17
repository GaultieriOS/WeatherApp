//
//  weatherPage.swift
//  WeatherApp
//
//  Created by Gaultier Moraillon on 15/09/2023.
//

import SwiftUI
import CoreData


struct WeatherPage: View {
    
    @StateObject private var viewModel = WeatherPageViewModel()
    
    
    var body: some View {
        VStack {
            if viewModel.isLoading == false{
                List(viewModel.weather, id: \.name) {
                    item in
                    Section(header: HStack{Text("\(item.name)")
                            .font(.title);
                        Text("\(item.temp)°")
                            .font(.title);
                        Image(systemName: item.picto)
                            .font(.title)
                    }
                        ) {
                            
                            Text("La température mininale sera de \(item.tempMin)°.")
                            Text("La température maximale sera de \(item.tempMax)°.")
                            Text("Condition météo : \(item.cloud)")
                        }
                }
                .listStyle(SidebarListStyle())
            }
            
            HStack(alignment: .bottom){
                if viewModel.isLoading == true && viewModel.isError == false{
                    ProgressView(viewModel.labelText, value: viewModel.progressValue, total: 1.0)
                        .padding([.leading, .bottom, .trailing], 30.0)
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                }else if viewModel.isLoading == false && viewModel.isError == false{
                    Button("Recommencer") {
                        viewModel.fetchAllData()
                    }
                }
                else{
                    VStack{
                        Text(viewModel.labelText)
                            .multilineTextAlignment(.leading)
                        Button("Recommencer") {
                            viewModel.fetchAllData()
                        }
                    }
                }
            }
        }
        .navigationBarTitle("Météo")
        .onAppear(perform: viewModel.fetchAllData)
    }
    
    
}

struct WeatherPage_Previews: PreviewProvider {
    static var previews: some View {
        WeatherPage().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
