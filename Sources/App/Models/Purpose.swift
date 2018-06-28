import Vapor
import FluentPostgreSQL

final class Purpose: Codable {
    var id: Int?
    var defaultPurpose: String
    var purposes: [String]
    var userID: User.ID

    init(defaultPurpose: String, purposes: [String], userID: User.ID) {
        self.defaultPurpose = defaultPurpose
        self.purposes = purposes
        self.userID = userID
    }
}
extension Purpose: PostgreSQLModel {}
extension Purpose: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.userID, to: \User.id)
        }
    }
}
extension Purpose: Content {}
extension Purpose: Parameter {}
extension Purpose {
    var user: Parent<Purpose, User> {
        return parent(\.userID)
    }
}