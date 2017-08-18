//
//  Individual.swift
//  DirectoryListing
//
//  Created by Michael Steele on 2/21/17.
//  Copyright © 2017 Michael Steele. All rights reserved.
//

import UIKit
import ObjectMapper
import Realm
import RealmSwift
import AlamofireImage

class Individual: BaseEntity {
    dynamic var id = 0
    dynamic var img: String = ""
    dynamic var first_name: String = ""
    dynamic var last_name: String = ""
    dynamic var status: String = ""
    dynamic var available: Bool = false
    
    // TODO: To Delete
    //dynamic var firstName: String = ""
    //dynamic var lastName: String = ""
    dynamic var birthdate: String = ""
    dynamic var affiliation: String = ""
    //dynamic var imageCheck: String = ""
    
    var forceSensitive = RealmOptional<Bool>()
    
    private var loadedProfileImage: UIImage?
    private var loadedProfileThumbnailImage: UIImage?
    
    private var requestedLoad : Bool = false
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        id <- map["id"]
        img <- map["img"]
        first_name <- map["first_name"]
        last_name <- map["last_name"]
        status <- map["status"]
        available <- map["available"]
        
        
        //firstName <- map["firstName"]
        //lastName <- map["lastName"]
        birthdate <- map["birthdate"]
        //profilePicture <- map["profilePicture"]
        forceSensitive <- map["forceSensitive"]
        affiliation <- map["affiliation"]
    }
    
    func getIdString() -> String {
        return "\(id)"
    }
    
    func getImageCheck() -> String {
        return getIdString() // Temporarily using ID for uniqueness instead of letting server control
    }
    
    func friendlyBirthdate() -> String? {
        return self.birthdate.friendlyDate()
    }
    
    func friendlyAffiliation() -> String {
        return affiliation.replacingOccurrences(of: "_", with: " ").lowercased().localizedCapitalized
    }
    
    func debugText() -> String {
        return "\(self.id) \(self.first_name) \(self.last_name) \(self.birthdate) \(self.img) \(self.forceSensitive) \(self.affiliation) \(self.getImageCheck())"
    }
    
    func clearImage() {
        self.loadedProfileImage = nil
        self.loadedProfileThumbnailImage = nil
        self.requestedLoad = false
    }
    
    func preloadImage(checkIndex: Int, forceRefresh: Bool = false, finished: @escaping ClosureIndexFinished) {
        
        if (forceRefresh == true) {
            clearImage()
        }
        
        if (loadedProfileImage != nil && loadedProfileThumbnailImage != nil) {
            DLog("image already loaded in memory for key: \(self.id)")
            
            finished(checkIndex)
            return
        }
        
        if (self.requestedLoad == true) {
            return
        }
        
        self.requestedLoad = true

        self.getImage(url: img + "?imageCheck=" + getImageCheck(), forceRefresh: forceRefresh) { (image) in
        
            self.loadedProfileImage = image
            
            self.loadedProfileImage = self.profileDetailImage()
            
            self.loadedProfileThumbnailImage = self.profileImage()
            
            if (image == nil || self.loadedProfileImage == nil || self.loadedProfileThumbnailImage == nil) {
                self.clearImage()
                return
            }
            
            DispatchQueue.main.async {
                finished(checkIndex)
            }
        }
        
        return
    }
    
    func profileImage() -> UIImage?
    {
        if (self.loadedProfileThumbnailImage != nil) {
            return self.loadedProfileThumbnailImage
        }
        
        guard let tempImage = loadedProfileImage else { return nil }
        
        let size = CGSize(width: 100.0, height: 100.0)
        let imageFilter = AspectScaledToFillSizeCircleFilter(size: size)
        
        return imageFilter.filter(tempImage)
    }
    
    func profileDetailImage() -> UIImage?
    {
        if (self.loadedProfileImage != nil) {
            return self.loadedProfileImage
        }
        
        guard let tempImage = loadedProfileImage else { return nil }
        
        let size = CGSize(width: 200.0, height: 200.0)
        let imageFilter = AspectScaledToFitSizeFilter(size: size)
        
        return imageFilter.filter(tempImage)
    }
}
