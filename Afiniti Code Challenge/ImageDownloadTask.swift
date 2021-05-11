//
//  ImageDownloadTask.swift
//  Afiniti Code Challenge
//
//  Created by Umer on 10/05/2021.
//

import Foundation

class ImageDownloadTask {
    let url: URL
    let progress: ImageDownloadProgress
    let completion: ImageDownloadCompletion
    let session: URLSession
    
    var identifier: Int! { task.taskIdentifier }
    var diskLocation: URL?
    private(set) var task: URLSessionDownloadTask!
    
    init(url: URL,
         session: URLSession,
         progress: @escaping ImageDownloadProgress,
         completion: @escaping ImageDownloadCompletion) {
        self.url = url
        self.session = session
        self.progress = progress
        self.completion = completion
        
        task = session.downloadTask(with: url)
    }
    
    func start() {
        task.resume()
    }
}
