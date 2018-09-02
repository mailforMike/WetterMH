//
//  station_model.swift
//  WetterMH
//
//  Created by Michael Holzinger on 18.08.18.
//  Copyright © 2018 Michael Holzinger. All rights reserved.
//

import Foundation
import Alamofire


class WetterStation {
    
    let id : Int
    let name : String
    let hoehe : String
    
    var lat : String?
    var long : String?
    
    var wetterDaten = Wetter()
    
    var fertig : Bool = false
    
    init(id: Int, name: String, hoehe: String) {
        self.id = id
        self.name = name
        self.hoehe = hoehe
    }
    
}

protocol wetterApiDelegate {
    func eventStationFertig(id: Int)
    func eventAlleStationenFertig()
}

class WetterStationsListe{
    
    var delegate : wetterApiDelegate?
    
    var station = [WetterStation]()
    var aktuelleId : Int
    let defaultId : Int
    
    var alleFertigGeladen : Bool = false
    
    let url_base = "http://at-wetter.tk/api/v1/"
    let url_stations = "http://at-wetter.tk/api/v1/stations"
    
    let tage = 5 // wieviele Tage sollen geladen von der api geladen werden?
    
    enum Einheit : String {
        case temp = "t"
        case luftdruck = "ldstat"
        case regen = "regen"
        case sonne = "sonne"
    }
    
    init(id: Int) {
        self.defaultId = id
        self.aktuelleId = defaultId
    }

    
    // ruft nach abschluss getAll auf:
    func getWetterStationen(){
        
        Alamofire.request(url_stations, method: .get).responseString {
            response in
            if response.result.isSuccess {
                print("verbindung erfolgreich zur api (wetter stationsliste erhalten)")
                
                let request_result = String(response.result.value!)
                let wetterStationen = self.decodeResult(resultValue: request_result)
                
                for element in wetterStationen {
                    let wetterstation = WetterStation(id: Int(element[0])!, name: element[1], hoehe: element[2])
                    if (Int(element[0])! >= 100) {self.station.append(wetterstation); }
                    //print("\(element[1]) ID: \(element[0])")
                }
                
                self.getAll()
                
            } else {
                print("Fehler ApI: \(response.result.error.debugDescription)")
            }
        }
    }
    
    //alle arrays befüllen (aktuelle ID zuerst) ruft get Stationsdaten auf:
    func getAll(){
        
        print("Alle stationsdaten löschen und neu befüllen von API")
        
        self.alleFertigGeladen = false
        
        getStationsdaten(index: returnArrayIndexStation(aktuelleId))
        
        var c = 0
        for _ in station {
            if c != returnArrayIndexStation(aktuelleId) { getStationsdaten(index: c)}
            c += 1
        }
        
    }
    
    // für jeden parameter des wetters muss eine abfrage gemacht werden -> getWetter()
    func getStationsdaten (index: Int) {
        
        //print("getStationsdaten: \(station[index].name)")
        station[index].fertig = false
        
        station[index].wetterDaten.datum.removeAll()
        station[index].wetterDaten.zeit.removeAll()
        station[index].wetterDaten.luft.removeAll()
        station[index].wetterDaten.temp.removeAll()
        
        
        getWetter(stationsindex: index, param: .temp)
        getWetter(stationsindex: index, param: .luftdruck)
        
        
    }

    // ladetd einen bestimmten parameter einer bestimmten station von der API
    func getWetter(stationsindex: Int, param: Einheit){
        
        let url = "\(url_base)station/\(station[stationsindex].id)/\(param.rawValue)/\(datumAPI())/\(tage)"
        
        Alamofire.request(url, method: .get).responseString {
            response in
            if response.result.isSuccess {
                //print("API abfrage wetter \(self.station[stationsindex].name) - \(param)")
                
                let request_result = String(response.result.value!)
                let daten = self.decodeResult(resultValue: request_result)
                //füllt die stations array
                self.fillArray(index: stationsindex, param: param, daten: daten)
                //check ob station fertig ist?
                self.istFertig(index: stationsindex)
                if self.alleFertig() == true { self.delegate?.eventAlleStationenFertig() }
                
            } else {
                print("Fehler ApI: \(response.result.error.debugDescription)")
                
            }
            
            
        }// ende response function
        
    }
    
    //füllt den array mit dem zeilenstring
    func fillArray(index: Int, param: Einheit, daten: [[String]]) {
        
        for element in daten {
            
            switch param {
            case .temp:
                station[index].wetterDaten.temp.append(Double(element[5])!)
                station[index].wetterDaten.zeit.append(element[4])
                station[index].wetterDaten.datum.append(element[3])
            case .luftdruck:
                station[index].wetterDaten.luft.append(Double(element[5])!)
            case .regen:
                print("")
            case .sonne:
                print("")
            }
        }
        
    }
    
    //überprüft ob nach befüllen eines parameters alle daten einer station geladen sind
    func istFertig(index: Int){
        //print("prüfe ob fertig... \(station[index].name)")
        if (station[index].wetterDaten.temp.count > 0 && station[index].wetterDaten.luft.count > 0) {
            station[index].fertig = true
            //print("fertig: \(station[index].name)")
            delegate?.eventStationFertig(id: station[index].id)
        }
        
    }

    //erstellt auss dem API result den zeilen string
    func decodeResult(resultValue: String) -> [[String]] {
        var returnArray = [[String]]() // zweidimensionalen array erstellen
        let zeilen = resultValue.components(separatedBy: "\n")
        for zeile in zeilen {
            if (zeile != ""){
                let temporary = zeile.replacingOccurrences(of: "'", with: "")
                let element = temporary.components(separatedBy: ";")
                returnArray.append(element)
            }
        }
        return returnArray
    }
    
    //lifert den index des stations arrays anhand der stations ID zurück
    func returnArrayIndexStation (_ id: Int) -> Int {
        var c = 0
        for element in station {
            var id_e : Int
            id_e = element.id
            if id_e == id {
                return c
            }
            c += 1
        }
        return c
    }
    
    
    
    // lifert den heutigen tag als string für die API abfrage zurück
    func datumAPI() -> String {
        let date = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        
        let datum = "\(year)-\(month)-\(day)"
        
        return datum
    }
    
    // überprüft ob alle stationen geladen wurden
    func alleFertig()->Bool {
        
        var fertig = false
        for wetter in station {
            //print ("\(wetter.name) : \(wetter.fertig)")
            if wetter.fertig {
                fertig = true
            } else {
                fertig = false
                self.alleFertigGeladen = fertig
                return false
            }
        }
        //print("Alle Stationen Fertig geladen von API")
        self.alleFertigGeladen = fertig
        return fertig
    }
    
}
