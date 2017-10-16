//
//  Engine.swift
//  ARTris
//
//  Created by Alireza Alidousti on 2017-10-15.
//  Copyright © 2017 ARTris. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class Position: NSObject {
    let x, y, z, col: Int
    init? (dict: [String: Int]){
        if let x = dict["x"], let y = dict["y"], let z = dict["z"], let col = dict["col"] {
            self.x = x; self.y = y; self.z = z; self.col = col
        } else {
            return nil
        }
    }
    override var description: String {
        return "(\(x), \(y), \(z))"
    }
}

class Engine {
    static let ref: DatabaseReference = { () -> DatabaseReference in
        FirebaseApp.configure()
        return Database.database().reference()
    }()
    
    let sessionId = "test"
    var state: [Position] = [] {
        didSet {
            print(state)
        }
    }
    
    init() {
        Engine.ref.child("game-session").child(sessionId).child("grid-render").observe(.value, with: { [weak self] snapshot in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                let newState = snapshots.map { snap -> [Position?] in
                    if let cells = snap.children.allObjects as? [DataSnapshot] {
                        return cells.map{ cell -> Position? in
                            if let pos = cell.value as? Dictionary<String, Int> {
                                return Position(dict: pos)
                            }
                            return nil
                        }
                    }
                    return Array<Position?>()
                }
                self?.state = newState.flatMap { $0.flatMap{ $0 } }
            }
        });
    }
}