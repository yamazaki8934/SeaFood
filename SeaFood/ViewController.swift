//
//  ViewController.swift
//  SeaFood
//
//  Created by 山崎浩毅 on 2019/05/26.
//  Copyright © 2019 山崎浩毅. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // optional binding(if you can downcast this data into UIImage, then you should execute below.)
        // Using optional binding makes our code safer, more readable, and more explicit.
        if let userPickedimage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = userPickedimage
            
            // to adjust coreML
            // use guard in order to make this code safer(In case of failing converting)
            guard let ciimage = CIImage(image: userPickedimage) else {
                fatalError("Could not convert to CIImage")
            }
            
            detect(image: ciimage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(image: CIImage) {
        
        // This model is what we're going to be using to classfy our image
        // try? is error handling(if an operation is succeed, then the result is going to be wrapped as an optional. if fail, the result is going to be nil.)
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            // use guard in order to send a message to debug console
            fatalError("Loading CoreML Model Failed")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image")
            }
            
            if let firstResult = results.first {
                if firstResult.identifier.contains("hotdog") {
                    self.navigationItem.title = "Hotdog!"
                } else {
                    self.navigationItem.title = "Not Hotdog!"
                }
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        // ! means that we're forcing it to execute this line
        // try! handler.perform([request])
        // more safe code is as follws
        do {
            try handler.perform([request])
        }
        catch {
            print(error)
        }
    }

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        present(imagePicker, animated: true, completion: nil)
        
        
    }
    
}

