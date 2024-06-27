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
            if let jsonObject = try JSONSerialization.jsonObject(with: didReceive, options: []) as?  [String: Any] {
                handleJSON(jsonObject)
            } else {
                print("Received data is not a valid JSON object")
            }
        } catch {
            print("Error deserializing received data: \(error)")
        }
    }
}

func handleJSON(_ json: [String: Any]) {
  if let messageType = json["type"] as? String {
      switch messageType {
      case "gameState":
          onlineOtherPlayCells = json["info"] as! [String: [String: [String: String]]]
      case "rocks":
          pNuisanceBeans = json["info"] as! Int
      default:
          print("Unknown message type: \(messageType)")
      }
  } else {
      print("Invalid JSON: missing 'type' key")
  }
}
