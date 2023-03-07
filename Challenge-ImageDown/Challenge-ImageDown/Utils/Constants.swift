//
//  Constants.swift
//  Challenge-ImageDown
//
//  Created by JunHo Park on 2023/03/06.
//

import Foundation

struct Constants {
    private init () {
        
    }
    public static let imageLoadedData: Array<DownloadImageModel> = [
        .init(urlStr: "https://images.unsplash.com/photo-1677552929439-082dabf4e88f?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2370&q=80"), // https://unsplash.com/ko/%EC%82%AC%EC%A7%84/vk_Z_ya4u14
        .init(urlStr: "https://images.unsplash.com/photo-1677549254885-cf55be3e552b?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=987&q=80"), // https://unsplash.com/ko/%EC%82%AC%EC%A7%84/VOYv0cDl_Uo
        .init(urlStr: "https://images.unsplash.com/photo-1677472423915-0cc46eb36685?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1335&q=80"), // https://unsplash.com/ko/%EC%82%AC%EC%A7%84/TtGYrK3WYFY
        .init(urlStr: "https://images.unsplash.com/photo-1675679620439-bacfc67a669a?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2370&q=80"), // https://unsplash.com/ko/%EC%82%AC%EC%A7%84/gmejHJ6k-VY
        .init(urlStr: "https://images.unsplash.com/photo-1677455104504-364b0e16ef39?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2370&q=80"), // https://unsplash.com/ko/%EC%82%AC%EC%A7%84/KvXQBeoolwU
        .init(urlStr: "https://wallpaperaccess.com/download/europe-4k-1369012"),
        .init(urlStr: "https://wallpaperaccess.com/download/europe-4k-1318341"),
        .init(urlStr: "https://wallpaperaccess.com/download/europe-4k-1379801"),
        .init(urlStr: "https://wallpaperaccess.com/download/cool-lion-167408"),
        .init(urlStr: "https://wallpaperaccess.com/download/iron-man-323408")
    ]
    
    public static let bgQueue = DispatchQueue(label: "bgQueue", qos: .background, attributes: .concurrent)
    
    public static let byteFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        return formatter
    }()
}
