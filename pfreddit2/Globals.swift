//
//  Globals.swift
//  pfreddit2
//
//  Created by David Lee on 12/23/15.
//  Copyright © 2015 David Lee. All rights reserved.
//

import RealmSwift

// TODO: Is there any way of keeping Realm out of this? It seems that there's no way around
//   specifying which kind of nodes/edges are in an adopter of `ContentGraph`...

//var SharedContentGraph: ContentGraph! = RealmContentGraph(realm: try! Realm())
var SharedContentGraph: RealmContentGraph! = RealmContentGraph(realm: try! Realm())