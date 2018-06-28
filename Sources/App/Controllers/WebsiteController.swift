import Vapor
import Leaf

struct WebsiteController: RouteCollection {
    func boot(router: Router) throws {
        router.get(use: indexHandler)
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
}

struct IndexContext: Encodable {
    let title: String
    let purposes: [Purpose]?
}