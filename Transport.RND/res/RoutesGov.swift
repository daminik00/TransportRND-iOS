// To parse the JSON, add this file to your project and do:
//
//   let routesGov = try? JSONDecoder().decode(RoutesGov.self, from: jsonData)
//
// To read values from URLs:
//
//   let task = URLSession.shared.routesGovTask(with: url) { routesGov, response, error in
//     if let routesGov = routesGov {
//       ...
//     }
//   }
//   task.resume()

import Foundation

typealias RoutesGov = [RoutesGovElement]

struct RoutesGovElement: Codable {
    let objectName: String
    let bus: Bus
    let tram: TramUnion
    let trolleybus: TrolleybusUnion
    let shuttleBus: Bus
    let latitude, longitude: Double

    enum CodingKeys: String, CodingKey {
        case objectName = "object_name"
        case bus, tram, trolleybus
        case shuttleBus = "shuttle_bus"
        case latitude, longitude
    }
}

enum Bus: Codable {
    case integer(Int)
    case string(String)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(Int.self) {
            self = .integer(x)
            return
        }
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        throw DecodingError.typeMismatch(Bus.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for Bus"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .integer(let x):
            try container.encode(x)
        case .string(let x):
            try container.encode(x)
        }
    }
}

enum TramUnion: Codable {
    case enumeration(TramEnum)
    case integer(Int)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(Int.self) {
            self = .integer(x)
            return
        }
        if let x = try? container.decode(TramEnum.self) {
            self = .enumeration(x)
            return
        }
        throw DecodingError.typeMismatch(TramUnion.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for TramUnion"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .enumeration(let x):
            try container.encode(x)
        case .integer(let x):
            try container.encode(x)
        }
    }
}

enum TramEnum: String, Codable {
    case empty = ""
    case the104 = "10, 4"
    case the1041 = "10, 4, 1"
    case the10641 = "10, 6, 4, 1"
    case the107 = "10, 7"
    case the11064 = "1, 10, 6, 4"
    case the41 = "4, 1"
    case the41106 = "4, 1, 10, 6"
    case the7641 = "7, 6, 4, 1"
}

enum TrolleybusUnion: Codable {
    case enumeration(TrolleybusEnum)
    case integer(Int)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(Int.self) {
            self = .integer(x)
            return
        }
        if let x = try? container.decode(TrolleybusEnum.self) {
            self = .enumeration(x)
            return
        }
        throw DecodingError.typeMismatch(TrolleybusUnion.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for TrolleybusUnion"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .enumeration(let x):
            try container.encode(x)
        case .integer(let x):
            try container.encode(x)
        }
    }
}

enum TrolleybusEnum: String, Codable {
    case empty = ""
    case the128 = "12, 8"
    case the159 = "1, 5, 9"
    case the19 = "1, 9"
    case the21229 = "2, 1, 22, 9"
    case the22129 = "22, 1, 2, 9"
    case the222 = "22, 2"
    case the2291 = "22, 9, 1"
    case the22921 = "22, 9, 2, 1"
    case the22951 = "22, 9, 5, 1"
    case the51 = "5, 1"
    case the91 = "9, 1"
    case the915 = "9, 1, 5"
}

// MARK: - URLSession response handlers

extension URLSession {
    fileprivate func codableTask<T: Codable>(with url: URL, completionHandler: @escaping (T?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return self.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completionHandler(nil, response, error)
                return
            }
            completionHandler(try? JSONDecoder().decode(T.self, from: data), response, nil)
        }
    }

    func routesGovTask(with url: URL, completionHandler: @escaping (RoutesGov?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return self.codableTask(with: url, completionHandler: completionHandler)
    }
}
