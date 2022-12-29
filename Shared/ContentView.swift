//
//  ContentView.swift
//  class
//
//  Created by LiYanan2004 on 2022/5/11.
//

import SwiftUI
import AVKit
import AVFAudio

struct ContentView: View {
    var timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    let beginTime = ["08:29", "09:24", "10:19", "11:14", "13:29", "14:24", "15:19", "16:14", "--"]
    let overTime = ["09:10", "10:05", "11:00", "11:55", "14:10", "15:05", "16:00", "16:55", "--"]
    @State var player = AVPlayer(url: Bundle.main.url(forResource: "begin", withExtension: "mp3")!)
    @ObservedObject var messagesController: Messages
    @State var exception = [String]()
    var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("HH:mm")
        return formatter
    }
    
    var body: some View {
        TimelineView(.everyMinute) { context in
            NavigationView {
                VStack(alignment: .leading, spacing: 10) {
                    Text(context.date, style: .time).font(.largeTitle.bold())
                        .frame(width: 200)
                        .onReceive(timer) { _ in check(date: context.date) }
                    Spacer()
                    HStack {
                        Button("上课铃") { setPlayer(to: .begin) }.disabled(player.rate != 0)
                        Spacer()
                        Button("STOP", role: .destructive) {
                            player = AVPlayer(url: Bundle.main.url(forResource: "begin", withExtension: "mp3")!)
                        }
                        Spacer()
                        Button("下课铃") { setPlayer(to: .over) }.disabled(player.rate != 0)
                    }
                }
                .padding()
                    
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(messagesController.messages, id: \.self) { message in
                            Text(message).font(.headline.bold()).id(UUID())
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }
                .navigationTitle("操作日志")
                .navigationSubtitle("共有 \(messagesController.messages.count) 条信息")
            }
        }
        .onAppear() { check(date: Date()) }
    }

    func check(date: Date) {
        // 正在播放就不要打断
        guard player.rate == 0 else { return }

        let nowTime = formatter.string(from: date)

        // 播放过了就加入`排外名单` 不要再次播放
        guard !exception.contains(nowTime) else { return }
        
        if beginTime.contains(nowTime) {
            setPlayer(to: .begin)
            exception.append(nowTime)
            sendMessage("下次打铃时间：\(overTime[beginTime.firstIndex(of: nowTime) ?? 0])")
        } else if overTime.contains(nowTime) {
            setPlayer(to: .over)
            exception.append(nowTime)
            sendMessage("下次打铃时间：\(beginTime[(overTime.firstIndex(of: nowTime) ?? 0) + 1])\n")
        }
    }

    func setPlayer(to kind: SoundKind) {
        sendMessage("\(kind == .begin ? "[上课啦]" : "[下课啦]") \(Date().formatted(date: .omitted, time: .standard))  Music...")
        let newPlayer = AVPlayer(url: Bundle.main.url(forResource: kind.rawValue, withExtension: "mp3")!)
        player = newPlayer
        player.play()
    }

    func sendMessage(_ content: String) {
        messagesController.messages.append(content)
    }
}

enum SoundKind: String {
    case begin
    case over
}
