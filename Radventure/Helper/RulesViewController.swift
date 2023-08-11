//
//  RulesViewController.swift
//  Radventure
//
//  Created by Can Duru on 18.07.2023.
//

//MARK: Import
import UIKit
import WebKit

class RulesViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {

    //MARK: Load
    override func viewDidLoad() {
        super.viewDidLoad()

        //MARK: Webview Set Up
        let webView = WKWebView()
        webView.navigationDelegate = self
        webView.configuration.defaultWebpagePreferences.allowsContentJavaScript = false
        view = webView
        
        //MARK: Back Button Set Up
        let backButton = UIButton()
        backButton.setImage(UIImage(systemName: "arrow.backward")?.withTintColor(UIColor(named: "AppColor1")!, renderingMode: .alwaysOriginal), for: .normal)
        backButton.addTarget(self, action: #selector(self_dismiss), for: .touchUpInside)
        view.addSubview(backButton)
        backButton.contentHorizontalAlignment = .fill
        backButton.contentVerticalAlignment = .fill
        backButton.imageView?.contentMode = .scaleAspectFit
        self.view.bringSubviewToFront(backButton)

        backButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16), backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 13), backButton.widthAnchor.constraint(equalToConstant: 30), backButton.heightAnchor.constraint(equalToConstant: 30)])

        //MARK: Web URL
        let url = URL(string: "https://docs.google.com/document/d/1pNwQQqcL7sAD2mAfxr_RS5bu8v8Z-XjZO7gKOHArUCI/edit?usp=sharing")!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = false
    }
    
    
    
    //MARK: Back Button Action
    @objc func self_dismiss(){
        self.dismiss(animated: true)
    }
}
