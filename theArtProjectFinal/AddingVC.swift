//
//  AddingVC.swift
//  theArtProjectFinal
//
//  Created by Berkay on 30.08.2022.
//

import UIKit
import CoreData

class AddingVC: UIViewController, UIGestureRecognizerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var artistTextField: UITextField!
    @IBOutlet weak var yearTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var choosenPaintingName = ""
    var choosenPaintingId : UUID?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if choosenPaintingName != ""{
            saveButton.isHidden = true
            // CoreData Part
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CoreData")
            let idString = choosenPaintingId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let Results = try context.fetch(fetchRequest)
                if Results.count > 0 {
                    for result in Results as! [NSManagedObject] {
                        
                        if let name = result.value(forKey: "name") as? String {
                            nameTextField.text = name
                        }
                        if let artist = result.value(forKey: "artist") as? String {
                            artistTextField.text = artist
                        }
                        if let year = result.value(forKey: "year") as? Int {
                            yearTextField.text = String(year)
                        }
                        if let imageData = result.value(forKey: "image") as? Data {
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                    }
                }
                
            } catch {
                print("Error, sorry")
            }
            
        } else {
            nameTextField.text = "bozuk"
            yearTextField.text = "bozuk"
            artistTextField.text = "bozuk"
            saveButton.isHidden = false
            saveButton.isEnabled = false
        }
        
        

        // Recognizers
        
        let emptyTappingGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(emptyTappingGestureRecognizer)
        imageView.isUserInteractionEnabled = true
        
        let imageViewTappingGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(chooseFromLibrary))
        imageView.addGestureRecognizer(imageViewTappingGestureRecognizer)
        

        
    }
    
    
    @objc func chooseFromLibrary() {
        
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    
    @objc func hideKeyboard() {
        
        view.endEditing(true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true)
    }
    
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        /// burada app'in kendisine CD ile olacak aksiyonları tanımlıyoruz

        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "CoreData", into: context)
        
        // Attributes //
        
        newPainting.setValue(nameTextField.text!, forKey: "name")
        newPainting.setValue(artistTextField.text!, forKey: "artist")
        
        if let year = Int(yearTextField.text!) {
            newPainting.setValue(year, forKey: "year")
        }
        newPainting.setValue(UUID(), forKey: "id")
        
        let data = imageView.image!.jpegData(compressionQuality: 0.5)
        newPainting.setValue(data, forKey: "image")
        
        do {
            try context.save()
            print("okey")
        } catch {
            print("didnt work")
        }
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
        
    }
    

}
