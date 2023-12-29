//
//  RunningLocationTests.swift
//  MapkitTutorialTests
//
//  Created by 김도현 on 2023/12/24.
//

import XCTest
import CoreLocation

final class RunningLocationTests: XCTestCase {
    
    struct LocationCreator {
        private let dummyLocation = CLLocation(latitude: 37.413294, longitude: 127.0016985)

        func create(count: Int) -> [CLLocation] {
            var locations = [CLLocation]()
            for index in 0..<count {
                locations.append(getLocation(index: index))
            }
            return locations
        }
        
        private func getLocation(index: Int) -> CLLocation {
            let timestamp = Date().addingTimeInterval(TimeInterval(index))
            return CLLocation(coordinate: CLLocationCoordinate2D(latitude: dummyLocation.coordinate.latitude + Double(index)/1000, longitude: dummyLocation.coordinate.longitude + Double(index)/1000), altitude: 0, horizontalAccuracy: 12.0, verticalAccuracy: 12.0, timestamp: timestamp)
        }
    }
       
    private let runningLocations: [CLLocation] = []
    private let locationCreator: LocationCreator = LocationCreator()
    
    func test_처음_생성되고_위치정보가_없을_경우_뷰모델의_값도_비어있음() {
        var viewModel = RunningLocationViewModel()
        viewModel.updateRunningLocation(locations: locationCreator.create(count: 0))
        
        XCTAssertEqual(RunningLocation.empty, viewModel.runningLocation.value)
    }
    
    func test_위치정보를_받고_최종_거리가_1이여함() {
        var viewModel = RunningLocationViewModel()
        viewModel.updateRunningLocation(locations: locationCreator.create(count: 5))
        print("test: \(viewModel.runningLocation.value.distance)")
    }
}
