/**
 *  SBXQueryBuilder
 *  Copyright (c) 2017 Hans Ospina <hansospina@gmail.com>
 *  Licensed under the MIT license, see LICENSE file
 */

import Foundation

public typealias JSONObject = [String: Any]

public enum JSONError: Error, CustomStringConvertible {
    case error(Error)
    case customError(String)
    case decodingError(DecodingError)
    case invalidJSON

    public var description: String {

        switch self {
        case let .error(error):
            return error.localizedDescription
        case let .customError(msg):
            return msg
        case .invalidJSON:
            return "Invalid JSON"
        case let .decodingError(e):
            switch e {
            case let .valueNotFound(type, context):
                return "Value not found => \(context.codingPath.last?.stringValue ?? "")(\(type)): \n \(context.codingPath)"
            case let .keyNotFound(key, context):
                return "Key not found => \(context.codingPath.last?.stringValue ?? "")(\(key)): \n \(context.codingPath)"
            case let .typeMismatch(type, context):
                return "Key not found => \(context.codingPath.last?.stringValue ?? "")(\(type)): \n \(context.codingPath)"
            default:
                return e.localizedDescription

            }
        }

    }
}


public enum HTTPMETHOD: String {
    case POST = "POST"
    case GET = "GET"
}


public protocol Find {

    var query: SBXQueryBuilder { get }

    func loadPage<T>(page: Int, completionHandler: @escaping (FindPageResponse<T>?, JSONError?) -> ())

    func loadAll<T: Codable>(completionHandler: @escaping ([T]?, JSONError?) -> ())

    func newGroupWithAnd() -> Find

    func newGroupWithOr() -> Find

    func andWhereIsEqual(field: String, value: Val) -> Find

    func andWhereIsNotNull(field: String) -> Find

    func andWhereIsNull(field: String) -> Find

    func andWhereGreaterThan(field: String, value: Val)

    func andWhereLessThan(field: String, value: Val)

    func andWhereGreaterOrEqualThan(field: String, value: Val)

    func andWhereLessOrEqualThan(field: String, value: Val)

    func andWhereIsNotEqual(field: String, value: Val)

    func andWhereStartsWith(field: String, value: String)

    func andWhereEndsWith(field: String, value: String)

    func andWhereContains(field: String, value: String)

    func andWhereIn(field: String, values: [Val])

    func andWhereNotIn(field: String, values: [Val])

    //  OR SECTION

    func orWhereIsEqual(field: String, value: Val) -> Find


    func orWhereIsNotNull(field: String) -> Find


    func orWhereIsNull(field: String) -> Find


    func orWhereGreaterThan(field: String, value: Val) -> Find

    func orWhereLessThan(field: String, value: Val) -> Find

    func orWhereGreaterOrEqualThan(field: String, value: Val) -> Find

    func orWhereLessOrEqualThan(field: String, value: Val) -> Find

    func orWhereIsNotEqual(field: String, value: Val) -> Find

    func orWhereStartsWith(field: String, value: String) -> Find

    func orWhereEndsWith(field: String, value: String) -> Find


    func orWhereContains(field: String, value: String) -> Find

    func orWhereIn(field: String, values: [Val]) -> Find

    func orWhereNotIn(field: String, values: [Val]) -> Find

    func whereWith(keys: [String]) -> Find

    func fetch(models: [String]) -> Find

    func set(page: Int) -> Find

    func set(size: Int) -> Find

}


public final class FindOperation: Find {

    public let query: SBXQueryBuilder
    let core: SBXCoreService

    let session = URLSession.shared


    fileprivate init(core: SBXCoreService, model: String) {
        self.query = SBXQueryBuilder(action: .find, domain: core.domain, model: model, size: 250)
        self.core = core
    }


    public func newGroupWithAnd() -> Find {
        self.query.newGroup(andOr: .and)
        return self
    }

    public func newGroupWithOr() -> Find {
        self.query.newGroup(andOr: .or)
        return self
    }


    public func andWhereIsEqual(field: String, value: Val) -> Find {
        self.query.addCondition(Condition(andOr: .and, field: field, op: .equal, value: value))
        return self
    }


