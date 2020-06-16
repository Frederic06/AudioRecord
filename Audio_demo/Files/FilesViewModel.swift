//
//  FilesViewModel.swift
//  Audio_demo
//
//  Created by Margarita Blanc on 14/06/2020.
//  Copyright © 2020 Frederic Blanc. All rights reserved.
//

import UIKit

protocol FilesViewModelDelegate{
    func dismissFiles()
    func shared(image: UIImage)
}

final class FilesViewModel {
    
    private var delegate: FilesViewModelDelegate
    
    private var files: [RecordItem] {
        didSet {
            displayRecords?(files)
        }
    }
    
    private var currentIndex: Int?
    
    init(delegate: FilesViewModelDelegate, records: [RecordItem]) {
        self.delegate = delegate
        self.files = records
    }
    
    func viewDidAppear() {
        displayRecords?(files)
    }
    
    var displayRecords: (([RecordItem]) -> ())?
    var displayRecord: ((RecordItem) -> ())?
    
    func dismiss() {
        delegate.dismissFiles()
    }
    
    func display(index: Int) {
        currentIndex = index
        let record = files[index]
        displayRecord?(record)
        
    }
    
    func share() {
        guard let index = currentIndex else {return}
        
        guard let imageData = files[index].screenShot else {return}
        guard let displayImage = UIImage(data: imageData) else {return}
        delegate.shared(image: displayImage)
    }
    
    func delete() {
        guard let index = currentIndex else {return}
        files.remove(at: index)
    }
}
