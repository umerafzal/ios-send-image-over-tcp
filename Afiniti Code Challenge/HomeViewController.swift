//
//  HomeViewController.swift
//  Afiniti Code Challenge
//
//  Created by Umer on 10/05/2021.
//

import Foundation
import UIKit

class HomeViewController: UIViewController {
    
    lazy var containerView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alignment = .fill
        view.distribution = .fillEqually
        view.axis = .vertical
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        downloadImages()
    }
    
    func setupUI(){
        view.addSubview(containerView)
        
        NSLayoutConstraint.activate([
        containerView.topAnchor.constraint(equalTo: view.topAnchor),
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor),
        containerView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    
    func downloadImages() {
        for url in ImageURLs.urls {
            ImageDownloader.shared.downloadImage(url: URL(string: url)!) { progress in
                print("progress:  \(progress)")
            } completion: { image, task  in
                DispatchQueue.main.async {
                    print("image")
                    self.addImageToScreen(image: image)
                }
            }
        }
    }
    
    func addImageToScreen(image: UIImage?) {
        let imageView = UIImageView()
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        containerView.addArrangedSubview(imageView)
    }
}

extension HomeViewController {
    @IBAction func sendImageAction() {
        let controller = tcpController()
        controller.sender = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func receiveImageAction() {
        let controller = tcpController()
        controller.sender = false
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    private func tcpController() -> SendImageViaTCPController {
        let controller: SendImageViaTCPController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "SendImageViaTCPController")
        return controller
    }
}

class ImageURLs {
    static let urls = ["https://s3-eu-west-1.amazonaws.com/s1-yap-documents-public/1611581853884_tobeChanged.png",
                       "https://homepages.cae.wisc.edu/~ece533/images/serrano.png",
                       "https://homepages.cae.wisc.edu/~ece533/images/airplane.png",
                       "https://homepages.cae.wisc.edu/~ece533/images/fruits.png",
                       "https://homepages.cae.wisc.edu/~ece533/images/peppers.png"]
}






