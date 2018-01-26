////
//// Created by Hans Ospina on 11/3/17.
////
//

import Foundation

let semaphore = DispatchSemaphore(value: 0)


let start = Date()


struct Customer: Codable {
    let key: String
    let name: String
    let margin: Float
    let adminId: Int?
    let logo: String?
    let folder: String?
    let street: String
    let city: String
    let state: State
    let zipCode: String
    let country: Country
    let timeZone: TimeZone?
    let accountManager: String
    let officePhone: String


    enum CodingKeys: String, CodingKey {
        case key = "_KEY"
        case name = "company_name"
        case margin
        case adminId = "admin"
        case logo
        case folder = "folder_key"
        case street
        case city
        case state
        case zipCode = "zipcode"
        case country
        case timeZone = "time_zone"
        case accountManager = "acc_manager"
        case officePhone = "office_phone"
    }


}

struct State: Codable {

    let key: String
    let iso: String
    let name: String

    enum CodingKeys: String, CodingKey {
        case key = "_KEY"
        case iso = "state_iso"
        case name = "state"
    }
}

struct Country: Codable {
    let key: String
    let iso: String
    let shipper: String

    enum CodingKeys: String, CodingKey {
        case key = "_KEY"
        case iso = "country_iso"
        case shipper = "country"
    }
}

struct TimeZone: Codable {
    let key: String
    let name: String
    let offset: Int


    enum CodingKeys: String, CodingKey {
        case key = "_KEY"
        case name = "time_zone"
        case offset
    }
}


let sbx = SbxCoreService(domain: 96, appKey: "598c9de4-6ef5-11e6-8b77-86f30ca893d3")
        .setToken(token: "489201b5-7993-461b-a96e-d0662fee700c")

sbx
        .find(model: "customer")
        .fetch(models: ["state", "country", "time_zone"])
        .whereWith(keys: ["0103634b-1188-4f58-93c0-219f2842cb2b"])
        .loadAll { (page: [Customer]?, resError: JSONError?) in

            if let e = resError {
                print("Error \(e)")
                semaphore.signal()
                return
            }

            if let items = page{//?.results {
                print("items \(items.count)")
                items.forEach {
                    print($0.name)
                }
            }

            semaphore.signal()
        }


semaphore.wait()




