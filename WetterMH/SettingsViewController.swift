//
//  SettingsViewController.swift
//  WetterMH
//
//  Created by Michael Holzinger on 19.08.18.
//  Copyright © 2018 Michael Holzinger. All rights reserved.
//

import UIKit

protocol CanRecieve {
    func reciveDate(stationsID: Int, tageAnzeigen: Int )
}

class SettingsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var delegate : CanRecieve?
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView.tag == 1) {
            return (stationsliste?.station.count)!;
        }
        if (pickerView.tag == 2) {
            return maxTage
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        //self.picker.selectRow(self.stationsindex!, inComponent: 0, animated: true)
        if (pickerView.tag == 1) {
            return stationsliste?.station[row].name;
        }
        if (pickerView.tag == 2) {
            return "\(row+1) Tage"
        }
        return "leer"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (pickerView.tag == 1) {
            self.stationsId = self.stationsliste?.station[row].id
        }
        if (pickerView.tag == 2) {
            self.tage = row+1;
        }
    }
    
    
    
    
    var stationsliste : WetterStationsListe?
    var stationsId : Int?
    //var stationsindex : Int?
    var tage : Int?
    var anzeigeTage : Int?
    
    let maxTage = 31
    
    
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var picker2: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        picker.delegate = self
        picker2.delegate = self
        
        picker.selectRow(stationsliste!.returnArrayIndexStation(stationsId!), inComponent: 0, animated: true)
        picker2.selectRow(self.tage!-1, inComponent: 0, animated: true)

        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func zurueckButon(_ sender: Any) {
        
        delegate?.reciveDate(stationsID: self.stationsId!, tageAnzeigen: self.tage!)
        dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
