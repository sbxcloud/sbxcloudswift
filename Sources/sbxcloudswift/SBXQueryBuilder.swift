
/**
 *  SBXQueryBuilder
 *  Copyright (c) 2017 Hans Ospina <hansospina@gmail.com>
 *  Licensed under the MIT license, see LICENSE file
 */

import Foundation

public enum Val: ExpressibleByStringLiteral,
        ExpressibleByIntegerLiteral,
        ExpressibleByBooleanLiteral,
        ExpressibleByFloatLiteral,
        ExpressibleByNilLiteral {


    public init(stringLiteral value: StringLiteralType) {
        self = .string(value)
    }

    public init(integerLiteral value: IntegerLiteralType) {
        self = .int(value)
    }

    public init(floatLiteral value: FloatLiteralType) {
        self = .float(value)
    }

    public init(booleanLiteral value: BooleanLiteralType) {
        self = .boolean(value)
    }

    public init(nilLiteral: ()) {
        self = .null()
    }

    case array([Val])
    case float(Double)
    case int(Int)
    case string(String)
    case text(String)
    case boolean(Bool)
    case date(Date)
    case null()
}

struct Condition {
    var andOr: AndOr
    var field: String
    var op: Operator
    var val: Val


    init(andOr: AndOr = .and, field: String, op: Operator = .equal, value: Val) {
        self.andOr = andOr
        self.field = field
        self.op = op
        self.val = value
    }

}

struct ConditionGroup {
    var andOr: AndOr = .or
    var conditions = [Condition]()

    init(andOr: AndOr) {
        self.andOr = andOr
    }
}

enum AndOr: String {
    case and = "AND"
    case or = "OR"
}

enum Operator: String {
    case equal = "="
    case notEqual = "!="
    case like = "LIKE"
    case lessThan = "<"
    case greaterThan = ">"
    case greaterOrEqualThan = ">="
    case lessOrEqualThan = "<="
    case isNotOp = "IS NOT"
    case isOp = "IS"
    case notInside = "NOT IN"
    case inside = "IN"
}

enum SBXAction: String {
    case insert = "/api/data/v1/row/add"
    case delete = "/api/data/v1/row/delete"
    case find = "/api/data/v1/row/find"
    case update = "/api/data/v1/row/update"
    case cloudscriptRun = "/api/cloudscript/v1/run"
}


public final class SBXQueryBuilder {


    struct Config {
        var action: SBXAction
        var domain: Int
        var model: String
        var page: Int
        var size: Int
        var fetch: [String]
    }

    var config: Config

    private var groups: [ConditionGroup]?

    private var keys: [String]?

    private var objects: [[String: Any?]]?


    private func checkObjects() -> Bool {

        if let _ = keys {
            self.keys = nil
        }

        if let _ = groups {
            self.groups = nil
        }

        if objects == nil {
            self.objects = [[String: Any?]]()
        }


        // can only work with objects for insert and update
        return config.action == .insert || config.action == .update
    }

    private func checkKeys() -> Bool {

        if let _ = objects {
            objects = nil
        }

        if let _ = groups {
            groups = nil
        }

        if keys == nil {
            keys = [String]()
        }


        // can only use keys for find or delete
        return config.action == .find || config.action == .delete
    }


    private func checkGroups() -> Bool {

        if let _ = keys {
            keys = nil
        }

        if let _ = objects {
            objects = nil
        }

        if groups == nil {
            groups = [ConditionGroup]()
        }

        // SBXQueryBuilder will break if the user tried to add a groups to a insert/update
        return config.action == .find || config.action == .delete
    }

    func set(page: Int) {
        self.config.page = page
    }

    func set(size: Int) {
        self.config.size = size < 250 ? size : 250
    }

    func fetch( models: [String]){
        self.config.fetch = models
    }

    @discardableResult func addObject(obj: [String: Any?]) -> SBXQueryBuilder? {

        if checkObjects() {
            objects!.append(obj)
            return self
        }

        return nil
    }

    @discardableResult func addCondition(_ obj: Condition) -> SBXQueryBuilder? {

        if checkGroups() {

            if groups!.isEmpty {
                let _ = newGroup(andOr: .and)
            }

            groups![groups!.count - 1].conditions.append(obj)
            return self
        }

        return nil
    }


    @discardableResult func newGroup(andOr: AndOr) -> SBXQueryBuilder? {

        if checkGroups() {
            groups!.append(ConditionGroup(andOr: andOr))
            return self
        }

        return nil
    }

    @discardableResult func addKey(key: String) -> SBXQueryBuilder? {

        if checkKeys() {
            keys!.append(key)
            return self
        }

        // SBXQueryBuilder will break if the user tried to add a key to a insert/update
        return nil
    }

    init(action: SBXAction, domain: Int, model: String, page: Int = 1, size: Int = 250) {
        self.config = Config(action: action, domain: domain, model: model, page: page, size: size, fetch: [])
    }

    func compile() -> [String: Any] {

        var json: [String: Any] = [
            "domain": config.domain,
            "row_model": config.model,
            "page": config.page,
            "size": config.size
        ]

        print(json)
        if let tmpGroups = groups {

            var groupList = [[String: Any]]()

            for g in tmpGroups {

                var tmpConditions = [Any]()

                for c in g.conditions {


                    let value: Any

                    switch c.val {
                    case let Val.date(dateValue):
                        value = dateValue
                    case let Val.string(stringValue):
                        value = stringValue
                    case let Val.text(textValue):
                        value = textValue
                    case let Val.int(intValue):
                        value = intValue
                    case let Val.float(floatValue):
                        value = floatValue
                    case let Val.boolean(boolValue):
                        value = boolValue
                    default:
                        value = NSNull()
                    }

                    let tmp: [String: Any] = [
                        "ANDOR": c.andOr.rawValue,
                        "FIELD": c.field,
                        "OP": c.op.rawValue,
                        "VAL": value
                    ]

                    tmpConditions.append(tmp)
                }

                let tmpGroup: [String: Any] = [
                    "ANDOR": g.andOr.rawValue,
                    "GROUP": tmpConditions
                ]

                groupList.append(tmpGroup)
            }


            json["where"] = groupList

        } else if let tmpKeys = keys {
            json["where"] = ["keys": tmpKeys]
        } else if let tmpObjects = objects {
            json["rows"] = tmpObjects
        }

        return json
    }

}
