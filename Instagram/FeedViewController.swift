//
//  FeedViewController.swift
//  Instagram
//
//  Created by Brian Velecela on 3/10/22.
//

import UIKit
import Parse
import AlamofireImage //dealing with images

//STEP 1: ADD UITableViewDelegate, UITableViewDataSource
class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var posts = [PFObject]()  // creating an empty array
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //STEP 2: INCLUDE delegate = self AND .dataSource = self
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    //after you click post to post photo, you want it to appear back to the home page
    //it pull in the photo you just created
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        //fetch the photo
        let query = PFQuery(className:"Posts")
        query.includeKey("Author") //to fetch the actually object
        query.limit = 20 //getting the last 20
        
        //apond getting the photo back
        query.findObjectsInBackground{ (posts, erro) in
            if posts != nil{
                self.posts = posts! //put the photo inside the array
                self.tableView.reloadData()   //calling tableView to reload itself
            }
            
        }
    }
    
    
    
    //STEP 4: ADD numberOfRowsInSection AND cellForRowAt
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell") as! postCell  //recycle cells
        
        //let me grab the post
        let post = posts[indexPath.row]
        
        //configure the three outlets
        let user = post["Author"] as! PFUser
        cell.usernameLabel.text = user.username
        
        cell.captionLabel.text = post["Caption"] as? String
        
        //covert iamge to URL
        let imageFile = post["image"] as! PFFileObject
        let urlString = imageFile.url!
        let url = URL(string: urlString)!
        
        //getting the photo
        cell.photoVIew.af.setImage(withURL: url)
        
        return cell
    }
}
