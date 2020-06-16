//
//  ViewModel.swift
//  Audio_demo
//
//  Created by Margarita Blanc on 13/06/2020.
//  Copyright © 2020 Frederic Blanc. All rights reserved.
//

import UIKit

protocol RecordViewModelDelegate{
    func dismissRecord()
    func saveRecord(record: RecordItem, completion: (String) -> Void?)
    func displayManualScreenshotAlarm()
    func microPermissionDenied()
    func unknownError()
    func shareImage(image: UIImage)
}

final class RecordViewModel {
    
    // MARK: - Private properties
    
    private let delegate: RecordViewModelDelegate
    
    private var seconds: Int = 0 { didSet {
        displayTime()
        if (seconds % recordingDuration == 0) && (seconds != 0) && (auto == true){
            saveRecording?()
            }
        }
    }
    
    private var number: Int = 1
    
    private var graphic: GraphicType = .rolling
    
    private var recordingDuration: Int
    
    private var auto: Bool
    
    private var recordings: [RecordItem] = [] {
        didSet {
            print("update")
            updateTableView?(recordings)
        }
    }
    
    private var currentIndexDisplaying: Int?
    
    private var isRecording = false {
        didSet {
            
            if isRecording {
                timerActive?(true)
                plotActive?(true)
                buttonActive?(true)
                launchTimer?()
            } else {
                timerActive?(false)
                buttonActive?(false)
                plotActive?(false)
                seconds = 0
            }
        }
    }
    
    // MARK: - Properties
    
    private func displayTime() {
        // if more than 59 minutes 59 seconds, time gets back to 0 seconds
        if seconds > 3599 { seconds = 0 }
        let (_,m,s) = seconds.secondsToHoursMinutesSeconds()
        let second = (s < 10) ? "0\(s)" : String(s)
        let minute = (m < 10) ? "0\(m)" : String(m)
        timeCountText?("\(minute) : \(second)")
    }
    
    private func getDate() -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let now = Date()
        return formatter.string(from:now)
    }
    
    func showRegister() {
        displayRecordBigView?(true)
        curvedViewHidden?(false)
    }
    
    // MARK: - Initializer
    
    init(parameters: Choice, delegate: RecordViewModelDelegate) {
        self.delegate = delegate
        self.graphic = parameters.graphic
        self.recordingDuration = parameters.lengh
        self.auto = parameters.autoManual
    }
    
    func viewDidAppear() {
        setupAudio?(graphic, recordingDuration)
            if auto == false {
                addGesture?()
                delegate.displayManualScreenshotAlarm()
            }
    }
    
    // MARK: - Outputs
    
    var timeCountText: ((String) -> ())?
    var displayRecordBigView: ((Bool) -> ())?
    var displayRecordWindow: ((Bool) -> ())?
    var curvedViewHidden: ((Bool) -> ())?
    var setupAudio: ((GraphicType, Int) -> ())?
    var setOffAudio: (() -> ())?
    var recordImage: ((RecordItem) -> ())?
    var timerActive: ((Bool) -> ())?
    var plotActive: ((Bool) -> ())?
    var launchTimer: (() -> ())?
    var buttonActive: ((Bool) -> ())?
    var updateTableView: (([RecordItem]) -> ())?
    var saveRecording: (() -> ())?
    var didSetNewDuration: ((Int) -> ())?
    var addGesture: (()->())?
    
    // MARK: - Inputs
    
    func didPressRecord() {
        isRecording = !isRecording
    }
    
    func incrementSeconds() {
        seconds += 1
    }
    
    func constructRecording(image: UIImage, date: String) {
        let durationText = (recordingDuration > 9) ? "00 : \(recordingDuration)" : "00 : 0\(recordingDuration)"
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {return}
        let recording = RecordItem(duration: durationText, date: date, number: ("Sans nom \(number)"), name: "Sans nom \(number)", screenShot: imageData, audioPath: "")
        number += 1
        recordings.append(recording)
    }
    
    func showRecording(index: Int) {
        let recordItem = recordings[index]
        currentIndexDisplaying = index
        isRecording = false
        displayRecordBigView?(false)
        curvedViewHidden?(true)
        recordImage?(recordItem)
        //        recordImage.image = recording?.screenShot
    }
    
    func dismissVC() {
        setOffAudio?()
        timerActive?(false)
        delegate.dismissRecord()
    }
    
    func manualSaving() {
        saveRecording?()
    }
    
    func deniedPermission() {
        delegate.microPermissionDenied()
    }
    
    func unknownError() {
        delegate.unknownError()
    }
    
    func saveRecord() {
        guard let index = currentIndexDisplaying else {return}
        let record = recordings[index]
        delegate.saveRecord(record: record, completion: { name in
            recordings[index].name = name
        })
        updateTableView?(recordings)
    }
    
    func share() {
        guard let index = currentIndexDisplaying else {return}
        guard let imageData = recordings[index].screenShot else {return}
        guard let image = UIImage(data: imageData) else {return}
        delegate.shareImage(image: image)
    }
    
}
