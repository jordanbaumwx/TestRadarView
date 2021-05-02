//
//  NewRadarOverlay.swift
//  RapidWx
//

import Foundation
import MapKit

class RadarOverlay: MKTileOverlay {
    func createPathIfNecessary(path: String) -> Void {
        let fm = FileManager.default
        if(!fm.fileExists(atPath: path)) {
            do {
                try fm.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            } catch let error {
                print(error)
            }
        }
    }

    func cachePathWithName(name: String) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        let cachesPath: String = paths as String
        let cachePath =  cachesPath.appending(name)
        createPathIfNecessary(path: cachesPath)
        createPathIfNecessary(path: cachePath)

        return cachePath
    }

    func getFilePathForURL(url: URL, folderName: String) -> String {
        return cachePathWithName(name: folderName).appending("\(url.hashValue)")
    }
    override func loadTile(at path: MKTileOverlayPath, result: @escaping (Data?, Error?) -> Void)
    {
        let url1 = self.url(forTilePath: path)
        let filePath = getFilePathForURL(url: url1, folderName: "/RAPID_WEATHER2")
        let file = FileManager.default

        let urlTileCache = URLCache(memoryCapacity: 5_000_000, diskCapacity: 5_000_000, directory: URL(fileURLWithPath: "rapidWX-radar-tiles"))
        
        if urlTileCache.memoryCapacity == urlTileCache.currentMemoryUsage || urlTileCache.diskCapacity == urlTileCache.currentDiskUsage {
            urlTileCache.removeAllCachedResponses()
        }
            let sessionConfig = URLSessionConfiguration.default
            sessionConfig.httpShouldUsePipelining = true
            sessionConfig.httpMaximumConnectionsPerHost = 300
            sessionConfig.urlCache = urlTileCache
            
            let urlSession = URLSession(configuration: sessionConfig)
        
        if file.fileExists(atPath: filePath) {
                    let tileData =  try? NSData(contentsOfFile: filePath, options: .dataReadingMapped)
                    result(tileData as Data?, nil)
        } else {
            let request = NSMutableURLRequest(url: url1)
            request.httpMethod = "GET"
                urlSession.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in

                            if error != nil {
                                print("Error downloading tile")
                                result(nil, error)
                            }
                            else {
                                do {
                                    try data?.write(to: URL(fileURLWithPath: filePath))
                                } catch let error {
                                    print(error)
                                }
                                result(data, nil)
                            }
                        }).resume()
        }
    }
 


}
