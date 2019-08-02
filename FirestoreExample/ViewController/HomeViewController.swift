//
//  HomeViewController.swift
//  FirestoreExample
//
//  Created by orangemac05 on 02/08/19.
//  Copyright © 2019 Saurabh. All rights reserved.
//

import UIKit
import FirebaseFirestore

class HomeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var documents: [DocumentSnapshot] = []
    public var tasks: [Task] = []
    private var listener : ListenerRegistration!
    
    fileprivate func baseQuery() -> Query {
        return Firestore.firestore().collection("Tasks").limit(to: 50)
    }
    
    fileprivate var query: Query? {
        didSet {
            if let listener = listener {
                listener.remove()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addTapped))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.query = baseQuery()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.listener =  query?.addSnapshotListener { (documents, error) in
            guard let snapshot = documents else {
                print("Error fetching documents results: \(error!)")
                return
            }
            
            let results = snapshot.documents.map { (document) -> Task in
                if let task = Task(dictionary: document.data(), id: document.documentID) {
                    return task
                } else {
                    fatalError("Unable to initialize type \(Task.self) with dictionary \(document.data())")
                }
            }
            
            self.tasks = results
            self.documents = snapshot.documents
            self.tableView.reloadData()
            
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.listener.remove()
    }
    
    @objc func addTapped() {
//        promptForAnswer()
        documents("Tasks").add
        Collection("Tasks").addDocument
        (data: ["name": textFieldReminder.text ??
            "empty task", "done": false])
    }
    
    func promptForAnswer() {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned ac] _ in
            let answer = ac.textFields![0]
            // do something interesting with "answer" here
        }
        
        ac.addAction(submitAction)
        
        present(ac, animated: true)
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let item = tasks[indexPath.row]
        
        cell.textLabel!.text = item.name
        cell.textLabel!.textColor = item.done == false ? UIColor.black : UIColor.lightGray
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if (editingStyle == .delete){
            let item = tasks[indexPath.row]
            _ = Firestore.firestore().collection("Tasks").document(item.id).delete()
        }
        
    }
}
