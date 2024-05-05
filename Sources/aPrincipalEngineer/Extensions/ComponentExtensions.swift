//
//  ComponentExtensions.swift
//
//
//  Created by Annalise Mariottini on 5/5/24.
//

import Foundation
import Plot

extension Array where Element: Component {
    @ComponentBuilder func joined(separator: Component) -> Component {
        let count = self.count
        for (index, component) in self.enumerated() {
            if (index + 1) < count {
                component
                separator
            } else {
                component
            }
        }
    }
}
