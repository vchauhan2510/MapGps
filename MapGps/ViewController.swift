//
//  ViewController.swift
//  MapGps
//
//  Created by user239727 on 3/17/24.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController
{

    @IBOutlet weak var UIcrrentspeed: UILabel!
    
    @IBOutlet weak var UIMaxspeed: UILabel!
    
    @IBOutlet weak var UIimage: UIImageView!
    
    @IBOutlet weak var UIaveragespeed: UILabel!
    
    
    @IBOutlet weak var Distance: UILabel!
    
    
    @IBOutlet weak var MaxAccelarationLable: UILabel!
    
    @IBOutlet weak var MKMapView: MKMapView!
    
    @IBOutlet weak var topbar: UIView!
    
    
    @IBOutlet weak var bottombar: UIView!
    
    private var locationManager: CLLocationManager!
        private var startLocation: CLLocation?
        private var currentLocation: CLLocation?
        private var lastLocation: CLLocation?
        private var currentspeed: CLLocationSpeed = 0.0
        private var maxSpeed: CLLocationSpeed = 0.0
        private var totalDistance: CLLocationDistance = 0.0
        private var acceleration: CLLocationSpeed = 0.0
        private var tripStartTime: Date?
        private var tripEndTime: Date?
        private var totalSpeed: CLLocationSpeed = 0.0
        private var speedReadings: Int = 0
        private var isUpdatingLocation: Bool = false
        
        // MARK: - View Lifecycle
        
        override func viewDidLoad() {
            super.viewDidLoad()
            setupLocationManager()
            setupUI()
            requestLocationPermission()
        }
        
        // MARK: - Setup
        
        private func setupLocationManager() {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
        
        private func setupUI() {
            // Use a different logo for the application
            UIimage.image = UIImage(named: "custom_logo")
        }
        
        private func requestLocationPermission() {
            locationManager.requestWhenInUseAuthorization()
        }
        
        // MARK: - Button Actions
        
        @IBAction func startTrip(_ sender: UIButton) {
            locationManager.startUpdatingLocation()
            tripStartTime = Date()
            updateUIForTripStart()
        }
        
        @IBAction func stopTrip(_ sender: UIButton) {
            locationManager.stopUpdatingLocation()
            tripEndTime = Date()
            updateUIForTripEnd()
            let distanceToExceedLimit = calculateDistanceToExceedSpeedLimit()
            print("Distance to exceed speed limit: \(distanceToExceedLimit) meters")
        }
    }

    // MARK: - CLLocationManagerDelegate

    extension ViewController: CLLocationManagerDelegate {
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard isUpdatingLocation, let newLocation = locations.last else { return }
            
            updateSpeedLabels(with: newLocation.speed)
            updateMaxSpeedLabelIfNeeded(with: newLocation.speed)
            updateAverageSpeedLabel()
            updateDistanceAndAccelerationLabels(with: newLocation)
            updateMapRegion(to: newLocation.coordinate)
            updateTopBarColor(for: newLocation.speed)
        }
    }

    // MARK: - Helper Functions

extension ViewController {
    private func updateSpeedLabels(with speed: CLLocationSpeed) {
        UIcrrentspeed.text = String(format: "%.2f km/h", abs(speed * 3.6))
        
    }
    
    private func updateMaxSpeedLabelIfNeeded(with speed: CLLocationSpeed) {
        if speed > maxSpeed {
            maxSpeed = speed
            UIMaxspeed.text = String(format: "%.2f km/h", abs(maxSpeed * 3.6))
        }
    }
    
    private func updateAverageSpeedLabel() {
        totalSpeed += currentspeed
        speedReadings += 1
        let averageSpeed = totalSpeed / Double(speedReadings)
        UIaveragespeed.text = String(format: "%.2f km/h", abs(averageSpeed * 3.6))
    }
    
    private func updateDistanceAndAccelerationLabels(with newLocation: CLLocation) {
        if let lastLocation = lastLocation {
            let distanceIncrement = newLocation.distance(from: lastLocation)
            totalDistance += distanceIncrement
            Distance.text = String(format: "%.2f km", totalDistance / 1000)
            
            let timeIncrement = newLocation.timestamp.timeIntervalSince(lastLocation.timestamp)
            acceleration = (newLocation.speed - lastLocation.speed) / timeIncrement
            MaxAccelarationLable.text = String(format: "%.2f m/s²", abs(acceleration))
        }
        lastLocation = newLocation
    }
    
    private func updateMapRegion(to coordinate: CLLocationCoordinate2D) {
        MKMapView.setCenter(coordinate, animated: true)
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        MKMapView.setRegion(region, animated: true)
    }
    
    private func updateTopBarColor(for speed: CLLocationSpeed) {
        if speed * 3.6 > 115 {
            topbar.backgroundColor = .red
        } else {
            topbar.backgroundColor = .clear
        }
    }
    
    private func updateUIForTripStart() {
        bottombar.backgroundColor = .green
        MKMapView.showsUserLocation = true
        MKMapView.setUserTrackingMode(.follow, animated: true)
        isUpdatingLocation = true
    }
    
    private func updateUIForTripEnd() {
        bottombar.backgroundColor = .gray
        UIcrrentspeed.text = "0.00 km/h"
        UIMaxspeed.text = "0.00 km/h"
        UIaveragespeed.text = "0.00 km/h"
        Distance.text = "0.00 km"
        MaxAccelarationLable.text = "0.00 m/s²"
        MKMapView.showsUserLocation = false
        MKMapView.setUserTrackingMode(.none, animated: true)
        isUpdatingLocation = false
    }
    
    private func calculateDistanceToExceedSpeedLimit() -> CLLocationDistance {
        let speedLimit = 115.0
        let averageSpeed = totalSpeed / Double(speedReadings)
        let timeToExceedLimit = (speedLimit / (averageSpeed * 3.6))
        let distanceToExceedLimit =  timeToExceedLimit*averageSpeed
        return distanceToExceedLimit
    }
}


