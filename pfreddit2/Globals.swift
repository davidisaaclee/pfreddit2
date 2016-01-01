//
//  Globals.swift
//  pfreddit2
//
//  Created by David Lee on 12/23/15.
//  Copyright © 2015 David Lee. All rights reserved.
//

import RealmSwift

var SharedContentGraph: ContentGraph = RealmContentGraph(realm: try! Realm())
var SharedContentParser: ContentParser = ContentParser(modules: [ImgurParser()], fallback: WebpageContentParser())