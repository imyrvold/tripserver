import Vapor
import Fluent 

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }

    let usersController = UsersController()
    try router.register(collection: usersController)

    let purposesController = PurposesController()
    try router.register(collection: purposesController)

    let websiteController = WebsiteController()
    try router.register(collection: websiteController)
    
}
