//
//  ViewController.swift
//  MLPhotos
//
//  Created by Paul nyondo on 04/01/2018.
//  Copyright © 2018 Paul nyondo. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController {
    //MARK: Properties
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!

    var actionSheet = UIAlertController()
    let imagePicker = UIImagePickerController()
    
    let modelFile =  MobileNet()
    
    func createActionSheet() -> UIAlertController {
        // Create action sheet to be displayed
        let actionSheet = UIAlertController(title: "Photo source", message: "Choose a photo", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action: UIAlertAction) in
            if  UIImagePickerController.isSourceTypeAvailable(.camera){
                self.imagePicker.sourceType = .camera
                self.present(self.imagePicker,animated: true, completion: nil)
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action: UIAlertAction) in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker,animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil ))
        
        return actionSheet
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        actionSheet = createActionSheet()
        
        self.imagePicker.delegate = self
        
    }
    
    @IBAction func chooseImageAction(_ sender: UIButton) {
        // display the action sheet
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func processResults(request: VNRequest, error: Error?) {
        guard let results = request.results as? [VNClassificationObservation] else {
            fatalError("Could not get results from ML Vision requests")
        }
        var bestPrediction = ""
        var bestConfidence: VNConfidence = 0
        
        for classification in results {
            if classification.confidence > bestConfidence {
                bestConfidence = classification.confidence
                bestPrediction = classification.identifier
            }
        }
        self.resultLabel.text = "\(bestPrediction) with confidence of \(bestConfidence) out of 1"
    }
    
}


extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        let imagedata = UIImagePNGRepresentation(image)
    
        guard let imgData = imagedata else {
           return
        }
        
        let model = try! VNCoreMLModel(for: modelFile.model)
        
        let handler = VNImageRequestHandler(data: imgData)
        
        let request = VNCoreMLRequest(model: model, completionHandler: processResults)
        
        try! handler.perform([ request ])

        imageView.image = image
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

