//
//  TypeDefinitions.swift
//  MLMusicComposition
//
//  Created by B5TB2080 江宇揚 on 2018/05/20.
//  Copyright © 2018 Jiang Yuyang. All rights reserved.
//

import Foundation
import UIKit

typealias NoteValue = String
typealias Duration = Int

let notesDictionaryInSharp = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
let notesDictionaryInFlat = ["C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab", "A", "Bb", "B"]


// MARK: - struct Note

struct Note {
    let noteValue: NoteValue
    let duration: Duration
}

// MARK: - class Cord

class Cord {
    let key: NoteValue // the key of the cord (ex: C)
    let cordType: String // cord type (ex: maj7)
    let keyNotes: [NoteValue] // key notes of the cord (ex: C, E, G for Cmaj)
    let tensions: [NoteValue] // tensions of the specific key (ex: D, F#, B for Cmaj7)
    
    
    // auxiliary static func for init()
    
    static func appendNotesFor(_ key: String, distances: [Int]) -> [NoteValue] {
        let keyIndex: Int = notesDictionaryInSharp.index(of: key) ?? notesDictionaryInFlat.index(of: key)!
        return distances.flatMap{
            let index = keyIndex + $0
            return index <= 12 ? notesDictionaryInSharp[index] : notesDictionaryInSharp[index-12]
        }
    }
    
    
    // main initializer
    
    init(_ cordName: String) {
        let cordNameComponents = cordName.components(separatedBy: "_")
        guard cordNameComponents.count == 2 else { fatalError("Failed to split cord name into certain cord.") }
        
        let key = cordNameComponents[0]
        guard notesDictionaryInSharp.contains(key) || notesDictionaryInFlat.contains(key), key.count <= 2 else { fatalError("Key name error.") }
        self.key = key
        
        
        let cordType = cordNameComponents[1]
        switch cordType {
        case "maj":
            self.keyNotes = Cord.appendNotesFor(key, distances: [0, 4, 7])
            self.tensions = Cord.appendNotesFor(key, distances: [2, 9, 11])
            
        case "maj7":
            self.keyNotes = Cord.appendNotesFor(key, distances: [0, 4, 7, 11])
            self.tensions = Cord.appendNotesFor(key, distances: [2])
            
        case "min", "min7":
            self.keyNotes = Cord.appendNotesFor(key, distances: [0, 3, 7, 10])
            self.tensions = Cord.appendNotesFor(key, distances: [2, 5])
            
        case "6", "min6":
            self.keyNotes = Cord.appendNotesFor(key, distances: [0, 3, 7, 9])
            self.tensions = Cord.appendNotesFor(key, distances: [2, 5])
            
        case "7":
            self.keyNotes = Cord.appendNotesFor(key, distances: [0, 4, 7, 10])
            self.tensions = Cord.appendNotesFor(key, distances: [1, 2, 6, 8])
            
        case "dim", "dim7":
            self.keyNotes = Cord.appendNotesFor(key, distances: [0, 3, 6, 9])
            self.tensions = Cord.appendNotesFor(key, distances: [2, 5, 8, 11])
            
        default:
            fatalError("Cord type error.")
        }
        self.cordType = cordType
    }
}


// MARK: - class Measure

class Measure {
    var cord: Cord
    static let beats = 8
    var notes: [Note]
    
    init(cord: Cord, notes: [Note]) {
        guard notes.reduce(0, { $0 + $1.duration }) == Measure.beats else { fatalError("The total timeValue doesn't meat the general beats.") }
        
        self.cord = cord
        self.notes = notes
    }
}


// MARK: - enum

enum CordRelationship {
    case twoFive
    case relative
    case same
    case subMinor
    case nearKey
    case none
}


// MARK: - class Environment

class Environment {
    let phrase: [Measure]
    let relationship: CordRelationship
    
    init( phrase: [Measure], relationship: CordRelationship ) {
        self.phrase = phrase
        self.relationship = relationship
    }
}












