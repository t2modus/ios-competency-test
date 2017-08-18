//
//  AppManager.swift
//  DirectoryListing
//
//  Created by Michael Steele on 2/21/17.
//  Copyright © 2017 Michael Steele. All rights reserved.
//

import UIKit
import RealmSwift
import Cache

class AppManager: NSObject {
    static private var appManager: AppManager? = nil

    //static public let serverURL = "http://private-c1b9f-t2mobile.apiary-mock.com/"
    static public let serverURL = "http://www.steeleinnovations.com/" // TODO: Fix needed on server to contain key of individuals or realm fix needed - further research required.  Not enough time.  Usually we key each data set.
    
    static public let allowInvalidCert = true // TODO: get call removed authentication for now.
    
    static public let baseURL = serverURL // If subdirectory exists + "/api/"
    
    static public let user = "test"; // Temporary user until login UI is built.
    static public let password = "test"; // Temporary password until login UI is built.

    static public let imageCompression : CGFloat = 95
    
    public var webService: WebService
    
    public var imageCache = AppManager.initImageCache()
    
    override init() {
        self.webService = WebService()
    }
    
    static func shared() -> AppManager {
        if (AppManager.appManager == nil) {
            AppManager.appManager = AppManager()
            AppManager.appManager?.clearDataIfNeeded()
        }
        
        return AppManager.appManager!
    }
    
    static func initImageCache() -> Cache<UIImage> {
        return Cache<UIImage>(name: "ImageCache", config: Config(
            frontKind: .memory,
            backKind: .disk,
            expiry: .date(Date().addingTimeInterval(60*60*24)),
            maxSize: 100000000,
            maxObjects: 10000
        ))
    }
    
    static func decodeURL(_ text: String) -> String {
        guard let decodedURL = text.base64Decoded() else {
            return baseURL
        }
        
        guard let url = decodedURL.base64Decoded() else {
            return decodedURL
        }
        
        return url
    }
    
    func setLastAppVersion() {
        let defaults = UserDefaults.standard
        defaults.set(getAppVersion(), forKey: "AppVersion")
    }
    
    func getLastAppVersion() -> String? {
        let defaults = UserDefaults.standard
        
        guard let version = defaults.string(forKey: "AppVersion") else {
            return nil
        }
        
        return version
    }
    
    
    func getAppVersion() -> String {
        guard let dictionary = Bundle.main.infoDictionary else {
            return ""
        }
        
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        
        return "\(version) build \(build)"
    }
    
    func clearData() {
        do {
            let realm = try Realm()
            
            realm.beginWrite()
            
            realm.deleteAll()
            
            try realm.commitWrite()
            
        } catch let error {
            DLog("Realm clear data error \(error)")
        }
    }
    
    func clearDataIfNeeded() {
        if (getAppVersion() != getLastAppVersion()) {
            clearDataFiles()
        }
        
        setLastAppVersion()
    }
    
    func clearImageCache() {
        imageCache.clear()
    }
    
    func clearDataFiles() {
        guard let realmURL = Realm.Configuration.defaultConfiguration.fileURL else {
            return
        }
        
        imageCache.clear()
        
        let realmURLs = [
            realmURL,
            realmURL.appendingPathExtension("lock"),
            realmURL.appendingPathExtension("note"),
            realmURL.appendingPathExtension("management")
        ]
        
        for url in realmURLs {
            
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                DLog("Attempting to delete database at: \(url.absoluteString)")
            }
        }
    }
    
    func authenticated() -> Bool {
        return true // TODO: For future auth
    }
}
