//
//  ParameterViewModel.swift
//  Audio_demo
//
//  Created by Margarita Blanc on 14/06/2020.
//  Copyright © 2020 Frederic Blanc. All rights reserved.
//

import Foundation

struct Choice {
    let graphic: GraphicType
    let autoManual: Bool
    let lengh: Int
}

enum GraphicType{
    case rolling, buffer, custom
}


protocol ParameterViewModelDelegate {
    func dismissedParameter(choices: Choice)
}

final class ParameterViewModel {
    
    // MARK: - Private properties
    
    private let delegate: ParameterViewModelDelegate
    
    private var auto: Bool
    
    private var lenghValue: Int {
        didSet {
            self.seconde = (lenghValue == 1) ? "seconde" : "secondes"
        }
    }
    
    private var graphicChoice: GraphicType {
        didSet {
            updateButtons?(graphicChoice)
        }
    }
    
    private var seconde = "secondes"
    
    // MARK: - Init
    
    
    init(delegate: ParameterViewModelDelegate, currentChoices: Choice) {
        self.delegate = delegate
        self.auto = currentChoices.autoManual
        self.lenghValue = currentChoices.lengh
        self.graphicChoice = currentChoices.graphic
        self.seconde = (lenghValue == 1) ? "seconde" : "secondes"
    }
    
    func viewDidAppear() {
        updateSlider?(lenghValue)
        updateRegisterMode?(auto)
        updateButtons?(graphicChoice)
        updateSliderText?("Plage d'enregistrement: \(lenghValue) \(seconde)")
    }
    
    // MARK: - Outputs
    
    var updateSlider: ((Int) -> ())?
    var updateRegisterMode: ((Bool)->())?
    var updateButtons: ((GraphicType)->())?
    var updateSliderText: ((String)->())?
    
    // MARK: - Inputs
    
    func sliderChanged(value: Int) {
        lenghValue = value
        updateSliderText?("Plage d'enregistrement: \(lenghValue) \(seconde)")
    }
    
    func segmentedChanged() {
        auto = !auto
    }
    
    func graphicChoice(type: GraphicType) {
        graphicChoice = type
        updateButtons?(graphicChoice)
    }
    
    func dismiss() {
        let choices = Choice(graphic: graphicChoice, autoManual: auto, lengh: lenghValue)
        delegate.dismissedParameter(choices: choices)
    }
}