    public func andWhereIsNotNull(field: String) -> Find {
        self.query.addCondition(Condition(andOr: .and, field: field, op: .isNotOp, value: .null()))
        return self
    }


    public func andWhereIsNull(field: String) -> Find {
        self.query.addCondition(Condition(andOr: .and, field: field, op: .isOp, value: .null()))
        return self
    }


    public func andWhereGreaterThan(field: String, value: Val) {
        self.query.addCondition(Condition(andOr: .and, field: field, op: .greaterThan, value: value))
    }

    public func andWhereLessThan(field: String, value: Val) {
        self.query.addCondition(Condition(andOr: .and, field: field, op: .lessThan, value: value))
    }

    public func andWhereGreaterOrEqualThan(field: String, value: Val) {
        self.query.addCondition(Condition(andOr: .and, field: field, op: .greaterOrEqualThan, value: value))
    }

    public func andWhereLessOrEqualThan(field: String, value: Val) {
        self.query.addCondition(Condition(andOr: .and, field: field, op: .lessOrEqualThan, value: value))
    }

    public func andWhereIsNotEqual(field: String, value: Val) {
        self.query.addCondition(Condition(andOr: .and, field: field, op: .notEqual, value: value))
    }

    public func andWhereStartsWith(field: String, value: String) {
        self.query.addCondition(Condition(andOr: .and, field: field, op: .like, value: .string("\(value)%")))
    }

    public func andWhereEndsWith(field: String, value: String) {
        self.query.addCondition(Condition(andOr: .and, field: field, op: .like, value: .string("%\(value)")))
    }


    public func andWhereContains(field: String, value: String) {
        // make the value a var
        var value = value

        if !value.isEmpty {
            value = value.split(separator: " ").joined(separator: "%")
        }

        self.query.addCondition(Condition(andOr: .and, field: field, op: .like, value: .string("%\(value)%")))
    }

    public func andWhereIn(field: String, values: [Val]) {
        self.query.addCondition(Condition(andOr: .and, field: field, op: .inside, value: .array(values)))
    }

    public func andWhereNotIn(field: String, values: [Val]) {
        self.query.addCondition(Condition(andOr: .and, field: field, op: .notInside, value: .array(values)))
    }

//    OR SECTION

    public func orWhereIsEqual(field: String, value: Val) -> Find {
        self.query.addCondition(Condition(andOr: .or, field: field, op: .equal, value: value))
        return self
    }


    public func orWhereIsNotNull(field: String) -> Find {
        self.query.addCondition(Condition(andOr: .or, field: field, op: .isNotOp, value: .null()))
        return self
    }


    public func orWhereIsNull(field: String) -> Find {
        self.query.addCondition(Condition(andOr: .or, field: field, op: .isOp, value: .null()))
        return self
    }


    public func orWhereGreaterThan(field: String, value: Val) -> Find {
        self.query.addCondition(Condition(andOr: .or, field: field, op: .greaterThan, value: value))
        return self
    }

    public func orWhereLessThan(field: String, value: Val) -> Find {
        self.query.addCondition(Condition(andOr: .or, field: field, op: .lessThan, value: value))
        return self
    }

    public func orWhereGreaterOrEqualThan(field: String, value: Val) -> Find {
        self.query.addCondition(Condition(andOr: .or, field: field, op: .greaterOrEqualThan, value: value))
        return self
    }

    public func orWhereLessOrEqualThan(field: String, value: Val) -> Find {
        self.query.addCondition(Condition(andOr: .or, field: field, op: .lessOrEqualThan, value: value))
        return self
    }

    public func orWhereIsNotEqual(field: String, value: Val) -> Find {
        self.query.addCondition(Condition(andOr: .or, field: field, op: .notEqual, value: value))
        return self
    }

    public func orWhereStartsWith(field: String, value: String) -> Find {
        self.query.addCondition(Condition(andOr: .or, field: field, op: .like, value: .string("\(value)%")))
        return self
    }

    public func orWhereEndsWith(field: String, value: String) -> Find {
        self.query.addCondition(Condition(andOr: .or, field: field, op: .like, value: .string("%\(value)")))
        return self
    }


