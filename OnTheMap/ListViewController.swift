//
//  ListViewController.swift
//  OnTheMap
//
//  Created by Mahmoud Tawfik on 10/11/16.
//
//

import UIKit

class ListViewController: MapTypeViewController, UITableViewDataSource, UITableViewDelegate {

    //MARK: IBOutlets
    @IBOutlet weak var studentList: UITableView!

    //MARK: View Lifecycle methods
    
    override func viewDidLoad() {
        reloadBlock = {self.studentList.reloadData()}
        super.viewDidLoad()
    }


    // MARK: - UITableViewDataSource methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ParseStudents.students.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "List Cell")!
        cell.imageView?.image = UIImage(named: "pin")
        let  student = ParseStudents.students[indexPath.row]
        cell.textLabel?.text = student.fullName
        cell.detailTextLabel?.text = student.mediaURL

        return cell
    }

    // MARK: - UITableViewDataSource methods

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let  student = ParseStudents.students[indexPath.row]
        if let url = URL(string: student.mediaURL) {
            UIApplication.shared.openURL(url)
        }
    }
}
