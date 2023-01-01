//
//  ViewController.swift
//  listApp
//
//  Created by Ali Görkem Aksöz on 14.10.2022.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    var alertController = UIAlertController()
    @IBOutlet weak var tableView : UITableView!
    
    
    var data = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
        fetch()
    }

    
    @IBAction func didAddBarButtonTapped(_ sender: UIBarButtonItem){
        presentAddAlert()
    }
    
    @IBAction func didDeleteBarButtonTapped(_ sender: UIBarButtonItem){
        presentAlert(title: "Uyarı",
                     message: "Listedeki bütün elemanları silmek istediğinizden emin misiniz ?",
                     preferredStyle: UIAlertController.Style.alert,
                     cancelButtonTitle: "Vazgeç",
                     defaultButtonTitle: "Evet") { _ in
            
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            
            let managedObjectContext =  appDelegate?.persistentContainer.viewContext
            
            let deleteFetch:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "ListItem")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
            
            let deletedData = try? managedObjectContext?.execute(deleteRequest)
            
            do {
                try managedObjectContext!.execute(deleteRequest)
                self.fetch()
            } catch let error as NSError {
                fatalError(error.localizedDescription)
            }
//            self.data.removeAll()
            self.fetch()
        }
    }
    func presentAddAlert(){
        
        presentAlert(title: "Yeni Eleman Ekle",
                     message: nil,
                     cancelButtonTitle: "Vazgeç",
                     isTextFieldAvailble: true,
                     defaultButtonTitle: "Ekle") { _ in
            let text = self.alertController.textFields?.first?.text
            if text != ""{
                //self.data.append((text)!)
                
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                
                let managedObjectContext =  appDelegate?.persistentContainer.viewContext
                
                let entity = NSEntityDescription.entity(forEntityName: "ListItem",
                                                        in: managedObjectContext!)
                let listItem = NSManagedObject(entity: entity!,
                                               insertInto: managedObjectContext)
                listItem.setValue(text, forKey: "title")
                
                self.fetch()
                
                self.tableView.reloadData()
            } else{
                self.presentWarningAlert()
            }
        }
        
    }
    
    func presentWarningAlert(){
        
        presentAlert(title: "Uyarı",
                     message: "Listeye boş eleman ekleyemezsiniz",
                     cancelButtonTitle: "Tamam")
        
    }
    
    func presentAlert(title: String?,
                      message: String?,
                      preferredStyle: UIAlertController.Style = .alert,
                      cancelButtonTitle: String?,
                      isTextFieldAvailble: Bool = false,
                      defaultButtonTitle: String? = nil,
                      defaultButtonHandler: ((UIAlertAction) -> Void)? = nil) {
        alertController = UIAlertController(title: title,
                                            message: message,
                                            preferredStyle: preferredStyle)
        
        let cancelButton = UIAlertAction(title: cancelButtonTitle,
                                         style: .cancel)
        
        if (defaultButtonTitle != nil) {
            let defaultButton = UIAlertAction(title: defaultButtonTitle,
                                              style: .default,
                                              handler:defaultButtonHandler)
            alertController.addAction(defaultButton)
        }
        
        
        if isTextFieldAvailble{
            alertController.addTextField()
        }
        
        
        alertController.addAction(cancelButton)
        present(alertController, animated: true)
        
    }
    func  fetch() {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        
        let managedObjectContext =  appDelegate?.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ListItem")
        
        data = try! managedObjectContext!.fetch(fetchRequest)
        
        tableView.reloadData()
    }
}

extension ViewController :UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell", for: indexPath)
        let listItem = data[indexPath.row]
        cell.textLabel?.text = listItem.value(forKey: "title") as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .normal, title: "Sil") { _, _, _ in
            //self.data.remove(at: indexPath.row)
            
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            
            let managedObjectContext =  appDelegate?.persistentContainer.viewContext
            
            managedObjectContext?.delete(self.data[indexPath.row])
            
            try? managedObjectContext?.save()
            
            self.fetch()
        }
        deleteAction.backgroundColor = .systemRed
        
        let editAction = UIContextualAction(style: .normal, title: "Düzenle") { _, _, _ in
            
            self.presentAlert(title: "Elemanı Düzenle",
                              message: nil,
                              cancelButtonTitle: "Vazgeç",
                              isTextFieldAvailble: true,
                              defaultButtonTitle: "Düzenle") { _ in
                let text = self.alertController.textFields?.first?.text
                if text != ""{
                 //   self.data[indexPath.row] = text!
                    let appDelegate = UIApplication.shared.delegate as? AppDelegate
                    
                    let managedObjectContext =  appDelegate?.persistentContainer.viewContext
                    
                    self.data[indexPath.row].setValue(text, forKey: "title")
                    
                    if managedObjectContext!.hasChanges {
                        try? managedObjectContext?.save()
                    }
                    
                    tableView.reloadData()
                } else{
                    self.presentWarningAlert()
                }
            }
        }
      //  editAction.backgroundColor = .systemBlue
        
        let config = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        
        return config
    }
}

