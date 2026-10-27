//
//  EnvironmentalValues.swift
//  STDemos
//
//  Created by Luca Pezzoni on 06/10/2026.
//

enum EnvironmentalType {
    case temperature
    case pressure
    case humidity
}

extension EnvironmentalType {
    func getImage(_ valueEnv: Double?) -> String {
        let fileName =
        if valueEnv != nil {
            switch(self) {
            case .temperature:
                "img_enviromental_temperature"
            case .pressure:
                "img_enviromental_pressure"
            case .humidity:
                "img_enviromental_humidity"
            }
        } else {
            switch(self) {
            case .temperature:
                "img_enviromental_temperature_missing"
            case .pressure:
                "img_enviromental_pressure_missing"
            case .humidity:
                "img_enviromental_humidity_missing"
            }
        }
        
        return fileName
    }
    
    func getLabel(_ valueEnv: Double?, offset: Double = 0.0, alternative: Bool = false) -> String {
        let labelValue =
        if let valueEnv {
            switch(self) {
            case .temperature:
                if alternative {
                    String(format: "%.2f [°F]", fromCelsiusToFahrenheit(valueEnv)+offset)
                } else {
                    String(format: "%.2f [°C]", valueEnv+offset)
                }
            case .pressure:
                String(format: "%.2f [mBar]",valueEnv+offset)
            case .humidity:
                String(format: "%.2f [%%]", valueEnv+offset)
            }
        } else {
            switch(self) {
            case .temperature:
                String(format: "-.- [%@]", alternative ? "°F" : "°C")
            case .pressure:
                String(format: "-.- [mBar]")
            case .humidity:
                "-.- [%%]"
            }
        }
        
        return labelValue
    }
    
    
    private func fromCelsiusToFahrenheit(_ celsius: Double) -> Double {
        return (celsius * 9.0 / 5.0) + 32.0
    }
}

