//
//  CameraViewController.swift
//  Instagram
//
//  Created by Brian Velecela on 3/10/22.
//

import UIKit
import AlamofireImage  //to resize image
import Parse  //how to create object into a table


                        //UIImagePickerControllerDelegate & UINavigationControllerDelegate will give you the camera events
class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //outlets
    @IBOutlet weak var commentField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //submit button action
    @IBAction func onSubmit(_ sender: Any) {
        let post = PFObject(className: "Posts")
        
        //creating columns
        post["Caption"] = commentField.text
        post["Author"] = PFUser.current()!
        
        //binary objects
        //image are saved as url
        //saved in a separate tabel for photo
        let imageData = imageView.image!.pngData()//image saved as png!
        //let file = PFFileObject(data: imageData!)
        let file = PFFileObject(name: "image.png", data: imageData!)
        
        post["image"] = file  //this column will have the url for this
        
        //save every object
        post.saveInBackground{ (success, error) in
            if success{
                self.dismiss(animated: true, completion: nil)
                print ("saved!")
            }else {
                print ("error")
            }
        }
    }
    
    //Opening camera action
    @IBAction func onCameraButton(_ sender: Any) {
        let picker = UIImagePickerController()
        //Creating the controller
        //the easy way: BUT THIS IS NOT CONFIGURABLE
        //when the user is done taking a photo, let me know what they took. So call me back on a function that has a photo
        picker.delegate = self
        //allow them to twick the photo before making it done
        picker.allowsEditing = true
        
        //we will check if camera is available to be used
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            picker.sourceType = .camera
        }else{
            picker.sourceType = .photoLibrary
        }
        present(picker, animated: true, completion: nil)  //show case the output
    }
    
    //display the image in the imageView
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[.editedImage] as! UIImage // inside of a dict called info
        //Resize the image
        let size = CGSize(width: 300, height: 300)
        let scaledImage = image.af.imageAspectScaled(toFit: size)
        
        //storing the scaledImage to the imageView
        imageView.image = scaledImage
        //dismiss the camera
        dismiss(animated: true , completion: nil)
    }
    
}
