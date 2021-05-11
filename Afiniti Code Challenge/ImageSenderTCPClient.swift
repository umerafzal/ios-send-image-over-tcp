//
//  ImageSenderTCPClient.swift
//  Afiniti Code Challenge
//
//  Created by Umer on 11/05/2021.
//

import Foundation
import UIKit

protocol ImageSenderDelegate: class {
    func imageReceived(image: UIImage)
}

class ImageSenderTCPClient: NSObject {
    //1
    var inputStream: InputStream!
    var outputStream: OutputStream!
    
    weak var delegate: ImageSenderDelegate?
    
    //3
    let maxReadLength = 4096
    
    func setupNetworkCommunication() {
        // 1
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        
        // 2
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault,
                                           "localhost" as CFString,
                                           7070,
                                           &readStream,
                                           &writeStream)
        
        inputStream = readStream!.takeRetainedValue()
        outputStream = writeStream!.takeRetainedValue()
        
        inputStream.delegate = self
        
        inputStream.schedule(in: .current, forMode: .common)
        outputStream.schedule(in: .current, forMode: .common)
        
        inputStream.open()
        outputStream.open()
    }
    
    func send(image: UIImage) {
        if let data = image.pngData() {
            data.withUnsafeBytes {
                guard let pointer = $0.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
                    print("Error joining chat")
                    return
                }
                //4
                outputStream.write(pointer, maxLength: data.count)
            }
        }
    }
    
    func stopSession() {
        inputStream.close()
        outputStream.close()
    }
    
}

extension ImageSenderTCPClient: StreamDelegate {
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case .hasBytesAvailable:
            print("new message received")
            readAvailableBytes(stream: aStream as! InputStream)
        case .endEncountered:
            print("new end received")
        case .errorOccurred:
            print("error occurred")
        case .hasSpaceAvailable:
            print("has space available")
        default:
            print("some other event...")
        }
    }
    
    private func readAvailableBytes(stream: InputStream) {
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: maxReadLength)
        var imageData = Data()
        while stream.hasBytesAvailable {
            let numberOfBytesRead = inputStream.read(buffer, maxLength: maxReadLength)
            if numberOfBytesRead < 0, let error = stream.streamError {
                print(error)
                break
            }
            let data = Data(bytes: buffer, count: numberOfBytesRead)
            imageData.append(data)
        }
        
        if let image = UIImage(data: imageData) {
            delegate?.imageReceived(image: image)
            buffer.deallocate()
        }
    }
    
}
