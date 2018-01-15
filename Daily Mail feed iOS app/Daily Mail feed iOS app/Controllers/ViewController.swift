//
//  ViewController.swift
//  Daily Mail feed iOS app
//
//  Created by Johan Fornander on 2018-01-09.
//  Copyright © 2018 Johan Fornander. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private var rssItems:[RSSItem]?
    private var currentRssItems:[RSSItem]?
    private var url:String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = editButtonItem
        initCollectionViewLayout()
        fetchData()
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        self.collectionView.reloadData()
    }
    
    
    private func fetchData(){
        let feedParser = FeedParser()
        feedParser.parseFeed(url: "http://www.dailymail.co.uk/sport/index.rss") { (rssItems) in
            self.rssItems = rssItems
            self.currentRssItems = rssItems
            OperationQueue.main.addOperation {
                self.collectionView.reloadSections(IndexSet(integer: 0))
            }
        }
    }
    
    
    func initCollectionViewLayout(){
        let screenWidth = UIScreen.main.bounds.width
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        layout.itemSize = CGSize(width: screenWidth, height: 100)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 3
        collectionView.collectionViewLayout = layout
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let currentRssItems = currentRssItems else {
            return 0
        }
        return currentRssItems.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "defaultCell", for: indexPath) as! DefaultCell
        if let item = currentRssItems?[indexPath.item] {
            
            let textColor:UIColor = UIColor (red:0.22, green:0.33, blue:0.53, alpha:1.0)
            
            cell.item = item
            cell.cellContainerView.layer.borderWidth = 1
            
            //cell.cellContainerView.layer.borderColor = UIColor.blue.cgColor
            cell.cellContainerView.layer.borderColor = textColor.cgColor
            cell.cellContainerView.layer.cornerRadius = 5
            
            cell.cellDescription.textColor = textColor
            cell.cellDate.textColor = textColor
            cell.cellIsReadLabel.textColor = textColor
            
            
            cell.cellImage.layer.masksToBounds = true
            cell.cellImage.layer.cornerRadius = 10
            cell.cellDeleteButton.layer.masksToBounds = true
            cell.cellDeleteButton.layer.cornerRadius = 20
            cell.delegate = self
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let item = currentRssItems?[indexPath.item] {
            self.url = item.link
            rssItems?[indexPath.item].isRead = true
            currentRssItems?[indexPath.item].isRead = true
        }
        performSegue(withIdentifier: "webview", sender: self)
    }
    
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if let indexPaths = collectionView?.indexPathsForVisibleItems {
            for indexPaths in indexPaths {
                if let cell = collectionView?.cellForItem(at: indexPaths) as? DefaultCell {
                    cell.isEditing = editing
                }
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "webview") {
            if let webView = segue.destination as? WebView {
                webView.urlObject = self.url
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 250)
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            currentRssItems = rssItems
            self.collectionView.reloadData()
            return
        }
        currentRssItems = rssItems?.filter({ RSSItem -> Bool in
            RSSItem.title.lowercased().contains(searchText.lowercased())})
        self.collectionView.reloadData()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}



extension ViewController: DefaultCellDelegate {
    
    func delete(cell: DefaultCell) {
        if let indexPath = collectionView?.indexPath(for: cell) {
            self.currentRssItems?.remove(at: indexPath.item)
            self.rssItems?.remove(at: indexPath.item)
            collectionView?.deleteItems(at: [indexPath])
        }
    }
}

