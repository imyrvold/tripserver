import Vapor
import Leaf

struct WebsiteController: RouteCollection {
    func boot(router: Router) throws {
        router.get(use: indexHandler)
        router.get("users", User.parameter, use: userHandler)
        router.get("users", use: allUsersHandler)
    }

    func indexHandler(_ req: Request) throws -> Future<View> {
        return Purpose.query(on: req)
            .all()
            .flatMap(to: View.self) { purposes in
                let purposeData = purposes.isEmpty ? nil : purposes
                let context = IndexContext(title: "Homepage", purposes: purposeData)
                return try req.view().render("index", context)
            }
    }

    func userHandler(_ req: Request) throws -> Future<View> {
        return try req.parameters.next(User.self)
            .flatMap(to: View.self) { user in
                return try user.purposes
                    .query(on: req)
                    .all()
                    .flatMap(to: View.self) { purposes in
                        let context = UserContext(title: user.fullName ?? "(Name not set)", user: user, purposes: purposes)
                        return try req.view().render("user", context)
                    }
            }
    }

    func allUsersHandler(_ req: Request) throws -> Future<View> {
        return User.query(on: req)
            .all()
            .flatMap(to: View.self) { users in
                let context = AllUsersContext(title: "All Users", users: users)
                return try req.view().render("allUsers", context)
            }
    }
}

struct IndexContext: Encodable {
    let title: String
    let purposes: [Purpose]?
}

struct UserContext: Encodable {
    let title: String
    let user: User
    let purposes: [Purpose]
}

struct AllUsersContext: Encodable {
    let title: String
    let users: [User]
}