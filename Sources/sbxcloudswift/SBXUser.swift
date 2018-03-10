//
// Created by Hans Ospina on 3/10/18.
//

import Foundation


public struct SBXLoginResponse:Codable {
    let success:Bool
    let token:String?
    let user:SBXUser?
    let error:String?
}


public struct SBXUser: Codable {

    let id: Int
    let name: String
    let code: String?
    let email: String
    let login: String
    let role: String
    let domainName: String
    let domainId: Int
    let memberOf: [SBXDomainMemberShip]


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
    let id: Int
    let name: String
    let displayName: String
    let role: String
    let homeKey: String?

    enum CodingKeys: String, CodingKey {
        case id = "domain_id"
        case name = "domain"
        case displayName = "display_name"
        case role
        case homeKey = "home_key"
    }

}
