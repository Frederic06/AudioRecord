//
//  MainViewController.swift
//  Audio_demo
//
//  Created by Margarita Blanc on 13/06/2020.
//  Copyright © 2020 Frederic Blanc. All rights reserved.
//

import UIKit
import CoreData

class MainViewController: UIViewController {
    
    // MARK: - Private properties
    // Default parameters
    private var choices: Choice = Choice(graphic: .rolling, autoManual: true, lengh: 2)
    
    @IBOutlet weak var registerView: UIView!
    
    @IBOutlet weak var filesView: UIView!
    
    @IBOutlet weak var parameterView: UIView!
    
    // View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        // Do any additional setup after loading the view.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - IB Actions
    
    // Adding gesture to our three views
    
    // Leads to RegisterViewController
    @IBAction func tappedOnRegister(_ sender: Any) {
        let recordViewModel = RecordViewModel(parameters: choices, delegate: self)
        let controller = storyboard?.instantiateViewController(withIdentifier: "RecordViewController") as! RecordViewController
        controller.viewModel = recordViewModel
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    // Leads to FilesViewController
    @IBAction func tappedFiles(_ sender: Any) {
        guard let records = fetchRecord() else {presentAlert(title: "Attention", message: "Aucun fichier sauvegardé"); return}
        let viewModel = FilesViewModel(delegate: self, records: records)
        let controller = storyboard?.instantiateViewController(withIdentifier: "FilesViewController") as! FilesViewController
        controller.viewModel = viewModel
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    // Leads to ParameterViewController
    @IBAction func tappedParameters(_ sender: Any) {
        let viewModel = ParameterViewModel(delegate: self, currentChoices: choices)
        let controller = storyboard?.instantiateViewController(withIdentifier: "ParametersViewController") as? ParametersViewController
        controller?.viewModel = viewModel
        self.navigationController?.pushViewController(controller!, animated: true)
    }
    
    
    // MARK: - Private methods
    private func saveRecordToPersistence(toSaveRecord: RecordItem) {
        let record = RecordEntity(context: AppDelegate.viewContext)
        record.date = toSaveRecord.date
        record.duration = toSaveRecord.duration
        record.image = toSaveRecord.screenShot
        record.name = toSaveRecord.name
        try? AppDelegate.viewContext.save()
    }
    
    private func fetchRecord() -> [RecordItem]?{
        let request: NSFetchRequest<RecordEntity> = RecordEntity.fetchRequest()
        guard let records = try? AppDelegate.viewContext.fetch(request) else {return nil}
        let fetchedRecords = records.map({return RecordItem(duration: $0.duration!, date: $0.date!, number: "", name: $0.name!, screenShot: $0.image, audioPath: "")})
        return fetchedRecords
    }
    
}

extension MainViewController: ParameterViewModelDelegate {
    
    func dismissedParameter(choices: Choice) {
        self.choices = choices
        self.navigationController?.popViewController(animated: true)
    }
}

extension MainViewController: RecordViewModelDelegate {
    func share(image: UIImage) {
        shareImage(image: image)
    }
    
    
    func saveRecord(record: RecordItem, completion: (String) -> Void?) {
        saveAlert(completion: { (name) in
            guard name != nil else {return}
            var toSaveRecord = record
            toSaveRecord.name = name!
            self.saveRecordToPersistence(toSaveRecord: toSaveRecord)
        })
        presentAlert(title: "Alerte", message: "L'enregistrement s'est correctement effectué")
    }
    
    func microPermissionDenied() {
        presentAlert(title: "Alerte d'autorisation", message: "Nous avons besoin de votre autorisation afin d'utiliser cette fonctionnalité")
        self.navigationController?.popViewController(animated: true)
    }
    
    func displayManualScreenshotAlarm() {
        presentAlert(title: "Mode manuel", message: "Cliquez n'importe où sur la zone du spectre, afin de le sauvegarder")
    }
    
    func dismissRecord() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func unknownError() {
        presentAlert(title: "Alerte erreur", message: "Une erreur inconnue est survenue, réessayez")
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension MainViewController: FilesViewModelDelegate {
    func dismissFiles() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func shared(image: UIImage) {
        self.shareImage(image: image)
    }
    
}

// Alerts
extension MainViewController {
    private func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
                
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
                
                
            @unknown default:
                print("error")
            }}))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func saveAlert(completion: @escaping (String?) -> Void)  {
        let alertController = UIAlertController(title: "Sauvegarde de l'enregistrement", message: "", preferredStyle: .alert)
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Entrez un nom"
        }
        
        let cancelAction = UIAlertAction(title: "Annuler", style: .default, handler: nil )
        
        let saveAction = UIAlertAction(title: "Sauvegarder", style: .default, handler: { alert -> Void in
            let firstTextField = alertController.textFields![0] as UITextField
            completion(firstTextField.text)
            
        })
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}

extension MainViewController {
    func shareImage(image: UIImage) {
        
        // set up activity view controller
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook,
                                                         UIActivity.ActivityType.print, UIActivity.ActivityType.airDrop, UIActivity.ActivityType.mail, UIActivity.ActivityType.saveToCameraRoll]
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
}



// Extension to fetch the data from persistence (CoreData)