    public func orWhereContains(field: String, value: String) -> Find {
        // make the value a var
        var value = value

        if !value.isEmpty {
            value = value.split(separator: " ").joined(separator: "%")
        }

        self.query.addCondition(Condition(andOr: .or, field: field, op: .like, value: .string("%\(value)%")))
        return self
    }

    public func orWhereIn(field: String, values: [Val]) -> Find {
        self.query.addCondition(Condition(andOr: .or, field: field, op: .inside, value: .array(values)))
        return self
    }

    public func orWhereNotIn(field: String, values: [Val]) -> Find {
        self.query.addCondition(Condition(andOr: .or, field: field, op: .notInside, value: .array(values)))
        return self
    }

    public func whereWith(keys: [String]) -> Find {
        keys.forEach {
            self.query.addKey(key: $0)
        }
        return self
    }

    public func fetch(models: [String]) -> Find {
        self.query.fetch(models: models)
        return self
    }

    public func set(page: Int) -> Find {
        self.query.set(page: page)
        return self
    }

    public func set(size: Int) -> Find {

        if size < 250 {
            self.query.set(size: size)
            return self
        }

        self.query.set(size: 250)
        return self
    }

    public func loadPage<T>(page: Int, completionHandler: @escaping (FindPageResponse<T>?, JSONError?) -> ()) {


        let req = core.buildRequest(query: self.set(page: page).query.compile(), params: nil, action: SBXAction.find, method: .POST)

        //hold a reference
        let strongSelf = self

        let task = session.dataTask(with: req) { (data: Data?, res: URLResponse?, err: Error?) in

            if let e = err {
                return completionHandler(nil, .error(e))
            }

            // we need the response code to be HTTP -> 200 (OK)
            if let response = res as? HTTPURLResponse, response.statusCode != 200 {
                return completionHandler(nil, .customError("Invalid Response code: \(response.statusCode)"))
            }


            guard let d = data else {
                return completionHandler(nil, .customError("Invalid Response From Server"))
            }


            do {
                guard let jsonData = try strongSelf.parseResponse(data: d) else {
                    return completionHandler(nil, .invalidJSON)
                }

                print("DATA OK?! \(String(data: jsonData, encoding: .utf8)!)")

                let decoder = JSONDecoder()
                let objects = try decoder.decode(FindPageResponse<T>.self, from: jsonData)

                return completionHandler(objects, nil)
            } catch let e as DecodingError {
                completionHandler(nil, .decodingError(e))
            } catch {
                completionHandler(nil, .error(error))
            }

        }

        task.resume()
    }

    private func parseResponse(data: Data) throws -> Data? {

        var json = try JSONSerialization.jsonObject(with: data, options: []) as! JSONObject

        let fResults = json["fetched_results"] as? JSONObject ?? JSONObject()

        guard let modelJSON = json["model"] as? [JSONObject] else {
            throw JSONError.invalidJSON
        }

        let modelData = try JSONSerialization.data(withJSONObject: modelJSON)
        let modelFields = try JSONDecoder().decode([FieldModel].self, from: modelData)

        guard let items = json["results"] as? [JSONObject] else {
            throw JSONError.invalidJSON
        }


        let jsonObjects = items.map { object in
            return modelFields.reduce(object) { (obj, field) in
                return bindFetched(field: field, obj: obj, fetchedObjects: fResults)
            }
        }

        json["results"] = jsonObjects


        return try JSONSerialization.data(withJSONObject: json)
    }

    @discardableResult private func bindFetched(field: FieldModel, obj: JSONObject, fetchedObjects: JSONObject) -> JSONObject {

        var obj = obj

        if let type = field.referenceTypeName,
           field.type == "REFERENCE",
           let refKey = (obj[field.name] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines),
           let f1 = fetchedObjects[type] as? [String: JSONObject],
           var refObject = f1[refKey] {

            if let subModel = field.referenceTypeModel {

                for subField in Array(subModel.values) {

                    if subField.type == "REFERENCE" {
                        refObject = bindFetched(field: subField, obj: refObject, fetchedObjects: fetchedObjects)
                    }

                }

            }

            obj[field.name] = refObject
        }

        return obj
    }

