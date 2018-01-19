//
//  WebView.swift
//  Daily Mail feed iOS app
//
//  Created by Johan Fornander on 2018-01-12.
//  Copyright © 2018 Johan Fornander. All rights reserved.
//

import UIKit
import WebKit

class WebView: UIViewController, UITextFieldDelegate, WKNavigationDelegate {

    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var urlTextField: UITextField!
    
    var urlObject:String?
    var urlString:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        urlTextField.delegate = self
        webView.navigationDelegate = self

        if(urlObject != nil) {
            urlString = urlObject
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let urlString: String = self.urlString!
        let url: URL = URL(string: urlString)!
        let urlRequest: URLRequest = URLRequest(url: url)
        webView.load(urlRequest)
        urlTextField.text = urlString
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let urlString: String = urlTextField.text!
        
        if(isvalidURL(string: urlString)){
            print("valid")
            let url: URL = URL(string: urlString)!
            let urlRequest: URLRequest = URLRequest(url: url)
            webView.load(urlRequest)
            textField.resignFirstResponder()
            return true
        }
        
        
        let alert = UIAlertController(title: "Error", message: "Invalid input URL", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        return false
    }
    
    
    func isvalidURL (string: String?) -> Bool {
        if string != nil{
            if let url = NSURL(string: string!){
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
    
    
    
    @IBAction func backButtonTapped(_ sender: Any) {
        if(webView.canGoBack) {
            webView.goBack()
        }
    }
    
    
    @IBAction func forwardButtonTapped(_ sender: Any) {
        if(webView.canGoForward) {
            webView.goForward()
        }
    }
    
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        backButton.isEnabled = webView.canGoBack
        forwardButton.isEnabled = webView.canGoForward
        urlTextField.text = webView.url?.absoluteString
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

}
