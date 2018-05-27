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

struct Note: Equatable {
    let noteValue: NoteValue
    let duration: Duration
}

// MARK: - class Cord

class Cord: Equatable {
    static func == (lhs: Cord, rhs: Cord) -> Bool {
        if lhs.cordType == rhs.cordType,
            lhs.key == rhs.key {
            return true
        } else {
            return false
        }
    }
    
    let key: NoteValue // the key of the cord (ex: C)
    let cordType: String // cord type (ex: maj7)
    let keyNotes: [NoteValue] // key notes of the cord (ex: C, E, G for Cmaj)
    let tensions: [NoteValue] // tensions of the specific key (ex: D, F#, B for Cmaj7)
    let duration: Duration
    
    
    // auxiliary static func for init()
    
    static func appendNotesFor(_ key: String, distances: [Int]) -> [NoteValue] {
        let keyIndex: Int = notesDictionaryInSharp.index(of: key) ?? notesDictionaryInFlat.index(of: key)!
        return distances.map{
            let index = keyIndex + $0
            return index <= 12 ? notesDictionaryInSharp[index] : notesDictionaryInSharp[index-12]
        }
    }
    
    
    // main initializer
    
    init(_ cordName: String, duration: Duration) {
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
        self.duration = duration
    }
}


// MARK: - class Measure

class Phrase {
    var cords: [Cord]
    static let beats = 8
    let measures: Int
    var notes: [Note]
    
    init(cords: [Cord], notes: [Note], measures: Int = 1) {
        guard notes.reduce(0, { $0 + $1.duration }) == Phrase.beats * measures else { fatalError("The total timeValue doesn't meet the general beats.") }
        self.measures = measures
        self.cords = cords
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
    let phrase: Phrase
    let currentCords: [Cord]
    let relationships: [CordRelationship]
    
    init( phrase: Phrase, relationships: [CordRelationship], currentCords: [Cord] ) {
        guard relationships.count == currentCords.count else {fatalError("relationships.count dismatch currentCords.count or phrase.count")}
        self.phrase = phrase
        self.relationships = relationships
        self.currentCords = currentCords
    }
}


// MARK: - class Evaluation

class Reaction: Hashable {
    var hashValue: Int
    static func == (lhs: Reaction, rhs: Reaction) -> Bool {
        if lhs.newPhrase.notes == rhs.newPhrase.notes,
            lhs.newPhrase.cords == rhs.newPhrase.cords {
            return true
        } else {
            return false
        }
    }
    
    let newPhrase: Phrase
    let environment: Environment
    
    init(to environment: Environment) {
        var generatedNotes = [Note]()
        var randomDuration = Int(arc4random_uniform(8) + 1)
        var randomNoteValue = Int(arc4random_uniform(12))
        var beatsLeft = Phrase.beats * environment.phrase.measures
        
        while true {
            let note = Note(noteValue: notesDictionaryInSharp[randomNoteValue], duration: randomDuration)
            generatedNotes.append(note)
            
            if beatsLeft == 0 { break }
            else {
                beatsLeft -= randomDuration
                randomNoteValue = Int(arc4random_uniform(12))
                randomDuration = Int(arc4random_uniform(8) + 1)
            }
        }
        
        let cords = environment.currentCords
        let measures = environment.phrase.measures
        self.newPhrase = Phrase(cords: cords, notes: generatedNotes, measures: measures)
        self.environment = environment
        
        var hashString = ""
        for note in generatedNotes {
            hashString.append(note.noteValue)
            for _ in 1..<note.duration {
                hashString.append("_")
            }
        }
        self.hashValue = Int( hashString.unicodeScalars.map({$0.value}).reduce(0, { $0*10000 + $1 }) )
    }
}














