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
    let myRefreshControl = UIRefreshControl()
    var numberOfPosts: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //STEP 2: INCLUDE delegate = self AND .dataSource = self
        tableView.delegate = self
        tableView.dataSource = self
        
        myRefreshControl.addTarget(self, action: #selector(loadPosts), for: .valueChanged)
        tableView.refreshControl = myRefreshControl
    }
    
    //after you click post to post photo, you want it to appear back to the home page
    //it pull in the photo you just created
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        /*
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
        */
        loadPosts()
    }
    
    //pull to refresh
    @objc func loadPosts(){
        numberOfPosts = 5
        myRefreshControl.beginRefreshing()
        
        //construct PFQuery
        let query = PFQuery(className: "Posts")
        query.order(byDescending: "createdAt")
        query.includeKey("Author")
        query.limit = numberOfPosts
        
        //data fetch
        query.findObjectsInBackground { (objects, error) in
            if error != nil {
                print("Error:\(error!.localizedDescription)")
            } else {
                self.posts = objects!
                self.tableView.reloadData()
            }
            self.myRefreshControl.endRefreshing()
        }
    }
    
    //infinite scroll
    func loadMorePosts(){
        numberOfPosts = numberOfPosts + 2
        
        //construct PFQuery
        let query = PFQuery(className: "Posts")
        query.order(byDescending: "createdAt")
        query.includeKey("Author")
        query.limit = numberOfPosts
        
        //data fetch
        query.findObjectsInBackground { (objects, error) in
            if error != nil {
                print("Error:\(error!.localizedDescription)")
            } else {
                self.posts = objects!
                self.tableView.reloadData()
                print("loadMprePost was called")
            }
        }
    }
    
    //also part of infinite scroll
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == posts.count{
            loadMorePosts()
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
