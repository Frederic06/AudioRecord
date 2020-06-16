//
//  RecordingDataSource.swift
//  Audio_demo
//
//  Created by Margarita Blanc on 12/06/2020.
//  Copyright © 2020 Frederic Blanc. All rights reserved.
//

import UIKit

final class RecordDataSource: NSObject, UITableViewDelegate, UITableViewDataSource{
    
    private var recordingTable: UITableView
    
    private var recordings: [RecordItem]?
    
    var open: ((Int) -> Void)?
    
    init(tableView: UITableView) {
        self.recordingTable = tableView
        super.init()
        recordingTable.delegate = self
        recordingTable.dataSource = self
    }
    
    func update(array: [RecordItem]) {
        self.recordings = array
        recordingTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard recordings != nil else { self.recordingTable.separatorStyle = UITableViewCell.SeparatorStyle.none;return 0}
        self.recordingTable.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        return recordings!.count
//        return recordings.count+1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    // We configure the header view
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = UIColor.white
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textAlignment = .left
        header.textLabel?.textColor = #colorLiteral(red: 0.1514950991, green: 0.160027355, blue: 0.241291821, alpha: 1)
        
    }
    
    // We set the header view title
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Liste des enregistrements"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                    guard let recording = recordings?[indexPath.row] else { return UITableViewCell() }
            let cell = tableView.dequeueReusableCell(withIdentifier: "recordingCell", for: indexPath) as! CustomDataCell
        cell.accessoryType = .disclosureIndicator
        cell.updateCell(with: recording)
           
            return cell

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        open?(index)
    }

}

