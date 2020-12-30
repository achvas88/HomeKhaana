//
//  ChatViewController.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 12/29/20.
//  Copyright © 2020 Achyuthan Vasanth. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import FirebaseDatabase

class ChatViewController: JSQMessagesViewController {

    var messages = [JSQMessage]()
    var currentOrder: Order?
    var chatDBRef: DatabaseReference?
    lazy var outgoingBubble: JSQMessagesBubbleImage = {
        return JSQMessagesBubbleImageFactory()!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }()

    lazy var incomingBubble: JSQMessagesBubbleImage = {
        return JSQMessagesBubbleImageFactory()!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleGreen())
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(currentOrder == nil)
        {
            fatalError("Order is null. Shouldn't happen")
        }
        
        if(currentOrder!.kitchenId == "" || currentOrder!.orderingUserID == "" || currentOrder!.id == "")
        {
            fatalError("Kitchen or ordering user id is null. Shouldn't happen")
        }
        
        chatDBRef = db.child("CurrentOrders/\(currentOrder!.kitchenId)/\(currentOrder!.orderingUserID)/\(currentOrder!.id)/Chat")
        if(chatDBRef == nil)
        {
            fatalError("Chat DB reference is nil. Shouldn't happen")
        }
        
        senderId = User.sharedInstance!.id
        senderDisplayName = User.sharedInstance!.name
        
        let kitchen:Kitchen? = DataManager.kitchens[currentOrder!.kitchenId]
        
        if(User.sharedInstance!.isKitchen)
        {
            self.title = "Chat with \(currentOrder!.orderingUserName)"
            if(kitchen != nil)
            {
                senderDisplayName = kitchen!.name
            }
        }
        else
        {
            if(kitchen != nil)
            {
                self.title = "Chat with \(kitchen!.name)"
            }
        }
        
        inputToolbar.contentView.leftBarButtonItem = nil
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        let query = chatDBRef!.queryLimited(toLast: 50)

        _ = query.observe(.childAdded, with: { [weak self] snapshot in

            if  let data        = snapshot.value as? [String: String],
                let id          = data["sender_id"],
                let name        = data["name"],
                let text        = data["text"],
                !text.isEmpty
            {
                if let message = JSQMessage(senderId: id, displayName: name, text: text)
                {
                    self?.messages.append(message)

                    self?.finishReceivingMessage()
                }
            }
        })
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData!
    {
        return messages[indexPath.item]
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource!
    {
        return messages[indexPath.item].senderId == senderId ? outgoingBubble : incomingBubble
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource!
    {
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString!
    {
        return messages[indexPath.item].senderId == senderId ? nil : NSAttributedString(string: messages[indexPath.item].senderDisplayName)
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat
    {
        return messages[indexPath.item].senderId == senderId ? 0 : 15
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!)
    {
        let ref = chatDBRef!.childByAutoId()
        let message = ["sender_id": senderId, "name": senderDisplayName, "text": text]
        ref.setValue(message)

        finishSendingMessage()
    }
    
    @IBAction func closeBtnClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
