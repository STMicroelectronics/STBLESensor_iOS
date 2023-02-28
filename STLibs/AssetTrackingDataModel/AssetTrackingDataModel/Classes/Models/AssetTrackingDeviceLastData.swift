//
//  AssetTrackingDeviceLastData.swift

import Foundation

/** Telemetry */
public struct LastTelemetryData: Decodable {
    public let ts: Double?
    public let t: String?
    public let v: ObjectOrDouble?
    public let mtd: MtdObject?

    enum CodingKeys: String, CodingKey {
        case ts = "ts"
        case t = "t"
        case v = "v"
        case mtd = "mtd"
    }
    
    public init(ts: Double?, t: String?, v: ObjectOrDouble?, mtd: MtdObject?) {
        self.ts = ts
        self.t = t
        self.v = v
        self.mtd = mtd
    }
}

public enum ObjectOrDouble: Decodable, Equatable {
    public static func == (lhs: ObjectOrDouble, rhs: ObjectOrDouble) -> Bool {
        true
    }
    
    case valueObject(ValueObject)
    case double(Double)
    
    public init(from decoder: Decoder) throws {
        if let double = try? decoder.singleValueContainer().decode(Double.self) {
            self = .double(double)
            return
        }
        if let valueObject = try? decoder.singleValueContainer().decode(ValueObject.self) {
            self = .valueObject(valueObject)
            return
        }
        throw Error.couldNotFindStringOrDouble
    }
    enum Error: Swift.Error {
        case couldNotFindStringOrDouble
    }
    
    public func getDoubleValue() -> Double? {
            switch self {
            case .double(let num):
                return num
            
            case .valueObject(_):
                return nil
            }
    }
    
}

public struct ValueObject: Codable {
    public let x: Double?
    public let y: Double?
    public let z: Double?
    
    enum CodingKeys: String, CodingKey {
        case x = "x"
        case y = "y"
        case z = "z"
    }
    
    public init(x: Double?, y: Double?, z: Double?) {
        self.x = x
        self.y = y
        self.z = z
    }
}

public struct MtdObject: Codable {
    public let tech: String?
    
    enum CodingKeys: String, CodingKey {
        case tech = "tech"
    }
    
    public init(tech: String?) {
        self.tech = tech
    }
}


/** Geolocation */
public struct LastGeolocationData: Decodable {
    public let ts: Double?
    public let t: String?
    public let v: LatLonAltValues?

    enum CodingKeys: String, CodingKey {
        case ts = "ts"
        case t = "t"
        case v = "v"
    }
    
    public init(ts: Double?, t: String?, v: LatLonAltValues?) {
        self.ts = ts
        self.t = t
        self.v = v
    }
}

public struct LatLonAltValues: Codable {
    public let lon: Double?
    public let lat: Double?
    public let ele: Double?

    enum CodingKeys: String, CodingKey {
        case lon = "lon"
        case lat = "lat"
        case ele = "ele"
    }
    
    public init(lon: Double?, lat: Double?, ele: Double?) {
        self.lon = lon
        self.lat = lat
        self.ele = ele
    }
}
