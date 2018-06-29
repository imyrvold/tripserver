 import Vapor
 import Fluent
 import Authentication

 struct PurposesController: RouteCollection {
     func boot(router: Router) throws {
        let purposesRoutes = router.grouped("api", "purposes")
        purposesRoutes.get(use: getAllHandler)
        purposesRoutes.get(Purpose.parameter, use: getHandler)
        // purposesRoutes.get("search", use: searchHandler)
        // purposesRoutes.get("first", use: getFirstHandler)
        // purposesRoutes.get("sorted", use: sortedHandler)
        purposesRoutes.get(Purpose.parameter, "user", use: getUserHandler)
        // purposesRoutes.post(Purpose.parameter, "categories", Category.parameter, use: addCategoriesHandler)
        // purposesRoutes.get(Purpose.parameter, "categories", use: getCategoriesHandler)

        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthGroup = purposesRoutes.grouped (tokenAuthMiddleware, guardAuthMiddleware)
        tokenAuthGroup.post(PurposeCreateData.self, use: createHandler)
        tokenAuthGroup.delete(Purpose.parameter, use: deleteHandler)
        tokenAuthGroup.put(Purpose.parameter, use: updateHandler)
     }

    func createHandler(_ req: Request, data: PurposeCreateData) throws -> Future<Purpose> {
        let user = try req.requireAuthenticated(User.self)
        let purpose = try Purpose(
            defaultPurpose: data.defaultPurpose,
            purposes: data.purposes,
            userID: user.requireID()
        )
        return purpose.save(on: req)
    }

    func getHandler(_ req: Request) throws -> Future<Purpose> {
        return try req.parameters.next(Purpose.self)
    }

    func updateHandler(_ req: Request) throws -> Future<Purpose> {
        return try flatMap(to: Purpose.self, req.parameters.next(Purpose.self), req.content.decode(PurposeCreateData.self)) { purpose, updateData in
            purpose.defaultPurpose = updateData.defaultPurpose
            purpose.purposes = updateData.purposes

            let user = try req.requireAuthenticated(User.self)
            purpose.userID = try user.requireID()
            return purpose.save(on: req)
        }
    }

    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters
                .next(Purpose.self)
                .delete(on: req)
                .transform(to: HTTPStatus.noContent)
    }

    // func searchHandler( req: Request) throws -> Future<[Purpose]> {
    //     guard let searchTerm = req.query[String.self, at: "term"] else { throw Abort(.badRequest) }
    //     return try Purpose.query(on: req).group(.or) { or in
    //         try or.filter(\.short == searchTerm)
    //         try or.filter(\.long == searchTerm)
    //     }.all()
    // }

    // func getFirstHandler(_ req: Request) throws -> Future<Purpose> {
    //     return Purpose.query(on: req).first().map(to: Purpose.self) { purpose in
    //         guard let purpose = purpose else { throw Abort(.notFound) }
    //         return purpose
    //     }
    // }

    // func sortedHandler(_ req: Request) throws -> Future<[Purpose]> {
    //     return try Purpose.query(on: req)
    //             .sort(\.defaultPurpose, .ascending)
    //             .all()
    // }

    func getUserHandler(_ req: Request) throws -> Future<User.Public> {
        return try req.parameters.next(Purpose.self)
                .flatMap(to: User.Public.self) { purpose in
                    purpose.user.get(on: req).convertToPublic()
                }
    }

    func getAllHandler(_ req: Request) throws -> Future<[Purpose]> {
        return Purpose.query(on: req).all()
    }

    // func addCategoriesHandler(_ req: Request) throws -> Future<HTTPStatus> {
    //     return try flatMap(to: HTTPStatus.self, req.parameters.next(Purpose.self), req.parameters.next(Category.self)) { purpose, category in
    //         let pivot = try PurposeCategoryPivot(purpose.requireID(), category.requireID())
    //         return pivot.save(on: req).transform(to: .created)
    //     }
    // }

    // func getCategoriesHandler(_ req: Request) throws -> Future<[Category]> {
    //     return try req.parameters.next(Purpose.self)
    //             .flatMap(to: [Category].self) { purpose in
    //                 try purpose.categories.query(on: req).all()
    //             }
    // }

 }

 struct PurposeCreateData: Content {
     let defaultPurpose: String
     let purposes: [String]
 }