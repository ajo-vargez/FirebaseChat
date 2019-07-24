//
//  Extensions.swift
//  FirebaseChat
//
//  Created by Ajo M Varghese on 15/11/18.
//  Copyright © 2018 Ajo M Varghese. All rights reserved.
//

import UIKit

// MARK : - Declarations
let imageCache = NSCache<AnyObject, AnyObject>();

// MARK : - Plugins
extension UIImageView {
    func loadImagesUsingCache(withUrl: String) {
        self.image = nil;
        
        /* check if image exists in cache */
        if let cachedImage = imageCache.object(forKey: withUrl as AnyObject) as? UIImage {
            self.image = cachedImage;
            return;
        }
        /* otherwise download fresh images */
        let url = URL(string: withUrl);
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                print(error.debugDescription);
                return;
            }
            /* successfully downloaded images */
            guard let data = data else {
                print("Data is nil");
                return;
            }
            DispatchQueue.main.async {
                self.image = UIImage(data: data);
            }
        }.resume();
    }
} // Extension UIImageView

extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1);
    }
} // Extension UIColor

extension UIView {
    func addConstraintsWithVisual(format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]();
        for (index, view) in views.enumerated() {
            let key = "v\(index)";
            viewsDictionary[key] = view;
            view.translatesAutoresizingMaskIntoConstraints = false;
        }
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: viewsDictionary))
    }
} // Extension UIView
