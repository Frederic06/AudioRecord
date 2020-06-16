//
//  CustomCell.swift
//  Audio_demo
//
//  Created by Margarita Blanc on 12/06/2020.
//  Copyright © 2020 Frederic Blanc. All rights reserved.
//


import UIKit

final class CustomDataCell: UITableViewCell {
    
    var openRecording: ((RecordItem?) -> Void)?
    
    var shareRecording: ((RecordItem?) -> Void)?
    
    private var recording: RecordItem? {
        didSet {
            guard let recording = recording else { return }
            self.number.text = recording.name
            self.date.text = recording.date
            self.duration.text = recording.duration
        }
    }
    
    @IBOutlet weak var number: UILabel!
    
    @IBOutlet weak var date: UILabel!
    
    @IBOutlet weak var duration: UILabel!
    
    func updateCell(with recording: RecordItem) {
        self.recording = recording
    }

}
