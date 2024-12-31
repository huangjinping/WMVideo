//
//  ViewController.swift
//  WMVideo
//
//  Created by wumeng on 2019/11/25.
//  Copyright © 2019 wumeng. All rights reserved.
//

import UIKit
import AVKit

class ViewController: UIViewController {

    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var targetView:UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //Get stored media files
        print(WMCameraFileTools.wm_getAllfiles())
        
        
        targetView=UIImageView(frame: CGRectMake(100, 300, 100, 100))
        targetView?.backgroundColor=UIColor.lightGray
        self.view.addSubview(targetView!)
    }

    @IBAction func recordVideoClick(_ sender: Any) {
        
        let vc = WMCameraViewController()
//        vc.inputType = .video
        vc.videoMaxLength = 20
        vc.modalPresentationStyle=UIModalPresentationStyle.fullScreen
        vc.completeBlock = { url, type in
            print("url == \(url)")
            //normal
//            if type == .video {
//                let videoUrl = URL.init(fileURLWithPath: url)
//                self.WM_FUNC_PresentPlay(videoUrl: videoUrl)
//            }
            //export
            if type == .video {
                self.getVideoInfoWithSourcePath(path: url)
                    let time = CMTime(seconds: 1.0, preferredTimescale: 600) // 5秒时的一帧
                self.captureImage(from: URL.init(fileURLWithPath: url), at: time) { image in
                            if let image = image {
                                // 使用到的图片
                                self.targetView?.image=image;
                                print("Image captured successfully")
                            } else {
                                print("Failed to capture image")
                            }
                }
//                self.captureImage(from: URL, at: time) { UIImage? in
//
//                }
//                
                let videoEditer = WMVideoEditor.init(videoUrl: URL.init(fileURLWithPath: url))
                videoEditer.addWaterMark(image: UIImage.init(named: "billbill")!)
                videoEditer.addAudio(audioUrl: Bundle.main.path(forResource: "孤芳自赏", ofType: "mp3")!)
                self.loadingIndicator.startAnimating()
                videoEditer.assetReaderExport(completeHandler: { url in
                    self.loadingIndicator.stopAnimating()
                    // play video
                    let videoUrl = URL.init(fileURLWithPath: url)
                    self.WM_FUNC_PresentPlay(videoUrl: videoUrl)
                   
                })
            }
            //image
            if type == .image {
                //save image to PhotosAlbum
                self.WM_FUNC_saveImage(UIImage.init(contentsOfFile: url)!)
            }
        }
        present(vc, animated: true, completion: nil)
        
    }
    
    
    
    
    
    //MARK:- save image
    func WM_FUNC_saveImage(_ image:UIImage) -> Void {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    //MARK:- play video
    func WM_FUNC_PresentPlay(videoUrl: URL) -> Void {
        
        // Create an AVPlayer, passing it the HTTP Live Streaming URL.
        let player = AVPlayer(url: videoUrl)
        // Create a new AVPlayerViewController and pass it a reference to the player.
        let controller = AVPlayerViewController()
        controller.player = player
        // Modally present the player and call the player's play() method when complete.
        present(controller, animated: true) {
            player.play()
        }
        
    }

    func getVideoInfoWithSourcePath( path:String){
        NSLog("===getVideoInfoWithSourcePath===");
        let asset=AVURLAsset(url: URL.init(fileURLWithPath: path))
        let time=[asset .duration];
        NSLog("=====%@", time)
//        let fileSize=NSFileProviderManager
//        let fileSize=NSFileProviderManager.
        
//        FileManager.default.attributesOfItem(atPath: path);
            
        do {
            let fileManager = FileManager.default
//            let path = "/path/to/file"
            let fileAttributes = try fileManager.attributesOfItem(atPath: path)
            if let fileSize = fileAttributes[FileAttributeKey.size] as? Int {
                print("File size: \(fileSize)")
                if(fileSize>=1048576){
                    
                    print("File size: \(fileSize/1024/1024)M")
                }else{
                    print("File size: \(fileSize/1024)KB")
                }
            }
        } catch {
            print("Error: \(error)")
        }
        
    }
    
    
//    func getVideoSize(for fileURL: URL) -> UInt64 {
//        let asset = AVAsset(url: fileURL)
//        let assetValues = asset.tracks.first?.assetTrack?.assetTrackSegments.first?.mediaSegment.segment.mediaData?.hintFormat?.formatDescription?.extendedPrecision?.memoryLayout
//        
//        return assetValues?.memoryLayout ?? 0
//    }
//     
//    func getVideoSize(for url: URL) -> CGSize? {
//        let asset = AVAsset(url: url)
//        let videoTrack = asset.tracks(withMediaType: .video).first
//        let size = videoTrack?.naturalSize.CGSizeValue
//        return size
//    }
     

    
//    // 使用示例
//    if let videoURL = Bundle.main.url(forResource: "video", withExtension: "mp4") {
//        let size = getVideoSize(for: videoURL)
//        print("Video size: \(size) bytes")
//    }
    

    
    
    func captureImage(from videoURL: URL, at time: CMTime, completion: @escaping (UIImage?) -> Void) {
        let asset = AVAsset(url: videoURL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.requestedTimeToleranceBefore = .zero
        generator.requestedTimeToleranceAfter = .zero
        
        do {
            let imageRef = try generator.copyCGImage(at: time, actualTime: nil)
            let image = UIImage(cgImage: imageRef)
            completion(image)
        } catch {
            completion(nil)
            print(error.localizedDescription)
        }
    }
//     
//    // 使用方法
//    let videoURL = URL(fileURLWithPath: "path/to/your/video.mp4")
//    let time = CMTime(seconds: 5.0, preferredTimescale: 600) // 5秒时的一帧
//    captureImage(from: videoURL, at: time) { image in
//        if let image = image {
//            // 使用获取到的图片
//            print("Image captured successfully")
//        } else {
//            print("Failed to capture image")
//        }
//    }
//    
    
}





