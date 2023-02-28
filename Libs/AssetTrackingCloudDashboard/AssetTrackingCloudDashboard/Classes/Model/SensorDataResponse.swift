//
//  SensorDataResponse.swift
//  AssetTrackingCloudDashboard
//
//  Created by Klaus Lanzarini on 06/11/2020.
//

import Foundation
import AssetTrackingDataModel

struct SensorDataResponse: Decodable {
    let values: [SensorDataResponseItem]
}

// MARK: - Events value
struct Vevents: Codable {
    let et: Et
    let m: M
    let l: String?
}

enum Et: String, Codable {
    case threshold = "threshold"
}

enum M: String, Codable {
    case orientation = "orientation"
    case wakeup = "wakeup"
    case tilt = "tilt"
}

// MARK: - Geolocation Value
struct Vgeolocation: Decodable {
    let lon, lat, ele: Double
}

public enum SensorDataResponseItem {
    case telemetry(SensorDataSample)
    case event(EventDataSample)
    case location(Location)
    
    
    var sensor: SensorDataSample? {
        guard case .telemetry(let data) = self else { return nil }
        return data
    }
    
    var event: EventDataSample? {
        guard case .event(let data) = self else { return nil }
        return data
    }
    
    var location: Location? {
        guard case .location(let data) = self else { return nil }
        return data
    }
}

extension SensorDataResponseItem: Decodable {
    enum Domains: String {
        case tem
        case pre
        case hum
        case gnss
        case evt
    }
    
    enum ValueCodingKeys: String, CodingKey {
        case ts
        case t
        case v
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ValueCodingKeys.self)
        let date = try container.decode(Double.self, forKey: .ts).date
        let domainRaw = try container.decode(String.self, forKey: .t)
        
        guard let domain = Domains(rawValue: domainRaw) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [ValueCodingKeys.t],
                                                                    debugDescription: "Missing domain"))
        }
        
        switch domain {
        case .gnss:
            let value = try container.decode(Vgeolocation.self, forKey: .v)
            self = Self.locationFrom(date: date, measure: "gnss", value: value)
        case .tem:
            let value = try container.decode(Float.self, forKey: .v)
            self = Self.sensorFrom(date: date, measure: "tem", value: value)
        case .pre:
            let value = try container.decode(Float.self, forKey: .v)
            self = Self.sensorFrom(date: date, measure: "pre", value: value)
        case .hum:
            let value = try container.decode(Float.self, forKey: .v)
            self = Self.sensorFrom(date: date, measure: "hum", value: value)
        case .evt:
            let value = try container.decode(Vevents.self, forKey: .v)
            self = Self.eventFrom(date: date, measure: "evt", value: value)
        }
    }
    
    private static func sensorFrom(date: Date, measure: String, value: Float) -> SensorDataResponseItem {
        let sample: SensorDataSample
        
        switch measure {
        case SensorDataSample.MappingKeys.temperature.decode:
            sample = SensorDataSample(date: date, temperature: value)
        case SensorDataSample.MappingKeys.pressure.decode:
            sample = SensorDataSample(date: date, pressure: value)
        case SensorDataSample.MappingKeys.humidity.decode:
            sample = SensorDataSample(date: date, humidity: value)
        default:
            sample = SensorDataSample(date: date)
        }
        
        return .telemetry(sample)
    }
    
    private static func eventFrom(date: Date, measure: String, value: Vevents) -> SensorDataResponseItem {
        let sample: EventDataSample
        
        let eventType = value.m
        
        switch eventType {
        case .wakeup:
            sample = EventDataSample(date: date, accelerationEvents: [.wakeUp])
        case .tilt:
            sample = EventDataSample(date: date, accelerationEvents: [.tilt])
        case .orientation:
            sample = EventDataSample(date: date, accelerationEvents: [.orientation], currentOrientation: SensorOrientation.fromJson(string: value.l!))
        default:
            sample = EventDataSample(date: date)
        }
        
        return .event(sample)
    }
    
    private static func locationFrom(date: Date, measure: String, value: Vgeolocation) -> SensorDataResponseItem {
        let sample: Location
        
        sample = Location(latitude: Double(value.lat), longitude: Double(value.lon), altitude: Double(value.ele))
        
        return .location(sample)
    }
}
