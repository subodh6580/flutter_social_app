//
//  ImageGallery.swift
//  Runner
//
//  Created by Apple on 20/08/22.
//

import Foundation
import Photos

class ImageGallery{
    private init() {
    }
    
    static let shared = ImageGallery()

    func createImagePickerChanel(window:UIWindow){
        guard let controller = window.rootViewController as? FlutterViewController else {
            fatalError("rootViewController is not type FlutterViewController")
        }
        let channel = FlutterMethodChannel(name: "/gallery", binaryMessenger: controller as! FlutterBinaryMessenger)
        
        channel.setMethodCallHandler { (call, result) in
            switch (call.method) {
                
            case "getItemCount":
                let mediaType = call.arguments as! Int

                result(self.getGalleryImageCount(mediaType: mediaType))
            case "getItem":
                
                let arguments = call.arguments as! [String:Int]
                let mediaType = arguments["mediaType"]!;
                let index = arguments["index"]!;

                self.dataForGalleryItem(index: index, mediaType: mediaType, completion: { (data, id, created, mediaType, path) in
                    
                    result([
                        "data": data ?? Data(),
                        "id": id,
                        "created": created,
                        "mediaType": mediaType,
                        "path": path
                    ])
                })
                

                case "originalForGalleryItem":

                                let identifier = call.arguments as? String ?? ""

                                self.originalForGalleryItem(identifier: identifier, completion: { (data, id, created, mediaType, path) in

                                    result([
                                        "data": data ?? Data(),
                                        "id": id,
                                        "created": created,
                                        "mediaType": mediaType,
                                        "path": path
                                    ])
                                })
            default: result(FlutterError(code: "0", message: nil, details: nil))
            }
        }
    }

    func getGalleryImageCount(mediaType:Int) -> Int {
        // 1
        let fetchOptions = PHFetchOptions()
        fetchOptions.includeHiddenAssets = true
        
        if(mediaType == 1){
            //images only
            fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        }
        else if (mediaType == 2){
            //images only
            fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue)
        }

        // 2
        let collection: PHFetchResult = PHAsset.fetchAssets(with: fetchOptions)
        // 3
        return collection.count
    }

    func dataForGalleryItem(index: Int, mediaType:Int, completion: @escaping (Data?, String, Int, Int, String) -> Void) {
        
        // 1
        let fetchOptions = PHFetchOptions()
        fetchOptions.includeHiddenAssets = true
        
        if(mediaType == 1){
            //images only
            fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        }
        else if (mediaType == 2){
            //images only
            fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue)
        }
        
        let collection: PHFetchResult = PHAsset.fetchAssets(with: fetchOptions)
        if (index >= collection.count) {
            return
        }
        
        // 2
        let asset = collection.object(at: index)
        
        // 3
        let options = PHImageRequestOptions()
        options.deliveryMode = .fastFormat
        options.resizeMode = PHImageRequestOptionsResizeMode.exact;
        options.isSynchronous = true
        let imageSize = CGSize(width: 500,
                               height: 500)
        
        // 4
        let imageManager = PHCachingImageManager()
        
        imageManager.requestImage(for: asset, targetSize: imageSize, contentMode: .aspectFit, options: options) { (image, info) in
            // 5
            if let image = image {
                // 6
                let data = image.pngData()
                
                
                completion(data,
                           asset.localIdentifier,
                           Int(asset.creationDate?.timeIntervalSince1970 ?? 0),
                           asset.mediaType.rawValue,"")
            } else {
                completion(nil, "", 0, 0,"")
            }
        }
    }

    func originalForGalleryItem(identifier: String, completion: @escaping (Data?, String, Int, Int,String) -> Void) {
        // 1
        let fetchOptions = PHFetchOptions()
        fetchOptions.includeHiddenAssets = true
        let collection: PHFetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: fetchOptions)
        
        // 2
        let asset = collection.object(at: 0)
        
        // 3

        if(asset.mediaType == PHAssetMediaType.image){
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
        
            options.isSynchronous = true
            
            // 4
            let imageManager = PHCachingImageManager()
            
            imageManager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: options) { (image, info) in
                // 5
                asset.requestContentEditingInput(with: PHContentEditingInputRequestOptions()) { (input, _) in
                    let url = input?.fullSizeImageURL
                    if let image = image {
                        // 6
                        let data = image.pngData()
                        
                        completion(data,
                                   asset.localIdentifier,
                                   Int(asset.creationDate?.timeIntervalSince1970 ?? 0),
                                   asset.mediaType.rawValue, url!.absoluteString)
                    } else {
                        completion(nil, "", 0, 0,"")
                    }
                }
            }
        }
        else{
            let localIdentifier:String = asset.localIdentifier
            let creationDate =  Int(asset.creationDate?.timeIntervalSince1970 ?? 0)
            let mediaType = asset.mediaType.rawValue

            asset.requestContentEditingInput(with: PHContentEditingInputRequestOptions()) { (input, _) in
                let url = input?.fullSizeImageURL
                print(url)
            }
            
            PHImageManager.default().requestAVAsset(forVideo: asset,
                                                    options: nil) { (asset, audioMix, info) in
                
                let aVURLAsset = asset as? AVURLAsset
                    let data = try! Data(contentsOf: aVURLAsset!.url)
                completion(data,
                           localIdentifier,
                           creationDate,
                           mediaType, aVURLAsset!.url.absoluteString)
                
            }
            
        }

    }

}
