//
//  File.swift
//  
//
//  Created by Masein Modi on 1/5/22.
//
import Foundation

struct SubmittedChatMessage: Decodable {
    let message: String
    let user: String
    let userID: UUID
}
struct ReceivingChatMessage: Encodable, Identifiable {
    let date = Date()
    let id = UUID()
    let message: String
    let user: String
    let userID: UUID
}
