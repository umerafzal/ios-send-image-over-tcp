//
//  ImageDownloader.swift
//  Afiniti Code Challenge
//
//  Created by Umer on 10/05/2021.
//

import Foundation
import UIKit

typealias ImageDownloadProgress = (Float) -> Void
typealias ImageDownloadCompletion = (UIImage?, ImageDownloadTask?) -> Void

class ImageDownloader: NSObject {
    private let queue = DispatchQueue(label: "com.afiniti.code.challenege", attributes: .concurrent)
    private var session: URLSession! = nil
    private var array: [ImageDownloadTask] = []
    // singleton
    static let shared = ImageDownloader()
    
    private override init() {
        super.init()
        session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
    }
    
    func downloadImage(url: URL, progress: @escaping ImageDownloadProgress, completion: @escaping ImageDownloadCompletion) {
        queue.async {
        let task = ImageDownloadTask(url: url,
                                     session: self.session,
                                     progress: progress,
                                     completion: completion)
            task.start()
            self.queue.async(flags: .barrier) {  self.array.append(task) }
        }
    }
}

extension ImageDownloader: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let currentTask = self.array.filter{ $0.identifier == downloadTask.taskIdentifier }.first
        currentTask?.diskLocation = location
        
        if let data = try? Data(contentsOf: location),
           let image = UIImage(data: data) {
            currentTask?.completion(image, currentTask)
        }
        
        self.array.removeAll {  $0.identifier == currentTask?.identifier    }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        print("\(downloadTask.taskIdentifier) : \(totalBytesExpectedToWrite)")
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        let currentTask = self.array.filter{ $0.identifier == downloadTask.taskIdentifier }.first
        currentTask?.progress(progress)
    }
}
