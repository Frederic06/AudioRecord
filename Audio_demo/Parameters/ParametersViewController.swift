//
//  ParametersViewController.swift
//  Audio_demo
//
//  Created by Margarita Blanc on 13/06/2020.
//  Copyright © 2020 Frederic Blanc. All rights reserved.
//

import UIKit

class ParametersViewController: UIViewController {
    
    // MARK: - Private properties
    
    var viewModel: ParameterViewModel!
    
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var slider: UISlider!
    
    @IBOutlet weak var firstButton: CurvedView!
    
    @IBOutlet weak var firstButtonImage: UIImageView!
    
    @IBOutlet weak var segmented: UISegmentedControl!
    
    @IBOutlet weak var secondButton: CurvedView!
    
    @IBOutlet weak var secondButtonImage: UIImageView!
    
    @IBOutlet weak var lenghText: UILabel!
    
    @IBOutlet weak var thirdButton: CurvedView!
    
    @IBOutlet weak var thirdButtonImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resetButtons()
        bind(to: viewModel)
        viewModel.viewDidAppear()
        setUI()
    }
    
    // Set the status bar to light
    override var preferredStatusBarStyle: UIStatusBarStyle {
          return .lightContent
    }
    // We bind ViewController to ViewModel's properties
    private func bind(to viewModel: ParameterViewModel) {
        viewModel.updateButtons = { [weak self] type in
            self?.resetButtons()
            switch type {
            case .rolling:
                self?.firstButton.backgroundColor = #colorLiteral(red: 0.4454075694, green: 0.1803351641, blue: 0.9983728528, alpha: 1)
                self?.firstButtonImage.tintColor = .white
            case .buffer:
                self?.secondButton.backgroundColor = #colorLiteral(red: 0.4454075694, green: 0.1803351641, blue: 0.9983728528, alpha: 1)
                self?.secondButtonImage.tintColor = .white
            case .custom:
                self?.thirdButton.backgroundColor = #colorLiteral(red: 0.4454075694, green: 0.1803351641, blue: 0.9983728528, alpha: 1)
                self?.thirdButtonImage.tintColor = .white
            }
        }
        
        viewModel.updateSlider = { [weak self] value in
            self?.slider.setValue(Float(value), animated: true)
        }
        
        viewModel.updateRegisterMode = { [weak self] bool in
            self?.segmented.selectedSegmentIndex = (bool == true) ? 0 : 1
        }
        
        viewModel.updateSliderText = { [weak self] text in
            self?.lenghText.text = text
        }
        
    }
    
    
    private func setUI() {
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
           segmented.setTitleTextAttributes(titleTextAttributes, for: .normal)
           segmented.setTitleTextAttributes(titleTextAttributes, for: .selected)
    }
    
    private func resetButtons() {
        self.firstButton.backgroundColor = #colorLiteral(red: 0.9236616492, green: 0.9333544374, blue: 0.9677243829, alpha: 1)
        self.firstButtonImage.tintColor = #colorLiteral(red: 0.007326011546, green: 0.469198823, blue: 0.9817305207, alpha: 1)
        self.secondButton.backgroundColor = #colorLiteral(red: 0.9236616492, green: 0.9333544374, blue: 0.9677243829, alpha: 1)
        self.secondButtonImage.tintColor = #colorLiteral(red: 0.007326011546, green: 0.469198823, blue: 0.9817305207, alpha: 1)
        self.thirdButton.backgroundColor = #colorLiteral(red: 0.9236616492, green: 0.9333544374, blue: 0.9677243829, alpha: 1)
        self.thirdButtonImage.tintColor = #colorLiteral(red: 0.007326011546, green: 0.469198823, blue: 0.9817305207, alpha: 1)
    }
    
    // MARK: - IBActions
    
    @IBAction func slider(_ sender: UISlider) {
        let value = Int(sender.value)
        viewModel.sliderChanged(value: value)
    }
    
    @IBAction func segmented(_ sender: UISegmentedControl) {
        viewModel.segmentedChanged()
    }
    
    
    @IBAction func firstButton(_ sender: Any) {
        viewModel.graphicChoice(type: .rolling)
    }
    
    @IBAction func secondButton(_ sender: Any) {
        viewModel.graphicChoice(type: .buffer)
    }
    
    @IBAction func thirdButton(_ sender: Any) {
        viewModel.graphicChoice(type: .custom)
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        viewModel.dismiss()
    }
    
}
