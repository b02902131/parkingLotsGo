//
//  ViewController.swift
//  tryMapKit
//
//  Created by Bigyo on 20/11/2016.
//  Copyright © 2016 Bigyo. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
//import LotsManager

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate  {
    //fixBranch
    @IBOutlet weak var myMap: MKMapView!
    var locationMgr = CLLocationManager()
    
    var isAddingLots: Bool = false
    
    @IBOutlet weak var text: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fullScreenSize = UIScreen.main.bounds.size
        //long press gesture setup
        let uilgr = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.longPress(_:)))
        uilgr.minimumPressDuration = 2.0
        
        //add lots gesture setup
        let singleFinger = UITapGestureRecognizer(target:self,action:#selector(ViewController.singleTap(_:)))
        
        // 點幾下才觸發 設置 2 時 則是要點兩下才會觸發 依此類推
        singleFinger.numberOfTapsRequired = 1
        
        // 幾根指頭觸發
        singleFinger.numberOfTouchesRequired = 1
        
        // 雙指輕點沒有觸發時 才會檢測此手勢 以免手勢被蓋過
        singleFinger.require(toFail: uilgr)
        
        //加入監聽
        self.view.addGestureRecognizer(uilgr)
        self.view.addGestureRecognizer(singleFinger)
        
        myMap.delegate = self
        myMap.mapType = MKMapType.standard
        myMap.showsUserLocation = true
        
        //Button 的==================
        var myButton = UIButton(type: .system)
        myButton = UIButton(type: .system)
        myButton.frame = CGRect(
            x: 0, y: 0, width: 100, height: 30)
        myButton.setTitle("Parking Lot", for: .normal)
        myButton.backgroundColor = UIColor.init(
            red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        myButton.addTarget(
            nil,
            action: #selector(ViewController.tapParkingLots),
            for: .touchUpInside)
        myButton.center = CGPoint(
            x: fullScreenSize.width * 0.15,
            y: fullScreenSize.height * 0.9)
        self.view.addSubview(myButton)
        //Button 的==================
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        locationMgr.delegate = self
        //詢問使用者是否同意給APP定位功能
        locationMgr.requestAlwaysAuthorization()
        locationMgr.requestWhenInUseAuthorization()
        locationMgr.distanceFilter = 3.0    // 移動超過三公尺就會更新目前位置
        
        getLocation()
    }
    
    func editLotsNumber(coordinate :CLLocationCoordinate2D) {
        // 建立一個提示框
        let alertController = UIAlertController(
            title: "設置停車格",
            message: "請輸入停車格數量",
            preferredStyle: .alert)
        
        // 建立輸入框
        alertController.addTextField {
            (textField: UITextField!) -> Void in
            textField.placeholder = "數量"
        }
        // 建立[取消]按鈕
        let cancelAction = UIAlertAction(
            title: "取消",
            style: UIAlertActionStyle.default){
                (action: UIAlertAction!) -> Void in
                self.isAddingLots = false
        }
        alertController.addAction(cancelAction)
        
        // 建立[登入]按鈕
        let okAction = UIAlertAction(
            title: "確認",
            style: UIAlertActionStyle.default) {
                (action: UIAlertAction!) -> Void in
                let acc =
                    (alertController.textFields?.first)!
                        as UITextField
                
                print("輸入的帳號為：\(acc.text)")
                //新增車格 fake
                self.addLotAnnotation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                //新增車格 real (through the LotsManager
//                LotsManager(coordinate, Int(acc.text))
                self.isAddingLots = false
        }
        alertController.addAction(okAction)
        
        // 顯示提示框
        self.present(
            alertController,
            animated: true,
            completion: nil)
    }
    
    func singleTap(_ recognizer: UITapGestureRecognizer){
        print("single tap")
        if(isAddingLots){
            print("single tap, and isAddingLots == true")
            self.findFingersPositon(recognizer)
        }
    }
    
    func findFingersPositon(_ recognizer:UITapGestureRecognizer) {
        // 取得每指的位置
        let number = recognizer.numberOfTouches
        for i in 0..<number {
            let point = recognizer.location(ofTouch: i, in: recognizer.view)
            print("第 \(i + 1) 指的位置：\(NSStringFromCGPoint(point))")
            
            //在點擊的點位新增標記
            let newCoordinates = myMap.convert(point, toCoordinateFrom: myMap)
            
            //call login, pass coordinate
            editLotsNumber(coordinate: newCoordinates)
            
            //待刪 12.15
            //addLotAnnotation(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude)
        }
        
    }
    
    func longPress(_ recongnizer:UILongPressGestureRecognizer){
        if recongnizer.state == .began{
            print("長按開始")
        }
        else if recongnizer.state == .ended{
            print("長按結束")
        }
    }
   
    func tapParkingLots(){
        isAddingLots = !isAddingLots
        //for convenience
    }
    
    
    @IBAction func btn_getLocation(_ sender: UIButton) {
        
        getLocation()
        print("button get Location")
    }
    
    func getLocation(){
        locationMgr.desiredAccuracy = kCLLocationAccuracyBest
        locationMgr.startUpdatingLocation()
    }
    
//    override func viewDidDisappear(_ animated: Bool) {
//        //因為ＧＰＳ功能很耗電,所以背景執行時關閉定位功能
//        locationMgr.stopUpdatingLocation();
//    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //http://toyo0103.blogspot.tw/2015/03/swift-ios-1.html
        //取得目前的座標位置
        let c = locations[0] as CLLocation;
        let nowLocation = CLLocationCoordinate2D(latitude: c.coordinate.latitude, longitude: c.coordinate.longitude);
        
        //將map中心點定在目前所在的位置
        //span是地圖zoom in, zoom out的級距
        let _span:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.0005, longitudeDelta: 0.0005);
        self.myMap.setRegion(MKCoordinateRegion(center: nowLocation, span: _span), animated: true);
        print("locationManager")
    }
    
    
    //新增車格於某位置
    private func addLotAnnotation(latitude:CLLocationDegrees , longitude:CLLocationDegrees){
        //大頭針
        let point:MKPointAnnotation = MKPointAnnotation();
        //設定大頭針的座標位置
        point.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude);
        point.title = "Parking Lots here";
