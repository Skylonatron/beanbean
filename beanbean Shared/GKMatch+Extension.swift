//
//  GKMatch+Extension.swift
//  beanbean
//
//  Created by Skylar Jones on 5/15/24.
//

import GameKit

extension GKMatch: GKMatchDelegate {
    public func match(_: GKMatch, didReceive: Data, forRecipient: GKPlayer, fromRemotePlayer: GKPlayer) {
        do {
            if let jsonObject = try JSONSerialization.jsonObject(with: didReceive, options: []) as?  [String: [String: [String: String]]] {
                onlineOtherPlayCells = jsonObject
                return
            } else {
                print("Received data is not a valid JSON object")
            }
        } catch {
            print("Error deserializing received data: \(error)")
        }
        if let receivedString = String(data: didReceive, encoding: .utf8) {
            // Handle the received string
            pNuisanceBeans = receivedString
        } else {
            print("Failed to convert data to string")
        }
    }
}
