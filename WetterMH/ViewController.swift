//
//  ViewController.swift
//  WetterMH
//
//  Created by Michael Holzinger on 18.08.18.
//  Copyright © 2018 Michael Holzinger. All rights reserved.
//

import UIKit
import Alamofire
import SwiftChart
import SVProgressHUD


class ViewController: UIViewController, ChartDelegate, CanRecieve, wetterApiDelegate{
   
    var stationsliste = WetterStationsListe(id: 11035)
    
    //var aktualisieren : Bool = true
    
    var tageAnzeige = 2 // wieviele tage sollen angezeigt werden? (1 tag -> 24h)
    
    @IBOutlet weak var chart2: Chart!
    @IBOutlet weak var logtext: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var zeitLabel: UILabel!
    @IBOutlet weak var standort: UILabel!
    
    func reciveDate(stationsID: Int, tageAnzeigen: Int) {
        //print("daten empfange: \(stationsID), \(tageAnzeigen)")
        stationsliste.aktuelleId = stationsID
        self.tageAnzeige = tageAnzeigen
        
        if (stationsliste.station[stationsliste.returnArrayIndexStation(stationsID)].fertig) {
            updateStatistics()
        } else {
           chart2.removeAllSeries()
            
        }
        
    }
    
    func eventStationFertig(id: Int) {
        if id == stationsliste.aktuelleId {
            updateStatistics()
        }
        print ("\(stationsliste.station[stationsliste.returnArrayIndexStation(id)].name) fertig: \(stationsliste.station[stationsliste.returnArrayIndexStation(id)].fertig)")
    }
    
    func eventAlleStationenFertig() {
        print("EVENT ALLE FERTIG")
    }
    
    
    func didTouchChart(_ chart: Chart, indexes: [Int?], x: Double, left: CGFloat) {
        
        zeitLabel.text = "\(stationsliste.station[stationsliste.returnArrayIndexStation(stationsliste.aktuelleId)].wetterDaten.zeit[Int(x)])"
        
        tempLabel.text = "\(stationsliste.station[stationsliste.returnArrayIndexStation(stationsliste.aktuelleId)].wetterDaten.temp[Int(x)])°C"
        
        zeitLabel.center.x = left
        tempLabel.center.x = left
        
    }
    
    func didFinishTouchingChart(_ chart: Chart) {
    }
    
    func didEndTouchingChart(_ chart: Chart) {
    }
    
    
    func updateStatistics(){
        
        SVProgressHUD.dismiss()
        print("DIAGRAMM NEU ZEICHNEN (\(stationsliste.station[stationsliste.returnArrayIndexStation(stationsliste.aktuelleId)].name))")
        
        chart2.removeAllSeries()
        
        var tempArray = stationsliste.station[stationsliste.returnArrayIndexStation(stationsliste.aktuelleId)].wetterDaten.temp
        var luftArray = stationsliste.station[stationsliste.returnArrayIndexStation(stationsliste.aktuelleId)].wetterDaten.luft
        
        let aktuelle_temp = tempArray[tempArray.count-1]
        let aktueller_luftdruck = luftArray[luftArray.count-1]
        
        //print("temp count: \(tempArray.count) \(aktuelle_temp)")
        //print("luft count: \(luftArray.count) \(aktueller_luftdruck)")
        
        logtext.text = "Temp: \(aktuelle_temp) Luftdruck: \(aktueller_luftdruck) Höhe: \(stationsliste.station[stationsliste.returnArrayIndexStation(stationsliste.aktuelleId)].hoehe)"
        standort.text = "\(stationsliste.station[stationsliste.returnArrayIndexStation(stationsliste.aktuelleId)].name) - \(tempArray.count) Mesungen"
        
        var datensatz_temp = [Double]()
        var datensatz_luft = [Double]()
        
        let counter = tempArray.count - (tageAnzeige * 24)
        
        
        var c = 0
        for wert in tempArray {
            let val = wert
           
            if c > counter { datensatz_temp.append(val) }
            c += 1
        }
        let series_temp = ChartSeries(datensatz_temp)
        
        
        var copyarray = luftArray
        copyarray = relativiereArray(eingabearray: luftArray)
        c = 0
        for wert in copyarray {
            let val2 = wert
            if c > counter { datensatz_luft.append(val2) }
            c += 1
        }
        let series_luft = ChartSeries(datensatz_luft)
        
        
        
        series_temp.color = ChartColors.redColor()
        series_temp.area = true
        series_luft.color = ChartColors.cyanColor()
        
        
        chart2.bottomInset = 2
        chart2.showXLabelsAndGrid = false

        chart2.add(series_temp)
        chart2.add(series_luft)
 
    }
    
    func relativiereArray(eingabearray :[Double]) ->[Double]{
        let max_temp = Double(stationsliste.station[stationsliste.returnArrayIndexStation(stationsliste.aktuelleId)].wetterDaten.temp.max()!)
        let min_temp = Double(stationsliste.station[stationsliste.returnArrayIndexStation(stationsliste.aktuelleId)].wetterDaten.temp.min()!)
        let max_scaledValue = Double(eingabearray.max()!)
        let min_scaledValue = Double(eingabearray.min()!)
        
        //print("temp max: \(max_temp) temp min: \(min_temp)")
        //print("value max: \(max_scaledValue) value min: \(min_scaledValue)")
        
        let high_temp : Double = max_temp - min_temp
        let high_scaledValue : Double = max_scaledValue - min_scaledValue
        
        //print("hightemp: \(high_temp) highvalue: \(high_scaledValue)")
        
        // neuer wert * hightemp / high scaled
        
        var scaledArray = [Double]()
        
        for wert in eingabearray {
            var wertDouble = Double(wert)
            wertDouble = wertDouble - min_scaledValue
            let neuerWert : Double = ((wertDouble * high_temp) / high_scaledValue) + min_temp
            scaledArray.append(neuerWert)
        }
        
        return scaledArray
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        stationsliste.getWetterStationen()
        stationsliste.delegate = self
        
        logtext.text = "Starting Up ..."
        
        SVProgressHUD.show()
        
        standort.text = ""
        
        tempLabel.text = ""
        zeitLabel.text = ""
        
        chart2.delegate = self
        
    }
    
    
    @IBAction func refreshButtonPressed(_ sender: Any) {
        print("refresch")

        if (stationsliste.alleFertigGeladen == true) {
            stationsliste.getAll()
        } else {
            print("ladevorgang noch nicht abgeschlossen....")
        }
        
    }
    
    
    @IBAction func settingsButtonPressed(_ sender: Any) {
        print("Button Settings")
        performSegue(withIdentifier: "goToSettings", sender: self)
        
    }
    
    
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToSettings" {
            
            let destinationVC = segue.destination as! SettingsViewController
            
            destinationVC.tage = self.tageAnzeige
            destinationVC.stationsliste = self.stationsliste
            destinationVC.stationsId = self.stationsliste.aktuelleId
            
            destinationVC.delegate = self
            
        }
    }
    
    func returnFertigeStationen(wetterstationen: [WetterStation]) -> [WetterStation] {
        var tempArray = [WetterStation]()
        for station in wetterstationen {
            if station.fertig {
                tempArray.append(station)
            }
        }
        return tempArray
    }
    
}

