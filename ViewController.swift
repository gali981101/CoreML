//
//  ViewController.swift
//  Dasha
//
//  Created by Terry Jason on 2023/12/17.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
     
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
    }

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        self.present(imagePicker, animated: true)
    }
    
}

// MARK: - CoreML

extension ViewController {
    
    private func detect(of image: CIImage) {
        
        guard let model = try? VNCoreMLModel(for: Inceptionv3(configuration: .init()).model) else {
            fatalError("Loading CoreML Model Failed")
        }
        
        let request = VNCoreMLRequest(model: model) { [self] request, error in
            guard let results = request.results as? [VNClassificationObservation] else { return }
            
            if let firstResult = results.first { isPerson(firstResult) }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }

    }
    
    private func isPerson(_ result: VNClassificationObservation) {
        if result.identifier.contains("keyboard") {
            self.navigationItem.title = "It's A Keyboard."
        } else {
            self.navigationItem.title = "Not A Keyboard."
        }
    }
    
}

// MARK: - UIImagePickerControllerDelegate

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        imageView.image = pickedImage
        
        guard let ciimage = CIImage(image: pickedImage) else { fatalError("Can't convert to CIImage") }
        detect(of: ciimage)
        
        self.imagePicker.dismiss(animated: true)
        
    }
    
}


