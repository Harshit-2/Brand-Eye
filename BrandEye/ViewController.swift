import UIKit
import CoreML
import Vision
//import Alamofire
//import SwiftyJSON
//import SDWebImage
//import ColorThiefSwift

class ViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var infoLabel: UILabel!
    
    var pickedImage: UIImage?
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
    }

    func detect(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: MyImageClassifier().model) else {
            fatalError("Cannot import model")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let classifications = request.results as? [VNClassificationObservation],
                  let topResult = classifications.first else {
                fatalError("Cannot classify image.")
            }
            
            DispatchQueue.main.async {
                self.navigationItem.title = topResult.identifier.capitalized
                //                self.requestInfo(flowerName: topResult.identifier)
            }
            self.imageView.image = self.pickedImage
            
//            self.infoLabel.text = "It's \(topResult.identifier.capitalized)"
            self.infoLabel.text = ""
            let titleText = "It's \(topResult.identifier.capitalized)"
            var counter = 0.0
            for letter in titleText {
                Timer.scheduledTimer(withTimeInterval: 0.1 * counter, repeats: false) { (timer) in
                    self.infoLabel.text?.append(letter)
                }
                counter += 1
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            imagePicker.dismiss(animated: true, completion: nil)
            
            // Set pickedImage when an image is picked
            pickedImage = image
            
            guard let convertedCIImage = CIImage(image: image) else {
                fatalError("Couldn't convert UIImage to CIImage")
            }
            detect(image: convertedCIImage)
        }
    }

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
}
