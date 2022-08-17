//
//  FirebaseReference.swift
//  TicTacToe
//
//  Created by user224517 on 8/16/22.
//

import Foundation
import Firebase
import FirebaseFirestore


enum FCollectionReference: String {
    case Game
}

func FirebaseReference(_ collectionReference: FCollectionReference) -> CollectionReference {
    return Firestore.firestore().collection(collectionReference.rawValue)
}