    public func loadAll<T: Codable>(completionHandler: @escaping ([T]?, JSONError?) -> ()) {

        self.loadPage(page: 1) { [weak self] (pageResponse: FindPageResponse<T>?, error: JSONError?) in


            guard let response = pageResponse, let strongSelf = self else {

                if let e = error {
                    return completionHandler(nil, .error(e))
                }

                return completionHandler(nil, .invalidJSON)
            }


            if !response.success {

                if let msg = response.error {
                    return completionHandler(nil, .customError(msg))
                }

                return completionHandler(nil, .invalidJSON)
            }

            guard let totalPages = response.totalPages, let results = response.results else {
                completionHandler(nil, .invalidJSON)
                return
            }

            if totalPages > 1 {
                let r: CountableClosedRange<Int> = 2...totalPages
                return strongSelf.loadAll(items: results, range: r, completionHandler: completionHandler)
            }

            completionHandler(response.results, nil)
        }


    }


}


private extension FindOperation {

    private func loadAll<T: Codable>(items: [T], range: CountableClosedRange<Int>, completionHandler: @escaping ([T]?, JSONError?) -> ()) {


        var resultList = items

        var errorBox: JSONError?


        let queue = DispatchQueue(label: "sbxcloud-pages", attributes: .concurrent)
        let pageGroup = DispatchGroup()


        for page in range {

            print("Page: \(page) START")

            pageGroup.enter()

            queue.async {

                self.loadPage(page: page, completionHandler: { (pageResult: FindPageResponse<T>?, error: Error?) in

                    defer{
                        pageGroup.leave()
                    }

                    print("Page: \(page) DONE")

                    if let e = error {
                        return errorBox = .error(e)
                    } else if let results = pageResult?.results {
                        resultList.append(contentsOf: results)
                        print(resultList.count)
                    }

                    print("Page: \(page) FINISHED")
                })
            }


        }

        print("waiting for all pages")
        queue.async {
            pageGroup.wait()
            print("DONE WITH ALL PAGES")
            completionHandler(resultList, errorBox)

        }


    }


}


public struct FindPageResponse<T: Codable>: Codable {


    public let success: Bool
    public let error: String?

    public let results: [T]?
    public let totalPages: Int?

    enum CodingKeys: String, CodingKey {
        case success
        case error
        case results
        case totalPages = "total_pages"
    }

}

public class CloudScriptRequest<T: Codable>: SBXRequest {

    public typealias ResponseType = Codable

    private var task: URLSessionDataTask?
    private let req: URLRequest
    private var isRunning = false
    private let session = URLSession(configuration: URLSessionConfiguration.default)
    private let completionHandler: (T?, JSONError?) -> ()

    init(req: URLRequest, cb: @escaping (T?, JSONError?) -> ()) {
        self.req = req
        self.completionHandler = cb
    }


    public func cancel() {

        if let dataTask = task, dataTask.state == .running {
            dataTask.cancel()
        }

    }

    public func send() {

        if isRunning {
            return
        }

        print("CloudScript:RUN")

        self.isRunning = true

        self.task = session.dataTask(with: self.req) { [weak self]  (data: Data?, res: URLResponse?, e: Error?) in

            print("CloudScript:DONE")

            if let error = e {
                self?.completionHandler(nil, JSONError.error(error))
                return
            }

            guard let d = data, let r = res as? HTTPURLResponse, r.statusCode == 200 else {
                self?.completionHandler(nil, JSONError.customError("Invalid response from server)"))
                return
            }


            do {

                let decoder = JSONDecoder()
                let tmp = try decoder.decode(T.self, from: d)
                self?.completionHandler(tmp, nil)
            } catch {
                print(error)
                self?.completionHandler(nil, .error(error))
            }


        }


        self.task?.resume()

    }


    public func run() {
        self.send()
    }

}


public final class SBXCoreService {

    let domain: Int
    let appKey: String
    let url = "sbxcloud.com"
    let scheme = "https"

    private var token: String?

    let sessionStatus: SessionStatus = .anonimous

    private let session = URLSession.shared


    enum SessionStatus {
        case authenticated
        case anonimous
    }


