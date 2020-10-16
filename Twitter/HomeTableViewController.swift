//
//  HomeTableViewController.swift
//  Twitter
//
//  Created by Nashir Janmohamed on 10/9/20.
//  Copyright © 2020 Dan. All rights reserved.
//

import UIKit

class HomeTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var tweetArray = [NSDictionary]()
    @IBOutlet weak var tableView: UITableView!
    var numberOfTweets: Int!
    let myRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Do any additional setup after loading the view.
        numberOfTweets = 20
        loadTweets()
        
        myRefreshControl.addTarget(self, action: #selector(loadTweets), for: .valueChanged)
        tableView.refreshControl = myRefreshControl
        
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    @objc func loadTweets() {
        let url = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        let params: [String : Any] = ["count" : numberOfTweets, "tweet_mode" : "extended"]
        
        TwitterAPICaller.client?.getDictionariesRequest(url: url, parameters: params, success: { (tweets: [NSDictionary]) in
            self.tweetArray.removeAll()
            for tweet in tweets {
                self.tweetArray.append(tweet)
//                print(tweet["full_text"])
            }
            
            self.tableView.reloadData()
            
            self.myRefreshControl.endRefreshing()
        }, failure: { (Error) in
            print("could not retrieve tweets")
        })
    }
    
    func loadMoreTweets() {
        numberOfTweets += 20
        loadTweets()
    }
    
    @IBAction func onLogout(_ sender: Any) {
        TwitterAPICaller.client?.logout()
        // this closes the modal view
        let defaults = UserDefaults.standard
        defaults.set(false, forKey: "isLoggedIn")
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweetArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as! TweetCell
        
        cell.tweetLabel?.text = tweetArray[indexPath.row]["full_text"] as! String
    
        let user = tweetArray[indexPath.row]["user"] as! [String:Any]
        
        cell.nameLabel?.text = user["name"] as! String
        cell.usernameLabel?.text = "@\(user["screen_name"] as! String)"
        
        let imageUrl = URL(string: (user["profile_image_url_https"] as! String))
        let data = try? Data(contentsOf: imageUrl!)
        
        if let imageData = data {
            cell.profileImageView.image = UIImage(data: imageData)
            let img = cell.profileImageView as! UIImageView
            img.layer.borderWidth = 1
            img.layer.masksToBounds = false
            img.layer.borderColor = UIColor.white.cgColor
            img.layer.cornerRadius = img.frame.height / 2
            img.clipsToBounds = true
        }
        
        let origDate = tweetArray[indexPath.row]["created_at"] as! String
        print("origDate: \(origDate)")
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "eee MMM dd HH:mm:ss ZZZZ yyyy"
        
        var timeSinceTweetFormatted: String = ""
        if let date = dateFormatter.date(from: origDate) {
            print("date: \(date)")
            let timeSinceTweet = -date.timeIntervalSinceNow
            print("timeSinceTweet: \(timeSinceTweet)")
            if timeSinceTweet < 60 { // seconds
                timeSinceTweetFormatted = "\(timeSinceTweet)s"
            } else if timeSinceTweet < 3600 { // minutes
                timeSinceTweetFormatted = "\(Int((timeSinceTweet / 60).rounded(.down)))m"
            } else if timeSinceTweet < 86400 { // hours
                timeSinceTweetFormatted = "\(Int((timeSinceTweet / 3600).rounded(.down)))h"
            } else if timeSinceTweet < 604800 { // days
                timeSinceTweetFormatted = "\(Int((timeSinceTweet / 86400).rounded(.down)))d"
            } else { // short date format: 10/12/20
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                timeSinceTweetFormatted = dateFormatter.string(from: date)
            }
        } else {
            print("failed to parse")
        }
        
        print("time right now: \(Date())")

        cell.dateLabel?.text = "• \(timeSinceTweetFormatted)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == tweetArray.count {
            loadMoreTweets()
        }
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
