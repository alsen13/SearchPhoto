//
//  ViewController.swift
//  PhotoSearch
//
//  Created by admin on 6/7/19.
//  Copyright © 2019 Alexey Sen. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {

    let realm = try! Realm()
    var array = [PhotoFound]()
    var currentPhoto: Photo? = nil
    let cellId = "cellId"
    
    var results: Results<PhotoFound>!
    
    struct BaseUrls {
        static let accessKey = "4c9fbfbbd92c17a2e95081cec370b4511659666240eb4db9416c40c641ee843b"
        static let urlSearchPhotos = "https://api.unsplash.com/search/photos/?client_id=\(BaseUrls.accessKey)"
        static let photoPerPage = "1"
    }
    
    lazy var searchBar: UISearchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 300, height: 20))
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        collectionView.delegate = self
        collectionView.backgroundColor = .darkGray
        collectionView.register(PhotoCustomCell.self, forCellWithReuseIdentifier: cellId)
        //getPhoto(searchText: searchBar.)
        
        searchBar.placeholder = "Search Photo"
        searchBar.delegate = self
        let leftNavBarButton = UIBarButtonItem(customView:searchBar)
        self.navigationItem.leftBarButtonItem = leftNavBarButton
        
        self.navigationController?.navigationBar.barTintColor = UIColor.darkGray
        
        results = realm.objects(PhotoFound.self)
        
        print("PRINT OBJECTS:\(realm.objects(PhotoFound.self))")
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if results.count != 0 {
            return results.count
        }
        return 0
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
    

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PhotoCustomCell
        
        let result = results[indexPath.row]
        
        cell.photoImageView.image = UIImage(data: result.image!)
        cell.photoTitle.text = result.title
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        getPhoto(searchText: searchBar.text)
    }
}

extension ViewController {
    func getPhoto(searchText: String? = nil) {
        guard let downloadURL = URL(string: BaseUrls.urlSearchPhotos + "&per_page=" + BaseUrls.photoPerPage + "&query=" + searchText!) else { return }
        let task = URLSession.shared.dataTask(with: downloadURL) { (data, response, error) in
            
            
            guard let data = data else {
                return
            }
            
            let decoder = JSONDecoder()
            let imageData = try! decoder.decode(Photo.self, from: data)
            print("Image DATA:\(String(describing: imageData.results.first?.urls.regular))")
            guard imageData.results.first?.urls.regular != nil else {
                
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Bad query", message: "No photo found for this request. Please enter a valid request.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    
                    self.present(alert, animated: true, completion: nil)
                }
                
                
                
                return }
            guard let imagePhoto = URL(string: (imageData.results.first?.urls.regular)!) else { return }
            let task = URLSession.shared.dataTask(with: imagePhoto, completionHandler: { (data, response, error) in
                guard let data = data else {return}
                
                print("MY DATA: \(String(describing: data.count))")
                
                
                let curPhoto = PhotoFound()
                curPhoto.image = data
                curPhoto.title = searchText!
                //self.array.append(curPhoto)
                DispatchQueue.main.async {
                    try! self.realm.write {
                        self.realm.add(curPhoto)
                    }
                    self.collectionView.reloadData()
                    self.searchBar.text = ""
                }
                
                /*
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
                */
            })
            task.resume()
        }
        task.resume()
    }
}


















