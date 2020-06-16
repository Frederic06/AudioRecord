

//
//  ViewController.swift
//  sound_recorder
//
//  Created by Frédéric Blanc on 11/06/2020.
//  Copyright © 2020 Frédéric Blanc. All rights reserved.
//

import UIKit
import AudioKit
import AudioKitUI

class RecordViewController: UIViewController {
    
    var viewModel: RecordViewModel!
    private var recordingTableDataSource: RecordDataSource!
    private var mic: AKMicrophone?
    private var noteFrequencies: [Float] = []
    private var tracker: AKFrequencyTracker?
    private var plot = AKNodeOutputPlot()
    private var flag = 0
    var trackedAmplitudeSlider: AKSlider?
    var trackedFrequencySlider: AKSlider?
 
    private var timer = Timer()
    private var secondTimer = Timer()

    private var oldIndex = 0
    
    // Main curved view
    @IBOutlet weak var curvedView: UIView!
    @IBOutlet weak var playStopButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeCount: UILabel!
    @IBOutlet weak var arrowBack: UIButton!
    
    // Display Record
    @IBOutlet weak var displayRecordBigView: CurvedView!
    @IBOutlet weak var displayRecordWindow: UIView!
    @IBOutlet weak var recordTitle: UILabel!
    @IBOutlet weak var recordImage: UIImageView!
    @IBOutlet weak var shareHoleView: CurvedView!
    
    @IBOutlet weak var saveHoleView: CurvedView!
    @IBOutlet var saveView: UITapGestureRecognizer!
    @IBOutlet var shareView: UITapGestureRecognizer!
    @IBOutlet weak var recordingTable: UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        checkMicroAutorisation()
        
        recordingTableDataSource = RecordDataSource(tableView: recordingTable)
        
        bind(to: recordingTableDataSource)
        bind(to: viewModel)
        viewModel.viewDidAppear()
        
