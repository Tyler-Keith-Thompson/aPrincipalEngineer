//
//  Alt.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/1/24.
//

import Elementary

public extension HTMLTrait.Attributes {
    protocol alt {}
}

extension HTMLTag.img: HTMLTrait.Attributes.alt {}

public extension HTMLAttribute where Tag: HTMLTrait.Attributes.alt {
    static func alt(_ description: String) -> Self {
        HTMLAttribute(name: "alt", value: description)
    }
}
