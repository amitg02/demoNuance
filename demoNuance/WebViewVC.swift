//
//  WebViewVC.swift
//  demoNuance
//
//  Created by Atal Bansal on 11/07/16.
//  Copyright © 2016 Atal Bansal. All rights reserved.
//

import UIKit

class WebViewVC: UIViewController {

	@IBOutlet var webView: UIWebView!
	var searchText:String = String()
	override func viewDidLoad() {
        super.viewDidLoad()
		loadWebView(searchText)
        // Do any additional setup after loading the view.
    }
	func loadWebView(text:String){
		super.viewDidLoad()
		let url = NSURL(string: "http://google.com/search?q=\(text)")
		let request = NSURLRequest(URL: url!)
		webView.loadRequest(request)

	}
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
