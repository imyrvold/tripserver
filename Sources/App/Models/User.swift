import Foundation
import Vapor
import FluentPostgreSQL
import Authentication

final class User: Codable {
        var userId: UUID?
        var userName: String
        var appTracking: Bool
        var attestationBy: String?
        var bankAccountNumber: String?
        var country: String
        var currency: String
        var distanceUnit: String
        var email: String
        var fullName: String?
        var locale: String
        var mobilePhone: String?
        var privateAddress: String?
        var taxDomicile: String?
        var title: String?
        var countryCode: Int
        var employeeNumber: String?
        var dateForFirstTrip: Date
        var privateDays: Int
        var privateLocalizedDistance: Double
        var privateTrips: Int

        var password: String

        public var id: UUID? {
            get {
                return self.userId
            }
            set {
                self.userId = newValue
            }
        }

    init(userName: String, appTracking: Bool, attestationBy: String?, bankAccountNumber: String?, country: String, currency: String, distanceUnit: String, email: String, fullName: String?, locale: String, mobilePhone: String?, privateAddress: String?, taxDomicile: String?, 
    title: String?, countryCode: Int, employeeNumber: String?, dateForFirstTrip: Date, privateDays: Int, privateLocalizedDistance: Double, privateTrips: Int, password: String) {
        self.userName = userName
        self.appTracking = appTracking
        self.attestationBy = attestationBy
        self.bankAccountNumber = bankAccountNumber
        self.country = country
        self.currency = currency
        self.distanceUnit = distanceUnit
        self.email = email
        self.fullName = fullName
        self.locale = locale
        self.mobilePhone = mobilePhone
        self.privateAddress = privateAddress
        self.taxDomicile = taxDomicile
        self.title = title
        self.countryCode = countryCode
        self.employeeNumber = employeeNumber
        self.dateForFirstTrip = dateForFirstTrip
        self.privateDays = privateDays
        self.privateLocalizedDistance = privateLocalizedDistance
        self.privateTrips = privateTrips

        self.password = password
    }

    final class Public: Codable {
        var id: UUID?
        var userName: String
        var appTracking: Bool
        var attestationBy: String?
        var bankAccountNumber: String?
        var country: String
        var currency: String
        var distanceUnit: String
        var email: String
        var fullName: String?
        var locale: String
        var mobilePhone: String?
        var privateAddress: String?
        var taxDomicile: String?
        var title: String?
        var countryCode: Int
        var employeeNumber: String?
        var dateForFirstTrip: Date
        var privateDays: Int
        var privateLocalizedDistance: Double
        var privateTrips: Int

        init(id: UUID?, userName: String, appTracking: Bool, attestationBy: String?, bankAccountNumber: String?, country: String, currency: String, distanceUnit: String, email: String, fullName: String?, locale: String, mobilePhone: String?, privateAddress: String?, taxDomicile: String?, 
        title: String?, countryCode: Int, employeeNumber: String?, dateForFirstTrip: Date, privateDays: Int, privateLocalizedDistance: Double, privateTrips: Int) {
            self.id = id
            self.userName = userName
            self.appTracking = appTracking
            self.attestationBy = attestationBy
            self.bankAccountNumber = bankAccountNumber
            self.country = country
            self.currency = currency
            self.distanceUnit = distanceUnit
            self.email = email
            self.fullName = fullName
            self.locale = locale
            self.mobilePhone = mobilePhone
            self.privateAddress = privateAddress
            self.taxDomicile = taxDomicile
            self.title = title
            self.countryCode = countryCode
            self.employeeNumber = employeeNumber
            self.dateForFirstTrip = dateForFirstTrip
            self.privateDays = privateDays
            self.privateLocalizedDistance = privateLocalizedDistance
            self.privateTrips = privateTrips
        }
    }
}

// extension User: Model {
//     typealias Database = PostgreSQLDatabase
//     typealias ID = Int
//     public static var idKey: IDKey = \User.userId
// }
extension User: PostgreSQLUUIDModel {}
extension User: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.unique(on: \.userName)
        }
    }
}
extension User: Content {}
extension User: Parameter {}
extension User.Public: Content {}
extension User {
    func convertToPublic() -> User.Public {
        return User.Public(id: id, userName: userName, appTracking: appTracking, attestationBy: attestationBy, bankAccountNumber: bankAccountNumber, country: country, currency: currency, distanceUnit: distanceUnit, email: email, fullName: fullName, locale: locale, mobilePhone: mobilePhone, privateAddress: privateAddress, taxDomicile: taxDomicile, 
        title: title, countryCode: countryCode, employeeNumber: employeeNumber, dateForFirstTrip: dateForFirstTrip, privateDays: privateDays, privateLocalizedDistance: privateLocalizedDistance, privateTrips: privateTrips)
    }
}
extension Future where T: User {
    func convertToPublic() -> Future<User.Public> {
        return self.map(to: User.Public.self) { user in
            return user.convertToPublic()
        }
    }
}
extension User: BasicAuthenticatable {
    static let usernameKey: UsernameKey = \User.userName
    static let passwordKey: PasswordKey = \User.password
}
extension User: TokenAuthenticatable {
    typealias TokenType = Token
}

// extension User: Content {}
// extension User: Parameter {}
// extension User: Migration {}

extension User {
    var purposes: Children<User, Purpose> {
        return children(\.userID)
    }
}