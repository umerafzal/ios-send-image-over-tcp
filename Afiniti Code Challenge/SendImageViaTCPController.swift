//
//  SendImageViaTCPController.swift
//  Afiniti Code Challenge
//
//  Created by Umer on 10/05/2021.
//

import Foundation
import  UIKit

class SendImageViaTCPController: UIViewController {
    
    let client = ImageSenderTCPClient()
    var sender = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        client.setupNetworkCommunication()
        client.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        client.stopSession()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if sender {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.client.send(image: #imageLiteral(resourceName: "umer"))
            }
        }
    }
    func addImageToScreen(image: UIImage) {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.image = image
        
        self.view.addSubview(view)
        
        view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        view.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        
    }
    
}

extension SendImageViaTCPController: ImageSenderDelegate {
    func imageReceived(image: UIImage) {
        DispatchQueue.main.async {
            self.addImageToScreen(image: image)
        }
    }
}


