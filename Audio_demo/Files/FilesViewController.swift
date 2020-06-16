//
//  FilesViewController.swift
//  Audio_demo
//
//  Created by Margarita Blanc on 13/06/2020.
//  Copyright © 2020 Frederic Blanc. All rights reserved.
//

import UIKit

class FilesViewController: UIViewController {
    
    var viewModel: FilesViewModel!
    private var recordingTableDataSource: RecordDataSource!

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var recordView: UIImageView!
    
    @IBOutlet weak var screenImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordingTableDataSource = RecordDataSource(tableView: tableView)

        bind(to: viewModel)
        bind(to: recordingTableDataSource)
        viewModel.viewDidAppear()
        
        // Do any additional setup after loading the view.
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
          return .lightContent
    }
    
    
    private func bind(to viewModel: FilesViewModel) {
        viewModel.displayRecords = recordingTableDataSource.update
        
        viewModel.displayRecord = { [weak self] record in
            guard let dataImage = record.screenShot else {return}
            let image1 = UIImage(data: dataImage)
            self?.screenImage.image = image1
            
        }
    }
    
    private func bind(to dataSource: RecordDataSource) {
        dataSource.open = viewModel.display
    }
    
    @IBAction func backArrow(_ sender: UIButton) {
        viewModel.dismiss()
    }
    @IBAction func share(_ sender: UITapGestureRecognizer) {
        viewModel.share()
    }
    
    @IBAction func unsave(_ sender: UITapGestureRecognizer) {
        print("unsave")
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
