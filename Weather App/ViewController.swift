//
//  ViewController.swift
//  Weather App
//
//  Created by Brandon Kitt on 14/7/21.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblMin: UILabel!
    @IBOutlet weak var lblMax: UILabel!
    @IBOutlet weak var tvLocation: UITextField! {
        didSet {
            tvLocation.layer.borderWidth = 1
            tvLocation.layer.borderColor = UIColor.clear.cgColor
        }
    }
    
    @IBAction func generateClicked(_ sender: Any) {
        if let location = tvLocation.text, !location.isEmpty {
            lblTitle.text = "The location at " + location + " is"
            queryForLocationData(location: location)
        } else {
            showLocationError()
        }
    }
    
    @IBAction func onTextChanged(_ sender: Any) {
        clearLocationError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    private func showLocationError() {
        tvLocation.layer.borderColor = UIColor.red.cgColor
    }
    
    private func clearLocationError() {
        tvLocation.layer.borderColor = UIColor.clear.cgColor
    }
    
    private func queryForLocationData(location: String) {
        var urlString = "https://api.openweathermap.org/data/2.5/weather?q="
        urlString.append(location)
        urlString.append("&appid=97904e638cd41e9c965871c67d11f7b2")
        
        let session = URLSession.shared
        let task = session.dataTask(with: URL(string: urlString)!, completionHandler: { data, response, error -> Void in
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode),
                  data != nil else {
                return
            }
            
            DispatchQueue.main.async {
                self.parseResponse(data: data!)
            }
        })

        task.resume()
    }
    
    private func parseResponse(data: Data) {
        if let json: [String:AnyObject] = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:AnyObject] {
            let main = json["main"] as? [String:AnyObject]
            
            let numberFormatter = NumberFormatter()
            numberFormatter.maximumFractionDigits = 2
            numberFormatter.minimumFractionDigits = 2
            
            let mf = MeasurementFormatter()
            mf.numberFormatter = numberFormatter
            mf.unitOptions = .providedUnit
            
            if let min = main?["temp_min"] as? Double {
                let kelvin = Measurement(value: min, unit: UnitTemperature.kelvin)
                let celcius = kelvin.converted(to: .celsius)
                lblMin.text = mf.string(from: celcius)
            }
            if let max = main?["temp_max"] as? Double {
                let kelvin = Measurement(value: max, unit: UnitTemperature.kelvin)
                let celcius = kelvin.converted(to: .celsius)
                lblMax.text = mf.string(from: celcius)
            }
        }
    }
}

