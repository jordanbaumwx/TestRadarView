//
//  RadarMapView.swift
//  RadarViewer
//
//  Created by Jordan Baumgardner on 9/25/20.
//

import Foundation
import SwiftUI
import MapKit

struct RadarView: UIViewRepresentable, Equatable {
    // Actual Map View
    var mapStyle: MKMapType
    var overlays: [RadarOverlay]
    var location: CLLocationCoordinate2D
    var times: [String]
    
    var animate: Bool
    
    var updateTimeStamp: (String) -> Void
    
    fileprivate let locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.requestWhenInUseAuthorization()
        return manager
    }()

    
    static func ==(lhs: RadarView, rhs: RadarView) -> Bool {
        return lhs.animate == rhs.animate && lhs.mapStyle == rhs.mapStyle
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: RadarView

        init(_ parent: RadarView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            
            let renderer = MKTileOverlayRenderer(overlay: overlay)
            renderer.alpha = 0.75
            
            return renderer
        }
        
        
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.mapType = self.mapStyle
        mapView.delegate = context.coordinator

        mapView.showsUserLocation = true
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.isUserInteractionEnabled = true
        let regionRadius: CLLocationDistance = 50000
        let coordinateRegion = MKCoordinateRegion(center: location,
                                                  latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        
        mapView.setRegion(coordinateRegion, animated: true) // Sets a static map region

        var i = 0
        let _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if self.animate {
                let index = i % overlays.count
                let localOverlays = mapView.overlays

                mapView.addOverlay(self.overlays[index])
                mapView.removeOverlays(localOverlays) // Removes Overlays
                updateTimeStamp(dateToHourString(self.times[index]))
                i = index + 1


            } else {
                print("Stop Animate")

                timer.invalidate()
                let localOverlays = mapView.overlays
                mapView.removeOverlays(localOverlays) // Removes Overlays
                mapView.addOverlay(overlays[overlays.count-1])
            }
        }
    
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        // Save overlays currently showing on maps
        mapView.mapType = self.mapStyle

        
        let localOverlays = mapView.overlays
        mapView.removeOverlays(localOverlays) // Removes Overlays

        var i = 0
        let _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if self.animate {
                let index = i % overlays.count
                let localOverlays = mapView.overlays

                mapView.addOverlay(self.overlays[index])
                mapView.removeOverlays(localOverlays) // Removes Overlays
                updateTimeStamp(dateToHourString(self.times[index]))
                i = index + 1


            } else {
                print("Stop Animate")

                timer.invalidate()
                let localOverlays = mapView.overlays
                mapView.removeOverlays(localOverlays) // Removes Overlays
                mapView.addOverlay(overlays[overlays.count-1])
            }
        }

    }
}


func dateToHourString(_ epoch: String) -> String{
    let dateFormatterPrint = DateFormatter()
    dateFormatterPrint.locale = NSLocale(localeIdentifier: NSLocale.current.languageCode!) as Locale
    dateFormatterPrint.dateFormat = "hh:mm a"

    let date = Date(timeIntervalSince1970: TimeInterval(Int(epoch)!))
    return dateFormatterPrint.string(from: date)
}

