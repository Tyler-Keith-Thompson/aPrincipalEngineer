//
//  Aside.swift
//  
//
//  Created by Tyler Thompson on 4/24/22.
//

import Plot
import Plot
import Publish

struct Aside: Component {
    @ComponentBuilder public var content: () -> ComponentGroup

    var body: Component {
        Element(name: "aside", content: content)
    }
}
