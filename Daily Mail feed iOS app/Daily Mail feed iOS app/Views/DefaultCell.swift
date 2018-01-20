//
//  defaultCell.swift
//  Daily Mail feed iOS app
//
//  Created by Johan Fornander on 2018-01-09.
//  Copyright © 2018 Johan Fornander. All rights reserved.
//

import UIKit

protocol DefaultCellDelegate: class {
    func delete(cell: DefaultCell)
}

class DefaultCell: UICollectionViewCell {
    
    @IBOutlet weak var cellContainerView: UIView!
    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var cellDescription: UILabel!
    @IBOutlet weak var cellDate: UILabel!
    @IBOutlet weak var cellIsReadLabel: UILabel!
    @IBOutlet weak var cellDeleteButton: UIButton!
    
    weak var delegate: DefaultCellDelegate?
    
    var item: RSSItem! {
        didSet {
            cellLabel.text = item.title
            cellDescription.text = item.description
            cellDate.text = String(item.date.dropLast(9))
            downloadImage(url: item.thumbnailUrl)
            cellDeleteButton.isHidden = !isEditing
            if(item.isRead){
                cellIsReadLabel.text = "read ✔️"
            }else{
                cellIsReadLabel.text = ""
            }
        }
    }
    
    
    var isEditing:Bool = false{
        didSet {
            cellDeleteButton.isHidden = !isEditing
        }
    }

    
    private func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    
    
    private func downloadImage(url: String) {
        if let url = URL(string: url) {
            getDataFromUrl(url: url) { data, response, error in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async() {
                    self.cellImage.image = UIImage(data: data)
                }
            }
        }
    }
    
    
    @IBAction func cellDeleteButton(_ sender: Any) {
        delegate?.delete(cell: self)
    }
    
    
    
}