//        point.subtitle = "緯度：\(latitude) 經度:\(longitude)";
        
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        var addressString : String = ""
        geocoder.reverseGeocodeLocation(location, completionHandler: {(placemarks, error)->Void in
            var placemark:CLPlacemark!
            
            if error == nil && (placemarks?.count)! > 0 {
                placemark = (placemarks?[0])! as CLPlacemark
                
                if placemark.isoCountryCode == "TW" /*Address Format in Chinese*/ {
                    if placemark.country != nil {
                        addressString = placemark.country!
                    }
                    if placemark.subAdministrativeArea != nil {
                        addressString = addressString + placemark.subAdministrativeArea! + ", "
                    }
                    if placemark.postalCode != nil {
                        addressString = addressString + placemark.postalCode! + " "
                    }
                    if placemark.locality != nil {
                        addressString = addressString + placemark.locality!
                    }
                    if placemark.thoroughfare != nil {
                        addressString = addressString + placemark.thoroughfare!
                    }
                    if placemark.subThoroughfare != nil {
                        addressString = addressString + placemark.subThoroughfare!
                    }
                } else {
                    if placemark.subThoroughfare != nil {
                        addressString = placemark.subThoroughfare! + " "
                    }
                    if placemark.thoroughfare != nil {
                        addressString = addressString + placemark.thoroughfare! + ", "
                    }
                    if placemark.postalCode != nil {
                        addressString = addressString + placemark.postalCode! + " "
                    }
                    if placemark.locality != nil {
                        addressString = addressString + placemark.locality! + ", "
                    }
                    if placemark.administrativeArea != nil {
                        addressString = addressString + placemark.administrativeArea! + " "
                    }
                    if placemark.country != nil {
                        addressString = addressString + placemark.country!
                    }
                }
                //subtitle
                point.subtitle = "地址:"+addressString
            }
        })//end of reverseGeocodeLocation
        //新增
        myMap.addAnnotation(point);
    }
    
    //MARK: - Custom Annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //prevent the current location to show up as a pin
        if (annotation.isEqual(mapView.userLocation))
        {
            return nil;
        }
        
        let reuseIdentifier = "pin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        
       annotationView?.image = UIImage(named: "greenPin.png")
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView,
                 regionWillChangeAnimated animated: Bool) {
        print("地圖縮放或滑動時")
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        print("載入地圖完成時")
    }
    
    func mapView(_ mapView: MKMapView,
                 annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        print("點擊大頭針的說明")
    }
    
    func mapView(_ mapView: MKMapView,
                 didSelect view: MKAnnotationView) {
        print("點擊大頭針")
    }
    
    func mapView(_ mapView: MKMapView,
                 didDeselect view: MKAnnotationView) {
        print("取消點擊大頭針")
    }
}