    private static func checkErrors(res: URLResponse?, err: Error?) -> JSONError? {

        if let e = err {
            return .error(e)
        }

        // we need the response code to be HTTP -> 200 (OK)
        if let response = res as? HTTPURLResponse, response.statusCode != 200 {
            return .customError("Invalid Response code: \(response.statusCode)")
        }


        return nil
    }


    public func doLogin(email: String, password: String, completionHandler: @escaping (SBXLoginResponse?, JSONError?) -> ()) {

        let body = [
            "login": email,
            "password": password,
            "domain": "\(self.domain)"
        ]


        let req = self.buildRequest(query: nil, params: body, action: SBXAction.userLogin, method: .GET)

        let strongSelf = self


        let task = session.dataTask(with: req) { (data: Data?, res: URLResponse?, err: Error?) in





            if let e = SBXCoreService.checkErrors(res: res, err: err) {
                return completionHandler(nil,e)
            }


            guard let d = data else {
                return completionHandler(nil, .customError("Invalid Response From Server"))
            }

            print(String(data:d, encoding: .utf8))


            do {

                let decoder = JSONDecoder()
                let loginResponse = try decoder.decode(SBXLoginResponse.self, from: d)

                guard loginResponse.success, let token = loginResponse.token else {
                    completionHandler(nil, .customError(loginResponse.error ?? "Invalid response"))
                    return
                }

                strongSelf.setToken(token: token)
                completionHandler(loginResponse, nil)


            } catch let e as DecodingError {
                completionHandler(nil, .decodingError(e))
            } catch {
                completionHandler(nil, .error(error))
            }

        }

        task.resume()

    }


    public init(domain: Int, appKey: String) {
        self.domain = domain
        self.appKey = appKey
    }

    @discardableResult public func setToken(token: String) -> SBXCoreService {
        self.token = token
        return self
    }


    public func runCloudScriptWith<T: Decodable>(key: String, params: JSONObject, autoRun: Bool = true, callback: @escaping (T?, JSONError?) -> ()) -> CloudScriptRequest<T> {


        let body: JSONObject = [
            "key": key,
            "params": params
        ]

        let req = self.buildRequest(query: body, params: nil, action: SBXAction.cloudscriptRun, method: .POST)

        let csRequest = CloudScriptRequest(req: req, cb: callback)

        if autoRun {
            csRequest.send()
        }

        return csRequest

    }

    @discardableResult public func find(model: String) -> Find {
        return FindOperation(core: self, model: model)
    }


}


public protocol SBXRequest {

    associatedtype ResponseType

    func send()

    func cancel()
}


private extension SBXCoreService {

    func buildRequest(query: JSONObject? = nil, params: [String: String]? = nil, action: SBXAction, method: HTTPMETHOD = .POST) -> URLRequest {

        var url = URLComponents()
        url.host = self.url
        url.path = action.rawValue
        url.scheme = self.scheme

        if let qParams = params {

            url.queryItems = qParams.map {
                return URLQueryItem(name: $0, value: $1)
            }

        }

        var clientReq = URLRequest(url: url.url!)


        if let q = query {
            clientReq.httpBody = try? JSONSerialization.data(withJSONObject: q)
            print(String(data: clientReq.httpBody!, encoding: .utf8)!)
        }


        var headers = [
            "accept-encoding": "gzip, deflate, br",
            "cache-control": "no-cache",
            "Pragma": "no-cache",
            "App-Key": appKey,
            "accept": "application/json, text/plain, */*",
            "Authority": "sbxcloud.com"
        ]


        if let t = token {
            headers["Authorization"] = "Bearer \(t)"
        }


        if method == .POST {
            headers["content-type"] = "application/json;charset=UTF-8"
        }


        headers.forEach {
            clientReq.addValue($1, forHTTPHeaderField: $0)
        }

        clientReq.httpMethod = method.rawValue



        return clientReq

    }

}


struct FieldModel: Codable {

    let id: Int
    let type: String
    let name: String
    let referenceTypeId: Int?
    let referenceTypeName: String?
    let referenceTypeModel: [String: FieldModel]?


    enum CodingKeys: String, CodingKey {
        case id
        case type
        case name
        case referenceTypeId = "reference_type"
        case referenceTypeName = "reference_type_name"
        case referenceTypeModel = "reference_model"
    }


}




