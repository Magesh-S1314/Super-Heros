//
//  ImageSourceHandler.swift
//  Super Heros
//
//  Created by magesh on 03/03/21.
//

import Foundation
import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

class ImageSourceHandler {
    private init() {}
    
    // MARK: **** DOWNLOAD IMAGE FROM URL
    static func loadImageUsingCacheWithUrlString(urlString: String, completion: @escaping (UIImage?) -> ()) {
        
        //check cache for image first
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            completion(cachedImage)
            return
        }
        
        //otherwise fire off a new download
        if let url = URL(string: urlString){
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                //download hit an error so lets return out
                if error != nil {
                    print(error ?? "")
                    completion(nil)
                    return
                }
                DispatchQueue.main.async(execute: {
                    if let downloadedImage = UIImage(data: data!) {
                        imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                        completion(downloadedImage)
                        return
                    }
                })
            }).resume()
        }else{
            completion(nil)
        }
    }
}
