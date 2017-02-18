//
//  InterfaceController.swift
//  downloadFile WatchKit Extension
//
//  Created by Drew Westcott on 06/02/2017.
//  Copyright © 2017 Drew Westcott. All rights reserved.
//

import WatchKit

class InterfaceController: WKInterfaceController, WKExtensionDelegate, URLSessionDownloadDelegate {
	
	// MARK: Properties For Download Test
	var downloadTask : URLSessionDownloadTask!
	var backgroundSession: URLSession!
	var requestDownload = false
	

	let sampleURL = URL(string: "https://www.drewwestcott.co.uk/wp-content/themes/lab-responsive-bootstrap-child/images/curtains1.png")!

	// MARK: Properties For Download Test
	var player: WKAudioFilePlayer!
	@IBOutlet weak var audioLabel: WKInterfaceLabel!
	@IBOutlet var podcastButton: WKInterfaceButton!
	
	override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
		WKExtension.shared().delegate = self
		podcastButton.setTitle("99 Percent Invisible")
		if requestDownload == false {
			downloadPodcast()
			requestDownload = true
		}
	}
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
		
		scheduleBackgroundRefresh()
    }
	
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
		audioLabel.setText("...")
    }

	func downloadPodcast() {
		let backgroundConfigObject = URLSessionConfiguration.background(withIdentifier: "uk.co.drewwestcott.cotvalley")
		let cachesDirectoryURL = try! FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		//let cacheURL = cacheDirectoryURL.append
		backgroundConfigObject.sessionSendsLaunchEvents = true
		let backgroundSession = URLSession(configuration: backgroundConfigObject)
		
		let downloadTask = backgroundSession.downloadTask(with: sampleURL)
		downloadTask.resume()
	}
	
	@IBAction func playFile() {
		playPodcast()

	}

	
	func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
		print("File Downloaded")
//		self.urlSessionTask.setTaskCompleted()

	}
	
	func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
		print("Data written \(totalBytesWritten) bytes")
	}
	// MARK: Podcast Player functions

	func playPodcast() {
		
		let filePath = Bundle.main.path(forResource: "246-Usonia", ofType: "mp3")!
		let fileURL = NSURL.fileURL(withPath: filePath)
		let asset = WKAudioFileAsset(url: fileURL)
		let playerItem = WKAudioFilePlayerItem(asset: asset)
		
		let player = WKAudioFilePlayer(playerItem: playerItem)
			audioLabel.setText("Playing")
			player.play()
	}
	
	func scheduleBackgroundRefresh() {
		
		let fireDate = Date(timeIntervalSinceNow: 120)
		// optional, any SecureCoding compliant data can be passed here
		let userInfo = ["reason" : "background update"] as NSDictionary
		
		WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: fireDate, userInfo: userInfo) { (error) in
			if (error == nil) {
				print("successfully scheduled background task, use the crown to send the app to the background and wait for handle:BackgroundTasks to fire.")
			}
		}

	}
	
	func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
		// Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
		for task in backgroundTasks {
			// Use a switch statement to check the task type
			
			if let urlTask = task as? WKURLSessionRefreshBackgroundTask {
			let backgroundConfigObject = URLSessionConfiguration.backgroundSessionConfiguration(urlTask.sessionIdentifier)
			let backgroundSession = URLSession(configuration: backgroundConfigObject,
			                                   delegate: self,
			                                   delegateQueue: nil)
			// receive data via URLSessionDownloadDelegate
			pendingBackgroundTasks.append(task)
		} else {
			task.setTaskCompleted()   // make sure to complete all tasks
		}
		
			switch task {
			case let backgroundTask as WKApplicationRefreshBackgroundTask:
				// Be sure to complete the background task once you’re done.
				
				if (WKExtension.shared().applicationState == .background) {
					if task is WKApplicationRefreshBackgroundTask {
						print("application task received, starting URL session")
//						downloadPodcast()
					}
				}
				
				//backgroundTask.setTaskCompleted()
			case let snapshotTask as WKSnapshotRefreshBackgroundTask:
				// Snapshot tasks have a unique completion call, make sure to set your expiration date
				snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
			case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
				// Be sure to complete the connectivity task once you’re done.
				connectivityTask.setTaskCompleted()
			case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
				// Be sure to complete the URL session task once you’re done.
					let backgroundConfigObject = URLSessionConfiguration.background(withIdentifier: urlSessionTask.sessionIdentifier)
					let backgroundSession = URLSession(configuration: backgroundConfigObject, delegate: self, delegateQueue: nil)
				print("Session continuing")
			default:
				// make sure to complete unhandled task types
				task.setTaskCompleted()
			}
		}
	}

}
