//
//  PostListViewController.swift
//  Post
//
//  Created by Haley Jones on 5/13/19.
//  Copyright © 2019 DevMtnStudent. All rights reserved.
//

import UIKit

class PostListViewController: UIViewController {

    
    let postController = PostController()
    var refreshControl = UIRefreshControl()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        postController.fetchPosts() {
            self.reloadTableView()
        }
        tableView.estimatedRowHeight = 45
        tableView.rowHeight = UITableView.automaticDimension

        refreshControl.addTarget(self, action: #selector(refreshControlPulled), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    @objc func refreshControlPulled(){
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        postController.fetchPosts() {
            self.reloadTableView()
        }
        DispatchQueue.main.async {
            self.refreshControl.endRefreshing()
        }
    }
    
    func reloadTableView(){
        DispatchQueue.main.async {
            self.tableView.reloadData()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        presentNewPostAlert()
    }
    
    func presentNewPostAlert(){
        let alertController = UIAlertController(title: "New Post", message: "", preferredStyle: .alert)
        alertController.addTextField { (UITextField) in
            UITextField.placeholder = "Enter Username"
        }
        alertController.addTextField { (newTextField) in
            newTextField.placeholder = "Enter Message"
        }
        let postAction = UIAlertAction(title: "Post", style: .default) { (action) in
            guard let postUsername = alertController.textFields?[0].text, let postBody = alertController.textFields?[1].text else {return}
            if !postUsername.isEmpty && !postBody.isEmpty{
                self.postController.addPostWith(username: postUsername, text: postBody, completion: {
                    DispatchQueue.main.async {
                         self.reloadTableView()
                    }
                })
            } else {
                self.presentErrorAlert()
            }
        }
        alertController.addAction(postAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
        }
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func presentErrorAlert(){
        let errorAlert = UIAlertController(title: "Woah there.", message: "A post must have both a username and a message.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Got it.", style: .cancel) { (_) in
        }
        errorAlert.addAction(okAction)
        present(errorAlert, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension PostListViewController: UITableViewDelegate{
}

extension PostListViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postController.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath)
        cell.textLabel?.text = postController.posts[indexPath.row].text
        cell.detailTextLabel?.text = ("\(postController.posts[indexPath.row].username), \(postController.posts[indexPath.row].timestamp)")
        return cell
    }
    
}
extension PostListViewController{
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row >= postController.posts.count - 1{
            postController.fetchPosts(reset: false, completion: {
                self.reloadTableView()
            })
        }
    }
}
