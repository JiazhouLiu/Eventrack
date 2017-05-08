//
//  SearchVC.swift
//  Eventrack
//
//  Created by Jiazhou Liu on 7/5/17.
//  Copyright © 2017 Jiazhou Liu. All rights reserved.
//

import UIKit
import FirebaseDatabase

class SearchVC: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tokenView: KSTokenView!
    @IBOutlet weak var TV: UITableView!
    var categories = [String]()
    var searchCategories: Array<String> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        DataService.instance.categoryRef.observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            
            if let cat = snapshot.value as? Dictionary<String, AnyObject>{
                for (key, _) in cat{
                    self.categories.append(key)
                }
            }
        }
        
        tokenView.delegate = self
        tokenView.promptText = "Categories: "
        tokenView.placeholder = "Type to search"
        tokenView.descriptionText = "Selected"
        tokenView.maxTokenLimit = -1 //default is -1 for unlimited number of tokens
        tokenView.minimumCharactersToSearch = 0 // Show all results without without typing anything
        tokenView.style = .squared
        tokenView.direction = .horizontal
        tokenView.shouldAddTokenFromTextInput = false
        tokenView.paddingY = 12.0
        tokenView.marginX = 8.0
        self.view.bringSubview(toFront: tokenView)
        self.view.sendSubview(toBack: TV)
        self.view.sendSubview(toBack: searchBar)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backToHomePressed(_ sender: Any) {
        performSegue(withIdentifier: "SearchToHomeSegue", sender: sender)
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    


}

extension SearchVC: KSTokenViewDelegate {
    func tokenView(_ token: KSTokenView, performSearchWithString string: String, completion: ((_ results: Array<AnyObject>) -> Void)?) {
        if (string.characters.isEmpty){
            completion!(categories as Array<AnyObject>)
            return
        }
        
        var data: Array<String> = []
        for value: String in categories {
            if value.lowercased().range(of: string.lowercased()) != nil {
                data.append(value)
            }
        }
        completion!(data as Array<AnyObject>)
    }
    
    func tokenViewDidEndEditing(_ tokenView: KSTokenView) {
        if let array: Array<KSToken> = tokenView.tokens(){
            for token in array{
                print("\(token.title) ")
            }
        }
    }
    
    func tokenView(_ token: KSTokenView, displayTitleForObject object: AnyObject) -> String {
        return object as! String
    }
}
