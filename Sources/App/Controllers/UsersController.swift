import Vapor
import Crypto
import Fluent

struct  UsersController: RouteCollection {
    func boot(router: Router) throws {
        let usersRoutes = router.grouped("api", "users")
        usersRoutes.post(User.self, use: createHandler)
        usersRoutes.get(use: getAllHandler)
        usersRoutes.get(User.parameter, use: getHandler)
        usersRoutes.put(User.parameter, use: updateHandler)
        usersRoutes.delete(User.parameter, use: deleteHandler)
        usersRoutes.get("search", use: searchHandler)
        // usersRoutes.get("first", use: getFirstHandler)
        usersRoutes.get("sorted", use: sortedHandler)
        usersRoutes.get(User.parameter, "purposes", use: getPurposesHandler)

        let basicAuthMiddleware = User.basicAuthMiddleware(using: BCryptDigest())
        let basicAuthGroup = usersRoutes.grouped(basicAuthMiddleware)
        basicAuthGroup.post("login", use: loginHandler)
    }

    func createHandler(_ req: Request, user: User) throws -> Future<User.Public> {
        user.password = try BCrypt.hash(user.password)
        return user.save(on: req).convertToPublic()
    }

    func getAllHandler(_ req: Request) throws -> Future<[User.Public]> {
        return User.query(on: req).decode(User.Public.self).all()
    }

    func getHandler(_ req: Request) throws -> Future<User.Public> {
        return try req.parameters.next(User.self).convertToPublic()
    }

    func getPurposesHandler(_ req: Request) throws -> Future<[Purpose]> {
        return try req.parameters.next(User.self)
            .flatMap(to: [Purpose].self) { user in
                try user.purposes.query(on: req).all()
            }
    }

    func updateHandler(_ req: Request) throws -> Future<User> {
        return try flatMap(to: User.self, req.parameters.next(User.self), req.content.decode(User.self)) { user, updatedUser in
            user.userId = updatedUser.userId
            user.userName = updatedUser.userName
            user.appTracking = updatedUser.appTracking
            user.attestationBy = updatedUser.attestationBy
            user.bankAccountNumber = updatedUser.bankAccountNumber
            user.country = updatedUser.country
            user.currency = updatedUser.currency
            user.distanceUnit = updatedUser.distanceUnit
            user.email = updatedUser.email
            user.fullName = updatedUser.fullName
            user.locale = updatedUser.locale
            user.mobilePhone = updatedUser.mobilePhone
            user.privateAddress = updatedUser.privateAddress
            user.taxDomicile = updatedUser.taxDomicile
            user.title = updatedUser.title
            user.countryCode = updatedUser.countryCode
            user.employeeNumber = updatedUser.employeeNumber
            user.dateForFirstTrip = updatedUser.dateForFirstTrip
            user.privateDays = updatedUser.privateDays
            user.privateLocalizedDistance = updatedUser.privateLocalizedDistance
            user.privateTrips = updatedUser.privateTrips

            return user.save(on: req)
        }
    }

    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters
            .next(User.self)
            .delete(on: req)
            .transform(to: HTTPStatus.noContent)
    }

    func searchHandler(_ req: Request) throws -> Future<[User.Public]> {
        guard let searchUserName = req.query[String.self, at: "userName"] else { throw Abort(.badRequest) }

        return User.query(on: req)
            .filter(\.userName == searchUserName)
            .decode(User.Public.self).all()
    }

    // func getFirstHandler(_ req: Request) throws -> Future<User.Public> {
    //       return User.query(on: req)
    //         .first()
    //         .map(to: User.self) { user in
    //             guard let user = user else { throw Abort(.notFound) }

    //             return user
    //         }
    // } 

    func sortedHandler(_ req: Request) throws -> Future<[User.Public]> {
        return User.query(on: req)
            .sort(\.userName, .ascending)
            .decode(User.Public.self).all()
    }

    func loginHandler(_ req: Request) throws -> Future<Token> {
        let user = try req.requireAuthenticated(User.self)
        let token = try Token.generate(for: user)
        return token.save(on: req)
    }
}