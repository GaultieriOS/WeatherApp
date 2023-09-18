//
//  weatherPageViewModel.swift
//  WeatherApp
//
//  Created by Gaultier Moraillon on 15/09/2023.
//

import Foundation
import SwiftUI

struct cityWeather{
    var name: String = ""
    var cloud: String = ""
    var temp: Int = 0
    var tempMin: Int = 0
    var tempMax: Int = 0
    var picto: String = ""
}

class WeatherPageViewModel : ObservableObject {
    
    @Published var items: [Weather] = []
    @Published var weather: [cityWeather] = []
    private var currentIndex = 0
    
    private let token = "82125178fcc05780625e4459f6097e2f"
    
    @Published var progressValue: Double = 0.0
    let totalTime: Double = 60.0 // One minute in seconds
    let timerInterval: Double = 1.0 // Update the progress every 1 second
    var timer: Timer?
    
    var timerRequest: Timer?
    
    @Published var labelText = ""
    let textOptions = ["Nous téléchargeons les données…",
                       "C’est presque fini…",
                       "Plus que quelques secondes avant d’avoir le résultat…"]
    let timerIntervalText: Double = 6.0 // 6 seconds
    var timerText: Timer?
    var counter = 0
    
    var isLoading = false
    var isError = false
    
    var progress = 0
    
    let weatherPictoMap: [String: String] = [
        "Rain": "cloud.rain",
        "Thunderstorm": "cloud.bolt",
        "Drizzle": "cloud.drizzle.fill",
        "Clouds": "cloud",
        "Clear": "sun.max",
        "Snow": "cloud.snow"
    ]
    
    private let cityArray:[String] = ["Rennes","Paris","Nantes","Bordeaux","Lyon"]
    
    //Prepare to get all the data
    func fetchAllData() {
        startLoading()
        startLoop()
        isLoading = true
        isError = false
        self.progress = 0
        self.weather = []

        
        // Start a timer with a 10-second interval between API calls
        timerRequest = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { _ in
            if self.currentIndex < self.cityArray.count {
                self.fetchData(from: "https://api.openweathermap.org/data/2.5/weather?q=\(self.cityArray[self.currentIndex])&appid=\(self.token)&units=metric&lang=fr")
                self.currentIndex += 1
            } else {
                self.timerRequest?.invalidate()
                print("All API calls completed.")
                self.isLoading = false
                self.currentIndex = 0
            }
        }
    }
    
    //Get the data, decode the JSON and fill the cityWeather Struct
    func fetchData(from urlStr: String) {
        if let url = URL(string: urlStr) {
            URLSession.shared.dataTask(with: url) { (data, _, error) in
                if let error = error {
                    print("Error: \(error)")
                    self.errorHandling(Error: error)
                } else if let data = data {
                    do {
                        let item = try JSONDecoder().decode(Weather.self, from: data)
                        DispatchQueue.main.async {
                            let weatherCondition = item.weather.first?.main ?? "Unknown"
                            let picto = self.weatherPictoMap[weatherCondition] ?? "cloud.fog"
                            let city = cityWeather(
                                name: item.name,
                                cloud: item.weather.first?.description.capitalized ?? "",
                                temp: Int(item.main.temp.rounded()),
                                tempMin: Int(item.main.tempMin),
                                tempMax: Int(item.main.tempMax),
                                picto: picto
                            )
                            self.weather.append(city)
                        }
                    } catch {
                        print("Error decoding JSON: \(error)")
                        let city = cityWeather(
                            name: "Error",
                            cloud: "Les données n'ont pas pu être récupérées (JSON)",
                            temp: 0,
                            tempMin: 0,
                            tempMax: 0,
                            picto: "exclamationmark.triangle"
                        )
                        self.weather.append(city)
                    }
                }
            }.resume()
        }
    }
    
    //Start the progress bar
    func startLoading() {
        progressValue = 0.0 // Reset the progress
        timer?.invalidate() // Stop any existing timer
        
        timer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { _ in
            if self.progressValue < 1.0 {
                self.progressValue += self.timerInterval / self.totalTime
                let number = ((self.progressValue * 100).rounded() / 100)*100
                self.progress = Int(number.rounded())
                print(self.progress)
            } else {
                self.timer?.invalidate()
            }
        }
    }
    
    //Start the loop for the text
    func startLoop() {
        timerText?.invalidate()
        counter = 0
        labelText = textOptions[counter]
        
        timerText = Timer.scheduledTimer(withTimeInterval: timerIntervalText, repeats: true) { _ in
            self.counter = (self.counter + 1) % self.textOptions.count
            self.labelText = self.textOptions[self.counter]
        }
    }
    
    func errorHandling(Error: Error){
        self.labelText = "Une erreur est survenue. Veuillez ressayer plus tard.\nError: \(Error.localizedDescription)"
        self.timerText?.invalidate()
        self.timer?.invalidate()
        self.timerRequest?.invalidate()
        progressValue = 0.0
        currentIndex = 0
        self.isLoading = false
        self.isError = true
    }
}
