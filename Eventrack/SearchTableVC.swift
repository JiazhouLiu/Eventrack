//
//  SearchTableVC.swift
//  Eventrack
//
//  Created by Jiazhou Liu on 7/5/17.
//  Copyright © 2017 Jiazhou Liu. All rights reserved.
//

import UIKit

class SearchTableVC: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        


        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // change back button text for segue to create screen
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if indexPath.section == 0{
            return 88.0
        }
        else{
            return 250.0;
        }
        
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch (section){
        case 0: return 1
        case 1: return 5
        default: return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "searchTopCell", for: indexPath) as! SearchTopCell
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "searchEventCell", for: indexPath) as! RegEventCell
            return cell
        }

        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.reloadData()
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
//        if let cell = sender as? UITableViewCell {
//            let i = self.tableView.indexPath(for: cell)!.row
//            if segue.identifier == "SearchToViewSegue" {
//                let vc = segue.destination as! ViewEventVC
//                //vc.currentEvent = eventArray[i] as Event
//                //vc.currentMonster = monsterListArray[i] as Monsters
//            }
//        }
//
//    }

}

