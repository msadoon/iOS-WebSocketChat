//
//  SocketIOManager.swift
//  SocketChat
//
//  Created by Mubarak Sadoon on 2017-06-11.
//  Copyright © 2017 AppCoda. All rights reserved.
//

import UIKit
import SocketIO

class SocketIOManager: NSObject {
    static let sharedInstance = SocketIOManager()
    
    var socket:SocketIOClient = SocketIOClient(socketURL: NSURL(string:"http://192.168.0.120:3000")! as URL)
    
    override init() {
        super.init()
    }
    
    func establishConnection() {
        socket.connect()
    }
    
    func closeConnection() {
        socket.disconnect()
    }
    
    
    func connectToServerWithNickname(nickname: String,
                                     completionHandler: @escaping (_ userList: [[String: AnyObject]]?) -> Void) {
        socket.emit("connectUser", nickname)
        socket.on("userList") { (dataArray, ack) -> Void in
            completionHandler(dataArray[0] as! [[String:AnyObject]])
        }
//        socket.on("exitUserUpdate") { (nicknameToRemove, ack) -> Void in
//            completionHandler(nicknameToRemove as! [[String:AnyObject]])
//        }
        listenForOtherMessages()
    }
    
    func exitChatWithNickname(nickname: String, completionHandler: () -> Void) {
        socket.emit("exitUser", nickname)
        completionHandler()
    }
    
    func sendMessage(message: String, withNickName nickname: String) {
        socket.emit("chatMessage", nickname, message)
    }
    
    func getChatMessage(completionHandler: @escaping (_ messageInfo: [String: String]) -> Void) {
        socket.on("newChatMessage") { (dataArray, socketAck) -> Void in
            var messageDictionary = [String: String]()
            if let nicknameString = dataArray[0] as? String, let messageString = dataArray[1] as? String, let dateString = dataArray[2] as? String {
                messageDictionary["nickname"] = nicknameString
                messageDictionary["message"] = messageString
                messageDictionary["date"] =  dateString
            }
            
            completionHandler(messageDictionary)
        }
    }
    
    func sendStartTypingMessage(nickname: String) {
        socket.emit("startType", nickname)
    }
    
    func sendStopTypingMessage(nickname: String) {
        socket.emit("stopType", nickname)
    }
    
    private func listenForOtherMessages() {
        
        socket.on("userConnectUpdate") { (dataArray, socketAck) -> Void in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "userWasConnectedNotification"), object: dataArray[0] as! [String: AnyObject])
        }
        
        socket.on("userExitUpdate") { (dataArray, socketAck) -> Void in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "userWasDisconnectedNotification"), object: dataArray[0] as! String)
        }
        
        socket.on("userTypingUpdate") { (dataArray, socketAck) -> Void in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "userTypingNotification") , object: dataArray[0] as? [String:AnyObject])
            
        }
        
    }
}