        setUI()
    }
    
    // Set the status bar to light
    override var preferredStatusBarStyle: UIStatusBarStyle {
          return .lightContent
    }
    
    // Binding to the data souce to keep track of table view changes (mainly the user taping one cell)
    private func bind(to dataSource: RecordDataSource) {
        dataSource.open = viewModel.showRecording
    }
    
    // Binding to the viewModel means that the ViewController will recieve warning everytime the ViewModel property are updated
    private func bind (to viewModel: RecordViewModel) {
        viewModel.setupAudio = { [weak self] graphic, duration in
            self?.setupAudio(type: graphic, duration: duration)
        }
        
        viewModel.setOffAudio = { [weak self] in
            self?.setOffAudio()
        }
        
        viewModel.curvedViewHidden = { [weak self] bool in
//            self?.curvedView.isHidden = bool
            if bool == true {
                self?.curvedView.alpha = 0.2
                self?.curvedView.isUserInteractionEnabled = false
            } else {
                self?.curvedView.alpha = 1
                self?.curvedView.isUserInteractionEnabled = true
            }
        }
        
        viewModel.displayRecordBigView = { [weak self] bool in
            self?.displayRecordBigView.isHidden = bool
            self?.displayRecordWindow.isUserInteractionEnabled = !bool
        }
        
        viewModel.timeCountText = { [weak self] text in
            self?.timeCount.text = text
        }
        
        viewModel.recordImage = { [weak self] record in
            guard let screenShot = (record.screenShot) else {return}
            guard let image = UIImage(data: screenShot) else {return}
            self?.recordImage.image = image
            self?.recordTitle.text = record.name
        }
        
        viewModel.timerActive = { [weak self] bool in
            bool == true ? self?.timer.fire() : self?.timer.invalidate()
        }
        
        viewModel.plotActive = { [weak self] bool in
            bool == true ? self?.plot.resume() : self?.plot.pause()
        }
        
        viewModel.launchTimer = { [weak self] in
            self?.setTimer()
        }
        
        viewModel.buttonActive = { [weak self] bool in
            self?.playStopButton.tintColor = (bool == true) ? .red : .white
        }
        
        viewModel.updateTableView = recordingTableDataSource.update
        
        viewModel.saveRecording = { [weak self] in
            self?.saveRecording()
        }
        
        viewModel.addGesture = { [weak self] in
            self?.configureGesture()
        }
    }
    
    private func setUI() {
        arrowBack.layer.zPosition = 1
        displayRecordBigView.layer.zPosition = 1
        displayRecordWindow.layer.zPosition = 1
    }

    // Initialization of the Timer
    private func setTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(incrementSeconds), userInfo: nil, repeats: true)
    }

    // Is called every second to increment time
    @objc func incrementSeconds() {
        viewModel.incrementSeconds()
    }
    
    // Commands saving the record
    private func saveRecording() {
            let image = plot.takeScreenshot()
            let date = getDate()
        viewModel.constructRecording(image: image, date: date)
    }
    
    // Gets the current date to add it to the record object
    private func getDate() -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let now = Date()
        return formatter.string(from:now)
    }
    
    // Set up the Micrphone
    private func setupAudio(type: GraphicType, duration: Int) {
        
        // Necessary to avoid bugs with Microphone
        AKSettings.sampleRate = AudioKit.engine.inputNode.inputFormat(forBus: 0).sampleRate
        
        // We create an instance of Microphone
        mic = AKMicrophone()
        
        //We begin tracking our Microphone
        tracker = AKFrequencyTracker.init(mic)
        let silence = AKBooster(tracker, gain: 0)
        
        //We set our audio output to silence == We do not want to play any sound
        AudioKit.output = silence
        
        do {
            try AudioKit.start()
        } catch {
            viewModel.unknownError()
        }
        setupPlot(type: type, duration: duration)
    }
    
    // We set off the audio
    private func setOffAudio() {
        do {
            try AudioKit.stop()
        } catch {
            viewModel.unknownError()
        }
        
        plot.removeFromSuperview()
    }
    
    //Setting up the configuration of our Graphic Plot
    private func setupPlot(type: GraphicType, duration: Int) {
        
        plot = AKNodeOutputPlot(mic, frame: CGRect(x: 0,y: 0, width: self.view.frame.width, height: self.view.frame.size.height * 0.5))
        curvedView.addSubview(plot)
        
        plot.plotType = (type == .rolling) ? .rolling : .buffer
        plot.setRollingHistoryLength(Int32(duration*47))
        
        plot.shouldFill = true
        plot.shouldMirror = true
        plot.color = UIColor.white
        
        plot.backgroundColor = #colorLiteral(red: 0.4409074783, green: 0.1815316677, blue: 0.9902138114, alpha: 1)
        plot.pause()
        playStopButton.layer.zPosition = 1
        titleLabel.layer.zPosition = 1
        plot.isUserInteractionEnabled = false
    }
    
    // We check the autorisation to access the user microphone
    private func checkMicroAutorisation() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case AVAudioSessionRecordPermission.granted:
            return
        case AVAudioSessionRecordPermission.denied:
            viewModel.deniedPermission()
        case AVAudioSessionRecordPermission.undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
                return
            })
        @unknown default:
            break
        }
    }
    
    // MARK: - IBActions
    
    // Main button, which commands the audio recording
    @IBAction func playStop(_ sender: UIButton) {
        viewModel.didPressRecord()
    }
    
    // Dismisses displaying of recorded audio
    @IBAction func dismissDisplay(_ sender: Any) {
        viewModel.showRegister()
    }
    
    // Dismisses the record screen, back to the main menu
    @IBAction func backChevronTapped(_ sender: UIButton) {
        viewModel.dismissVC()
    }
    
    @IBAction func shareButton(_ sender: UITapGestureRecognizer) {
        viewModel.share()
    }
    
    @IBAction func saveButton(_ sender: UITapGestureRecognizer) {
        viewModel.saveRecord()
    }
    // Setup the gesture, for manual use
    private func configureGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(manualScreenShot))
        curvedView.addGestureRecognizer(gesture)
    }
    
    // Called by the gesture recognizare, commands manual screenshot of the spectrum
    @objc func manualScreenShot() {
        viewModel.manualSaving()
    }
}

