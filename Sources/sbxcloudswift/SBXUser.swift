//
// Created by Hans Ospina on 3/10/18.
//

import Foundation


public struct SBXLoginResponse:Codable {
    public let success:Bool
    public let token:String?
    public let user:SBXUser?
    public let error:String?
}


public struct SBXUser: Codable {

    public let id: Int
    public let name: String
    public let code: String?
    public let email: String
    public let login: String
    public let role: String
    public let domainName: String
    public let domainId: Int
    public let memberOf: [SBXDomainMemberShip]


    enum CodingKeys: String, CodingKey {
        case id
        case name
        case code
        case email
        case login
        case role
        case domainName = "domain"
        case domainId = "domain_id"
        case memberOf = "member_of"
    }


}

public struct SBXDomainMemberShip: Codable {
    public let id: Int
    public let name: String
    public let displayName: String
    public let role: String
    public let homeKey: String?

    enum CodingKeys: String, CodingKey {
        case id = "domain_id"
        case name = "domain"
        case displayName = "display_name"
        case role
        case homeKey = "home_key"
    }

}


struct CloudScriptResponse<T:Codable>:Codable {
    public let response:CloudScriptResponseBody<T>?
    public let success:Bool
    public let error:String?
}

struct CloudScriptResponseBody<T:Codable>:Codable {
    public let body:T?
}

