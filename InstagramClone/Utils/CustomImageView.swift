//
//  CustomImageView.swift
//  InstagramClone
//
//  Created by КИМ on 25.10.2022.
//

import UIKit

var imageCache = [String: UIImage]()

class CustomImageView: UIImageView {
    
    var lastUrlUsed: String?
     
    func loadImage(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        lastUrlUsed = urlString
        
        self.image = nil
        
        if let cachedImage = imageCache[urlString] {
            self.image = cachedImage
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, err in
            if let err = err {
                print("post photo download error", err)
                return
            }
            if url.absoluteString != self.lastUrlUsed {
                return
            }
            guard let imageData = data else { return }
            let photoImage = UIImage(data: imageData)
            imageCache[url.absoluteString] = photoImage
            DispatchQueue.main.async {
                self.image = photoImage
            }
        }.resume()
    }
}
