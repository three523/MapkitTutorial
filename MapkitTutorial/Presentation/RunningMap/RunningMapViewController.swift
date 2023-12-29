//
//  ViewController.swift
//  MapkitTutorial
//
//  Created by 김도현 on 2023/12/22.
//

import UIKit
import SnapKit
import MapKit

final class ViewController: UIViewController {
    
    private let mapView: MKMapView = {
        let map = MKMapView()
        map.mapType = .mutedStandard
        return map
    }()
    
    private let userLoactionButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 30
        button.backgroundColor = .clear
        button.tintColor = .systemBlue
        button.setBackgroundImage(UIImage(systemName: "location.circle"), for: .normal)
        return button
    }()
    
    private let userDistance: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .black
        return label
    }()
    
    private let userSpeed: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .black
        return label
    }()
    private let userSpeedAccuracy: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .black
        return label
    }()
    
    private let locationManager = CLLocationManager()
    private let runningLocationViewModel: DefaultRunningLocationViewModel = DefaultRunningLocationViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        checkAuthorization()
        mapView.setUserTrackingMode(.follow, animated: true)
    }
    
    func checkAuthorization() {
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .notDetermined:
            runningLocationViewModel.manager.requestWhenInUseAuthorization()
        case .authorizedAlways:
            print("authorizedAlways")
            mapView.showsUserLocation = true
        case .authorizedWhenInUse:
            print("authorizedWhenInUse")
            mapView.showsUserLocation = true
        case .authorized:
            print("authorized")
            mapView.showsUserLocation = true
        default:
            presentGpsAuthAlert()
        }
    }
    
    func presentGpsAuthAlert() {
        guard let appSettingURL = URL(string: "\(UIApplication.openSettingsURLString)") else { return }
        let alert = UIAlertController(title: "Gps 접근 권한이 필요합니다", message: "설정 > MapKitTutorial > 위치 로 이동하여 앱을 사용하는 동안을 클릭하여주세요", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "수락", style: .default) { _ in
            UIApplication.shared.open(appSettingURL)
        }
        let cancelAction = UIAlertAction(title: "취소", style: .destructive)
        
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
}

//MARK: SetUp
private extension ViewController {
    
    func setup() {
        addViews()
        setupAutoLayout()
        setupNavigation()
        bind()
    }
    
    func addViews() {
        view.addSubview(mapView)
        mapView.addSubview(userLoactionButton)
        mapView.addSubview(userDistance)
        mapView.addSubview(userSpeed)
        mapView.addSubview(userSpeedAccuracy)
    }
    
    func setupAutoLayout() {
        let safearea = view.safeAreaLayoutGuide
        mapView.snp.makeConstraints { make in
            make.edges.equalTo(safearea)
        }
        userLoactionButton.snp.makeConstraints { make in
            make.bottom.right.equalToSuperview().inset(16)
            make.height.width.equalTo(60)
        }
        userDistance.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.centerX.equalToSuperview()
        }
        userSpeed.snp.makeConstraints { make in
            make.top.equalTo(userDistance.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        userSpeedAccuracy.snp.makeConstraints { make in
            make.top.equalTo(userSpeed.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
    }
    
    func updateUI(runningLocation: RunningLocation) {
        DispatchQueue.main.async {
            self.userDistance.text = runningLocation.distance
            self.userSpeed.text = runningLocation.speed
            self.userSpeedAccuracy.text = runningLocation.speedAccuracy
        }
    }
    
    func setupButton() {
        userLoactionButton.addTarget(self, action: #selector(setUserRegion), for: .touchUpInside)
    }
    
    @objc func setUserRegion() {
        guard let location = mapView.userLocation.location?.coordinate else { return }
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func setupNavigation() {
        navigationItem.title = "운동 결과"
    }
    
    func bind() {
        runningLocationViewModel.runningLocation.observe(on: self) { [weak self] runningLocation in
            self?.updateUI(runningLocation: runningLocation)
        }
    }
}

