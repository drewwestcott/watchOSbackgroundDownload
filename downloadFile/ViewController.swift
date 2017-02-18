//
//  ViewController.swift
//  downloadFile
//
//  Created by Drew Westcott on 06/02/2017.
//  Copyright © 2017 Drew Westcott. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, URLSessionDownloadDelegate {
	
	var downloadTask: URLSessionDownloadTask!
	var backgroundSession: URLSession!
	
	var audioPlayer = AVAudioPlayer()

	override func viewDidLoad() {
		super.viewDidLoad()

		let backgroundSessionConfiguration = URLSessionConfiguration.background(withIdentifier: "backgroundSession")
		backgroundSession = URLSession(configuration: backgroundSessionConfiguration, delegate: self, delegateQueue: OperationQueue.main)
		
		let url = URL(string: "https://www.drewwestcott.co.uk/Sound/01%20Cot%20Valley.m4a")!
		downloadTask = backgroundSession.downloadTask(with: url)
		downloadTask.resume()
		
		
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
		print("Downloaded")
		let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
		let documentDirectoryPath:String = path[0]
		let fileManager = FileManager()
		let destinationURLForFile = URL(fileURLWithPath: documentDirectoryPath.appendingFormat("/file.m4a"))
		print(destinationURLForFile)
		
		if fileManager.fileExists(atPath: destinationURLForFile.path){
			playFileWithPath(path: destinationURLForFile.path)
		}
		else{
			do {
				try fileManager.moveItem(at: location, to: destinationURLForFile)
				// show file
				playFileWithPath(path: destinationURLForFile.path)
			}catch{
				print("An error occurred while moving file to destination url")
			}
		}

	}
	
	func playFileWithPath(path: String){
		let isFileFound:Bool? = FileManager.default.fileExists(atPath: path)
		if isFileFound == true{
			let podcast = URL(fileURLWithPath: path)
			
			//var podcast = NSURL(fileURLWithPath: Bundle.main.path(forResource: "file", ofType: "m4a")!)

			var error : NSError?
			do {
				audioPlayer = try AVAudioPlayer(contentsOf:  podcast as URL)
				audioPlayer.play()
			} catch {
				print("Error '(error)")
			}
			
//			viewer.delegate = self
//			viewer.presentPreview(animated: true)
		}
	}

}

