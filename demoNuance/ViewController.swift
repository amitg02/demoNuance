//
//  ViewController.swift
//  demoNuance
//
//  Created by Atal Bansal on 11/07/16.
//  Copyright © 2016 Atal Bansal. All rights reserved.
//

import UIKit
import SpeechKit

class ViewController: UIViewController ,SKTransactionDelegate {
	
	// State Logic: IDLE -> LISTENING -> PROCESSING -> repeat
	enum SKSState {
		case SKSIdle
		case SKSListening
		case SKSProcessing
	}
	
	// User interface
	@IBOutlet weak var matchButton: UIButton?
	@IBOutlet weak var toggleRecogButton: UIButton?
	@IBOutlet weak var logTextView: UITextView?
	@IBOutlet weak var clearLogsButton: UIButton?
	@IBOutlet weak var recognitionTypeSegmentControl: UISegmentedControl?
	@IBOutlet weak var endpointerTypeSegmentControl: UISegmentedControl?
	@IBOutlet weak var volumeLevelProgressView: UIProgressView?
	@IBOutlet weak var languageTextView: UITextField?
	
	// Settings
	var language: String!
	var recognitionType: String!
	var endpointer: SKTransactionEndOfSpeechDetection!
	
	var skSession:SKSession?
	var skTransaction:SKTransaction?
	
	var state = SKSState.SKSIdle
	
	var volumePollTimer: NSTimer?
	
	var lastSearchText: String!
	var callFromMatching: Bool = false
	override func viewDidLoad() {
		super.viewDidLoad()
		initalSetUp()
		// Do any additional setup after loading the view, typically from a nib.
	}
	func initalSetUp(){
		recognitionType = SKTransactionSpeechTypeDictation
		endpointer = .Short
		language = LANGUAGE
		self.languageTextView!.text = language
		
		state = .SKSIdle
		skTransaction = nil
		
		// Create a session
		print(SKSServerUrl)
		print(SKSAppKey)
		skSession = SKSession(URL: NSURL(string: SKSServerUrl), appToken: SKSAppKey)
		
		if (skSession == nil) {
			let alertView = UIAlertController(title: "SpeechKit", message: "Failed to initialize SpeechKit session.", preferredStyle: .Alert)
			let defaultAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
			alertView.addAction(defaultAction)
			presentViewController(alertView, animated: true, completion: nil)
			return
		}
		
		loadEarcons()

	}
	func textFieldDidEndEditing(textField: UITextField) {
		textField.resignFirstResponder()
	}
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
	
	// MARK: - ASR Actions
	@IBAction func toggleRecognition() {
		callFromMatching = false
		switch state {
		case .SKSIdle:
			recognize()
		case .SKSListening:
			stopRecording()
		case .SKSProcessing:
			cancel()
		}
	}
	
	func recognize() {
		// Start listening to the user.
		toggleRecogButton?.setTitle("Stop", forState: .Normal)
		skTransaction = skSession!.recognizeWithType(recognitionType,
		                                             detection: endpointer,
		                                             language: language,
		                                             delegate: self)
	}
	func recognizeMatch() {
		// Start listening to the user.
		matchButton?.setTitle("Stop", forState: .Normal)
		skTransaction = skSession!.recognizeWithType(recognitionType,
		                                             detection: endpointer,
		                                             language: language,
		                                             delegate: self)
	}
	
	func stopRecording() {
		// Stop recording the user.
		skTransaction!.stopRecording()
		
		// Disable the button until we received notification that the transaction is completed.
		toggleRecogButton?.enabled = false
		matchButton?.enabled = false
	}
	
	func cancel() {
		// Cancel the Reco transaction.
		// This will only cancel if we have not received a response from the server yet.
		skTransaction!.cancel()
	}
	
	// MARK: - SKTransactionDelegate
	
	func transactionDidBeginRecording(transaction: SKTransaction!) {
		log("transactionDidBeginRecording")
		
		state = .SKSListening
		startPollingVolume()
		toggleRecogButton?.setTitle("Listening..", forState: .Normal)
	}
	
	func transactionDidFinishRecording(transaction: SKTransaction!) {
		log("transactionDidFinishRecording")
		
		state = .SKSProcessing
		stopPollingVolume()
		toggleRecogButton?.setTitle("Processing..", forState: .Normal)
	}
	
	func transaction(transaction: SKTransaction!, didReceiveRecognition recognition: SKRecognition!) {
		log(String(format: "didReceiveRecognition: %@", arguments: [recognition.text]))
		
		lastRecogniation = recognition
		
		if recognition.text == "Google"  && !callFromMatching {
			let openNewVC = self.storyboard?.instantiateViewControllerWithIdentifier("WebViewVC") as! WebViewVC
			openNewVC.searchText = recognition.text
			lastSearchText = recognition.text
			self.navigationController?.pushViewController(openNewVC, animated: true)
		}
		if callFromMatching {
			log(String(format: "Match Responcse: %@", matchVoiceOrNot(recognition)))
		}
		
		state = .SKSIdle
	}
	
