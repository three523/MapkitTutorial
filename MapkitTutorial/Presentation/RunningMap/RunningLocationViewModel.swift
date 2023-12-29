//
//  RunningLocationManager.swift
//  MapkitTutorial
//
//  Created by 김도현 on 2023/12/24.
//

import Foundation
import CoreLocation

struct RunningLocation {
    var distance: String
    var speed: String
    var speedAccuracy: String
    var runningDate: String
    
    static let empty: RunningLocation = .init(distance: "", speed: "", speedAccuracy: "", runningDate: "")
}

class RunningMapViewModel: NSObject {
    let manager: CLLocationManager = CLLocationManager()
    var runningLocation: Observable<RunningLocation> = Observable(.empty)
    var totalLocation: [CLLocation] = [CLLocation]()
    var previousLocation: CLLocation?
        
    func updateRunningLocation(locations: [CLLocation]) {
        if locations.last == nil { return }
        let newLocations = fliterNewLocations(locations)
        var newRunningLocation = runningLocation.value
        
        newLocations.forEach { newLocation in
            newRunningLocation = addDistance(newLocation: newLocation, to: newRunningLocation)
        }
        
        self.runningLocation.value = newRunningLocation
    }
    
    fileprivate func addDistance(newLocation: CLLocation, to runningLocation: RunningLocation) -> RunningLocation {
        if let previousLocation = previousLocation {
            let distance = (Double(runningLocation.distance) ?? 0.0) + newLocation.distance(from: previousLocation)
            let speed = newLocation.speedAccuracy > 5.0 ? String(newLocation.speed) : runningLocation.speed
            
            self.previousLocation = newLocation
            
            return RunningLocation(distance: String(distance), speed: speed, speedAccuracy: String(newLocation.speedAccuracy), runningDate: runningLocation.runningDate)
        }
        self.previousLocation = newLocation
        return runningLocation
    }
    
    fileprivate func fliterNewLocations(_ locations: [CLLocation]) -> [CLLocation] {
        let setLocations = Set(locations)
        let setOldLocations = Set(totalLocation)

        let setNewLocations = setLocations.subtracting(setOldLocations)
        return Array(setNewLocations).filter{ $0.horizontalAccuracy >= 10.0 }.sorted{ $0.timestamp < $1.timestamp }
    }
}


final class DefaultRunningLocationViewModel: RunningMapViewModel {
    
    var startLocation: Observable<CLLocation?> = Observable(nil)
    
    override init() {
        super.init()
        manager.delegate = self
        setupManager()
    }
    
    private func setupManager() {
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.startUpdatingLocation()
    }
        
}

extension DefaultRunningLocationViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        updateRunningLocation(locations: locations)
        if totalLocation.count == 0 {
            self.startLocation.value = locations.first
        }
    }
}

extension Date {
    var toString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd a hh시 mm분"
        return dateFormatter.string(from: self)
    }
}
