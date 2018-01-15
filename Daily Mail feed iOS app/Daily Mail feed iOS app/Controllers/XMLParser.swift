//
//  XMLParser.swift
//  Daily Mail feed iOS app
//
//  Created by Johan Fornander on 2018-01-10.
//  Copyright © 2018 Johan Fornander. All rights reserved.
//

import Foundation

struct RSSItem {
    var title: String
    var description: String
    var thumbnailUrl: String
    var date: String
    var link: String
    var isRead: Bool
}


class FeedParser: NSObject, XMLParserDelegate{
    private var rssItem: [RSSItem] = []
    private var currentElement = ""
    private var parserCompletionHandler: (([RSSItem]) -> Void)?
    
    private var currentTitle: String = "" {
        didSet {
            currentTitle = currentTitle.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    
    private var currentDescription: String = "" {
        didSet {
            currentDescription = currentDescription.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    
    private var currentThumbnailUrl: String = "" {
        didSet {
            currentThumbnailUrl = currentThumbnailUrl.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    
    private var currentDate: String = "" {
        didSet {
            currentDate = currentDate.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    
    private var currentLink: String = "" {
        didSet {
            currentLink = currentLink.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    
    private var currentIsReadBool: Bool = false
    
    
    func parseFeed(url: String, completionHandler: (([RSSItem]) -> Void)?){
        self.parserCompletionHandler = completionHandler
        let request = URLRequest(url: URL(string: url)!)
        let urlSession = URLSession.shared
        let task = urlSession.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                if let error = error {
                    print(error)
                }
                return
            }
            let parser = XMLParser(data: data)
            parser.delegate = self
            parser.parse()
        }
        task.resume()
    }
    
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        if currentElement == "item" {
            currentTitle = ""
            currentDescription = ""
            currentThumbnailUrl = ""
            currentDate = ""
            currentLink = ""
            currentIsReadBool = false
        }
        if(currentElement == "enclosure"){
            if let urlString = attributeDict["url"] {
                currentThumbnailUrl += urlString
            } else {
                print("error parsing thumbnailUrl")
            }
        }
    }
    
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        switch currentElement {
            case "title": currentTitle += string
            case "description": currentDescription += string
            case "pubDate": currentDate += string
            case "link": currentLink += string
        default:
            break
        }
    }
    
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            let rssItem = RSSItem(title: currentTitle, description: currentDescription, thumbnailUrl: currentThumbnailUrl, date: currentDate, link: currentLink, isRead: currentIsReadBool)
            self.rssItem.append(rssItem)
        }
    }
    
    
    func parserDidEndDocument(_ parser: XMLParser) {
        parserCompletionHandler?(rssItem)
    }
    
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print(parseError.localizedDescription)
    }
    
    
    
}