	func transaction(transaction: SKTransaction!, didReceiveServiceResponse response: [NSObject : AnyObject]!) {
		log(String(format: "didReceiveServiceResponse: %@", arguments: [response]))
	
	}
	
	func transaction(transaction: SKTransaction!, didFinishWithSuggestion suggestion: String) {
		log("didFinishWithSuggestion")
		
		state = .SKSIdle
		resetTransaction()
//		if lastSearchText == "Google" {
//			initalSetUp()
//		}
	}
	
	func transaction(transaction: SKTransaction!, didFailWithError error: NSError!, suggestion: String) {
		log(String(format: "didFailWithError: %@. %@", arguments: [error.description, suggestion]))
		
		// Something went wrong. Ensure that your credentials are correct.
		// The user could also be offline, so be sure to handle this case appropriately.
		
		state = .SKSIdle
		resetTransaction()
	}
	
	// MARK: - Other Actions
	
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		let touch = event?.allTouches()?.first
		if (languageTextView!.isFirstResponder() && touch!.view != languageTextView) {
			languageTextView!.resignFirstResponder()
		}
		super.touchesBegan(touches, withEvent: event)
	}
	
	@IBAction func selectRecognitionType(sender: UISegmentedControl) {
		let index = sender.selectedSegmentIndex
		if(index == 0){
			recognitionType = SKTransactionSpeechTypeDictation
		} else if (index == 1){
			recognitionType = SKTransactionSpeechTypeSearch
		} else if (index == 2){
			recognitionType = SKTransactionSpeechTypeTV
		}
	}
	
	@IBAction func selectEndpointerType(sender: UISegmentedControl) {
		let index = sender.selectedSegmentIndex
		if(index == 0){
			endpointer! = .Long
		} else if (index == 1){
			endpointer! = .Short
		} else if (index == 2){
			endpointer! = .None
		}
	}
	
	@IBAction func useLanguage(sender: UITextField) {
		language = sender.text
	}
	
	@IBAction func clearLogs(sender: UIButton) {
		logTextView!.text = ""
	}
	@IBAction func matchVoice(sender: UIButton) {
		callFromMatching = true
		switch state {
		case .SKSIdle:
			recognizeMatch()
		case .SKSListening:
			stopRecording()
		case .SKSProcessing:
			cancel()
		}
	}
	func matchVoiceOrNot(recong:SKRecognition)->Bool {
		
			if 	recong == lastRecogniation {
			return true
		} else{
			return false
		}
		
	}
	// MARK: - Volume level
	
	func startPollingVolume() {
		// Every 50 milliseconds we should update the volume meter in our UI.
		volumePollTimer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(ViewController.pollVolume), userInfo: nil, repeats: true)
	}
	
	func pollVolume() {
		let volumeLevel = skTransaction!.audioLevel
		volumeLevelProgressView!.setProgress(volumeLevel / Float(100), animated: true)
	}
	
	func stopPollingVolume() {
		volumePollTimer!.invalidate()
		volumePollTimer = nil
		volumeLevelProgressView!.setProgress(Float(0), animated: true)
	}
	
	//MARK - Helpers
	
	func log(message: String) {
		logTextView!.text = logTextView!.text.stringByAppendingFormat("%@\n", message)
	}
	
	func resetTransaction() {
		NSOperationQueue.mainQueue().addOperationWithBlock({
			self.skTransaction = nil
			self.toggleRecogButton?.setTitle("recognizeWithType", forState: .Normal)
			self.toggleRecogButton?.enabled = true
			self.matchButton?.setTitle("match", forState: .Normal)
			self.matchButton?.enabled = true
		})
	}
	
	func loadEarcons() {
		let startEarconPath = NSBundle.mainBundle().pathForResource("sk_start", ofType: "pcm")
		let stopEarconPath = NSBundle.mainBundle().pathForResource("sk_stop", ofType: "pcm")
		let errorEarconPath = NSBundle.mainBundle().pathForResource("sk_error", ofType: "pcm")
		let audioFormat = SKPCMFormat()
		audioFormat.sampleFormat = .SignedLinear16
		audioFormat.sampleRate = 16000
		audioFormat.channels = 1
		
		skSession!.startEarcon = SKAudioFile(URL: NSURL(fileURLWithPath: startEarconPath!), pcmFormat: audioFormat)
		skSession!.endEarcon = SKAudioFile(URL: NSURL(fileURLWithPath: stopEarconPath!), pcmFormat: audioFormat)
		skSession!.errorEarcon = SKAudioFile(URL: NSURL(fileURLWithPath: errorEarconPath!), pcmFormat: audioFormat)
	}
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

