import UIKit
import FirebaseAuth
import Firebase

class ChatViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    let db = Firestore.firestore()
    var messages: [Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = K.appName
        navigationItem.hidesBackButton = true
        tableView.dataSource = self
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        loadMessages()
    }
    
    func loadMessages() {
        db.collection(K.FStore.collectionName)
            .order(by: K.FStore.dateField)
            .addSnapshotListener { querySnapshot, error in
                //every change in database
                self.messages = []
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }
                for document in documents {
                    let data = document.data() // Access data for each document
                    
                    if let messageSender = data[K.FStore.senderField] as? String,
                       let messageBody = data[K.FStore.bodyField] as? String {
                        let newMessage = Message(sender: messageSender, body: messageBody)
                        self.messages.append(newMessage)
                    }
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData() //Run datasource methods again
                    let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                    if indexPath[1] >= 0  {
                        self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
                    }
                }
            }
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        Task {
            do {
                if let messageBody = messageTextfield.text, let messageSender = Auth.auth().currentUser?.email {
                    _ = try await db.collection(K.FStore.collectionName).addDocument(data: [
                        K.FStore.senderField: messageSender,
                        K.FStore.bodyField: messageBody,
                        K.FStore.dateField: Date().timeIntervalSince1970
                    ])
                    
                    DispatchQueue.main.async{
                        self.messageTextfield.text = ""
                    }
                    //print("Document added with ID: \(ref.documentID)")
                }
            } catch {
                print("Error adding document: \(error)")
            }
        }
    }
    
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            //return to welcomeviewcontroller
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}

extension ChatViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell
        cell.label.text = messages[indexPath.row].body
        
        //this message from the current user
        if message.sender == Auth.auth().currentUser?.email {
            cell.leftImageView.isHidden = true
            cell.rightImageView.isHidden = false
            cell.messageBubble.backgroundColor = UIColor(named:K.BrandColors.lighBlue)
            cell.label.textColor =  K.BrandColors.dark
            
        } else {
            //this message from the another sender
            cell.leftImageView.isHidden = false
            cell.rightImageView.isHidden = true
            cell.messageBubble.backgroundColor = K.BrandColors.darkGray
            cell.label.textColor = UIColor(named: K.BrandColors.lightPurple)
        }
        return cell
    }
}
