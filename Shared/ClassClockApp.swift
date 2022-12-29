//
//  HelloApp.swift
//  Shared
//
//  Created by LiYanan2004 on 2022/5/11.
//

import SwiftUI

@main
struct ClassClockApp: App {
    @StateObject var messageController: Messages = Messages()
    var body: some Scene {
        WindowGroup {
            ContentView(messagesController: messageController).frame(width: 720, height: 512)
        }
    }
}

class Messages: ObservableObject {
    @Published var messages = [String]()
}
