import Foundation
import Publish
import Plot

// This type acts as the configuration for your website.
struct APrincipalEngineer: Website {
    enum SectionID: String, WebsiteSectionID {
        // Add the sections that you want your website to contain here:
        case posts
    }

    struct ItemMetadata: WebsiteItemMetadata {
        // Add any site-specific metadata that you want to use here.
    }

    struct Content {
        let profileName = "Tyler Thompson"
        let profileTitle = "Principal Software Engineer - Apple Platforms"
        let aboutMe = """
        My primary motivation is helping people. As Software Engineer's we can sometimes get so wrapped up in a problem we forget what the end goal is. I do my best to make sure the software I help write makes a difference, and is based off of user needs.

        I have managed to become a Principal Engineer largely by working with people far smarter than I am, and learning from them. I owe much of my success specifically to World Wide Technology where I continue to enjoy opportunities to work with a very diverse group of intelligent people.

        I spend most of my free time honing my skills in my favorite programming language (Swift). I've become an avid believer in automated testing and DevOps practices. I incorporate that into both my professional code and my personal code.
        """
        let residence = "Colorado, United States"
        let yearsInIndustry = 14
        let primarySkill = "Apple Development"
    }

    // Update these properties to configure your website:
    var url = URL(string: "https://aPrincipalEngineer.com")!
    var name = "A Principal Engineer"
    var description = "A blog about software engineering. From career advice, to side projects, to Swift language topics."
    var language: Language { .english }
    var imagePath: Path? { nil }
    let content = Content()
}

// This will generate your website using the built-in Foundation theme:
try APrincipalEngineer().publish(using: [
    .group([].map(PublishingStep.installPlugin)),
    .optional(.copyResources()),
    .addMarkdownFiles(),
    .sortItems(by: \.date, order: .descending),
    .generateHTML(withTheme: .sparrow),
    .generateSiteMap()
])
