//
//  HXAttribute.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/2/24.
//

import Elementary
import ElementaryHTMX

extension HTMLAttributeValue.HTMX.Extension {
    public static var classTools: Self { "class-tools" }
}

extension HTMLAttribute.hx {
    static func ext(_ ext: HTMLAttributeValue.HTMX.Extension) -> HTMLAttribute {
        .init(name: "hx-ext", value: ext.rawValue)
    }
}
