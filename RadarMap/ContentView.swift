//
//  ContentView.swift
//  RadarMap
//
//  Created by Jordan Baumgardner on 5/2/21.
//

import SwiftUI
import SwiftSoup
import CoreLocation

func getOverlays() -> [RadarOverlay] {
    var overlays: [RadarOverlay] = []
    for time in getTimesURL() {
        let template = "https://tilecache.rainviewer.com/v2/radar/\(time)/256/{z}/{x}/{y}/7/1_1.png"
        
        //let template = "https://tile.openweathermap.org/map/wind_new/{z}/{x}/{y}.png?appid=\(OWMConstants.APIKey)"
        
        let overlay = RadarOverlay(urlTemplate:template)
        overlays.append(overlay)

    }

    return overlays
    
}

func getTimesURL() -> [String] {
    let myURLString = "https://api.rainviewer.com/public/maps.json"
    guard let myURL = URL(string: myURLString) else {
        print("Error: \(myURLString) doesn't seem to be a valid URL")
        return []
    }

    do {
        let myHTMLString = try String(contentsOf: myURL)
        do {
           let doc: Document = try SwiftSoup.parse(myHTMLString)
            
            let text = try doc.text()
            let resultArray = text.trimmingCharacters(in: CharacterSet(charactersIn: "[]"))
                .components(separatedBy:",")
            return resultArray

            
        } catch Exception.Error( _, let message) {
            print(message)
        } catch {
            print("error")
        }
    } catch let error as NSError {
        print("Error: \(error)")
    }
    return []
    
}


struct ContentView: View {
    // Get overlay tiles for available times
    static var overlayArray: [RadarOverlay] {
        getOverlays()
    }
    
    // Get available times
    static var timeArray: [String] {
        getTimesURL()
    }
    
    @State var timeString = "Current"
    @State var animating = false
    
    func updateTimeStamp(_ timeStr: String){
        self.timeString = timeStr
    }
    
    var body: some View {
        VStack{
        HStack{
            Text("Radar: \(timeString)")
            
            Button(action: {
                self.animating.toggle()
            }, label: {
                if self.animating {
                    Text("Stop")
                } else {
                    Text("Animate")
                }
            })
        }
            RadarView(mapStyle: .mutedStandard, overlays: ContentView.overlayArray, location: CLLocation().coordinate, times: ContentView.timeArray, animate: animating, updateTimeStamp: updateTimeStamp)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
