//
//  FeedViewController.swift
//  Instagram
//
//  Created by Brian Velecela on 3/10/22.
//

import UIKit
import Parse
import AlamofireImage //dealing with images
import MessageInputBar //dealing with messages

//STEP 1: ADD UITableViewDelegate, UITableViewDataSource
class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    let commentBar = MessageInputBar() //create an instinct
    var showsCommentBar = false
    var selectedPost: PFObject!  // this var will remember the post, (optional)
    var posts = [PFObject]()  // creating an empty array
    let myRefreshControl = UIRefreshControl()
    var numberOfPosts: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //STEP 2: INCLUDE delegate = self AND .dataSource = self
        tableView.delegate = self
        tableView.dataSource = self
        
        commentBar.inputTextView.placeholder = "Add a comment..."
        commentBar.sendButton.title = "Post"
        commentBar.delegate = self
        
        tableView.keyboardDismissMode = .interactive //dismiss the keyboard by swiping down
        
        //keyboard to be hidden
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        myRefreshControl.addTarget(self, action: #selector(loadPosts), for: .valueChanged)
        tableView.refreshControl = myRefreshControl
    }
    @objc func keyboardWillBeHidden(note: Notification){
        //this will be called when the keyboard is hidden
        //do the oppsite
        commentBar.inputTextView.text = nil  //every time it gets dismissed, clear the text
        showsCommentBar = false
        becomeFirstResponder()
    }
    
    //these two are hacking the framework
    override var inputAccessoryView: UIView?{
        return commentBar
    }
    //you dont want the message bar to show by default ->
    override var canBecomeFirstResponder: Bool{
        return showsCommentBar      //so create a varable and setting it to false
    }
    
    //after you click post to post photo, you want it to appear back to the home page
    //it pull in the photo you just created
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        loadPosts()
    }
    
    //pull to refresh
    @objc func loadPosts(){
        numberOfPosts = 5
        myRefreshControl.beginRefreshing()
        
        //construct PFQuery
        let query = PFQuery(className: "Posts")
        query.order(byDescending: "createdAt")
        query.includeKeys(["Author", "comments","comments.Author"]) // we grabbing comment and the author of the comment
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
    
    //button action
    @IBAction func onLogoutButton(_ sender: Any) {
        PFUser.logOut();  //logout action
        
        //switch user to go back to the login screen
        let main = UIStoryboard(name:"Main", bundle: nil)
        let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
        
        //we need to access the window
        //Q: how do we access the window from this file?
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let
                delegate = windowScene.delegate as? SceneDelegate else {return}
        
        delegate.window?.rootViewController = loginViewController
    }
    

    //infinite scroll
    func loadMorePosts(){
        numberOfPosts = numberOfPosts + 10
        
        //construct PFQuery
        let query = PFQuery(className: "Posts")
        query.order(byDescending: "createdAt")
        query.includeKeys(["Author", "comments","comments.Author"])
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
    
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        //create the comment
        //including what a comment should have:
        let comment = PFObject(className:"comments")
        comment["text"] = text
        comment["post"] = selectedPost           // you want the comment to know which post it is
        comment["Author"] = PFUser.current()!           // you want to know who made the comment
        
        // this is saying, that every post should have an array called comments, to add this comment to the array.
        selectedPost.add(comment, forKey: "comments")
        
        selectedPost.saveInBackground{(success, error) in
            if success{
                print("Comment saved")
            }else{
                print("Error saving comment")
            }
        }
        tableView.reloadData()
        
        //clear and dismiss the input bar
        commentBar.inputTextView.text = nil
        
        showsCommentBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
    }
    
    
    //also part of infinite scroll
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == posts.count{
            loadMorePosts()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let post = posts[section]
        let comments = (post["comments"] as? [PFObject]) ?? []  //?? default values
        
        return comments.count + 2  // adding 2 will display both table view cells
    }
  
    //STEP 4: ADD numberOfRowsInSection AND cellForRowAt
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let me grab the post
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        if indexPath.row == 0 {  // that the post
            let cell = tableView.dequeueReusableCell(withIdentifier: "postCell") as! postCell  //recycle cells
            
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
            
        }else if indexPath.row <= comments.count{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            let comment = comments[indexPath.row - 1]  //This will bring you the first comment
            cell.commentLabel.text = comment["text"] as? String
            
            let user  = comment["Author"] as! PFUser
            cell.nameLabel.text = user.username
        
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
            return cell
        }
    }
    
    //this action
    //viewer can view comments on a post
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //this the row you selected
        // indexPath.row will tell you the which pic was selected
        let post = posts[indexPath.section]
        //we are creating a new col to our parse called comments
        let comments = (post["comments"] as? [PFObject]) ?? []  //?? in case its nil
        
        //for the last cell
        if indexPath.row == comments.count + 1{
            //show the ccomment bar
            showsCommentBar = true
            //keyboard to show up
            becomeFirstResponder()
            commentBar.inputTextView.becomeFirstResponder()
            
            //remember this for later
            selectedPost = post
        }
        
    }
}
