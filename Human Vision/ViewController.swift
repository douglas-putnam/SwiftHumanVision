//
//  ViewController.swift
//  Human Vision
//
//  Created by Douglas Putnam on 1/10/19.
//  Copyright © 2019 Douglas Putnam. All rights reserved.
//

import CoreML
import UIKit
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var classifierLabel: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        classifierLabel.isHidden = true
        label.text = "Ready to scan..."
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        
    }
    
    // MARK: - METHODS
    
    // Method called when user has finished picking an image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let userImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            fatalError("Failed to access camera image.")
        }
        imageView.image = userImage
        
        guard let convertedImage = CIImage(image: userImage) else {
            fatalError("Failed to convert image to CIImage format")
        }
        detect(convertedImage)
        
        imagePicker.dismiss(animated: true, completion: nil)
    }

    // Method to classify an image
    func detect(_ image: CIImage) {
        guard let model = try? VNCoreMLModel(for: PersonVsRobotClassifier().model) else {
            fatalError("Failed to load classifier.")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Failed to retreive results from classifier")
            }
            
            if let firstResult = results.first {
                let confidence = firstResult.confidence * 100.0
                if firstResult.identifier.contains("Person") {
                    self.navigationItem.title = "Human Detected"
                    self.classifierLabel.image = UIImage(named: "HUMAN")
                    self.label.textColor = UIColor.green
                    self.label.text = "Looks like a human to me. I am " + String(format: "%.1f", Double(confidence)) + "% sure."
                } else {
                    self.navigationItem.title = "Robot Detected"
                    self.classifierLabel.image = UIImage(named: "ROBOT")
                    self.label.textColor = UIColor.red
                    self.label.text = "That looks like a robot to me. I am " + String(format: "%.1f", confidence) + "% sure."
                }
                self.classifierLabel.isHidden = false
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        } catch {
            fatalError("Failed to process image. " + error.localizedDescription)
        }
    }
    
    
    // Method called when user taps the camera button
    @IBAction func cameraTapped(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
        classifierLabel.isHidden = true
    }
    
}

