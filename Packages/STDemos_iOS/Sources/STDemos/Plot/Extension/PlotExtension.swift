//
//  PlotExtension.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import STUI
import STBlueSDK

extension AnyFeatureSample {
    func toPlotEntry(sample: AnyFeatureSample?) -> PlotEntry? {
        if let sample = sample as? FeatureSample<AccelerationData>,
            let data = sample.data,
            let accX = data.accelerationX .value,
            let accY = data.accelerationY.value,
            let accZ = data.accelerationZ.value {
            return PlotEntry(
                x: Int(sample.timestamp),
                y: [accX, accY, accZ]
            )
        } else if let sample = sample as? FeatureSample<CompassData>,
                  let data = sample.data,
                  let angleValue = data.angle.value {
            return PlotEntry(
                x: Int(sample.timestamp),
                y: [angleValue]
            )
        } else if let sample = sample as? FeatureSample<DirectionOfArrivalData>,
                  let data = sample.data,
                  let angleValue = data.angle.value {
            return PlotEntry(
                x: Int(sample.timestamp),
                y: [Float(angleValue)]
            )
        } else if let sample = sample as? FeatureSample<GyroscopeData>,
                  let data = sample.data,
                  let gyroX = data.gyroX.value,
                  let gyroY = data.gyroY.value,
                  let gyroZ = data.gyroZ.value {
            return PlotEntry(
                x: Int(sample.timestamp),
                y: [gyroX, gyroY, gyroZ]
            )
        } else if let sample = sample as? FeatureSample<HumidityData>,
                  let data = sample.data,
                  let humidityValue = data.humidity.value {
            return PlotEntry(
                x: Int(sample.timestamp),
                y: [humidityValue]
            )
        } else if let sample = sample as? FeatureSample<LuminosityData>,
                  let data = sample.data,
                  let luminosityValue = data.luminosity.value {
            return PlotEntry(
                x: Int(sample.timestamp),
                y: [Float(luminosityValue)]
            )
        } else if let sample = sample as? FeatureSample<MagnetometerData>,
                  let data = sample.data,
                  let magX = data.magX.value,
                  let magY = data.magY.value,
                  let magZ = data.magZ.value {
            return PlotEntry(
                x: Int(sample.timestamp),
                y: [magX, magY, magZ]
            )
        } else if let sample = sample as? FeatureSample<SensorFusionData>,
                  let data = sample.data,
                  let qi = data.quaternionI.value,
                  let qj = data.quaternionJ.value,
                  let qs = data.quaternionS.value,
                  let qk = data.quaternionK.value {
            return PlotEntry(
                x: Int(sample.timestamp),
                y: [qi, qj, qs, qk]
            )
        } else if let sample = sample as? FeatureSample<SensorFusionCompactData>,
                  let data = sample.data,
                  let qi = data.samples[0].quaternionI.value,
                  let qj = data.samples[0].quaternionJ.value,
                  let qs = data.samples[0].quaternionS.value,
                  let qk = data.samples[0].quaternionK.value {
            return PlotEntry(
                x: Int(sample.timestamp),
                y: [qi, qj, qs, qk]
            )
        } else if let sample = sample as? FeatureSample<MicLevelsData>,
                  let data = sample.data {
            var micLevels: [Float] = []
            data.micLevels.forEach { level in
                if let value = level.value {
                    micLevels.append(Float(value))
                }
            }
           return PlotEntry(
               x: Int(sample.timestamp),
               y: micLevels
           )
        } else if let sample = sample as? FeatureSample<MotionIntensityData>,
                  let data = sample.data,
                  let intensityValue = data.motionIntensity.value {
           return PlotEntry(
               x: Int(sample.timestamp),
               y: [Float(intensityValue)]
           )
        } else if let sample = sample as? FeatureSample<ProximityData>,
                  let data = sample.data,
                  let distanceValue = data.distance.value {
           return PlotEntry(
               x: Int(sample.timestamp),
               y: [Float(distanceValue)]
           )
        } else if let sample = sample as? FeatureSample<PressureData>,
                  let data = sample.data,
                  let pressure = data.pressure.value {
            return PlotEntry(
                x: Int(sample.timestamp),
                y: [pressure]
            )
        } else if let sample = sample as? FeatureSample<TemperatureData>,
                  let data = sample.data,
                  let temperatureValue = data.temperature.value {
            return PlotEntry(
                x: Int(sample.timestamp),
                y: [temperatureValue]
            )
        } else if let sample = sample as? FeatureSample<EulerAngleData>,
                  let data = sample.data,
                  let yaw = data.yaw.value,
                  let pitch = data.pitch.value,
                  let roll = data.roll.value {
            return PlotEntry(
                x: Int(sample.timestamp),
                y: [yaw, pitch, roll]
            )
        } else if let sample = sample as? FeatureSample<MemsNormData>,
                  let data = sample.data,
                  let norm = data.norm.value {
            return PlotEntry(
                x: Int(sample.timestamp),
                y: [norm]
            )
        }
//        else if let sample = sample as? FeatureSample<QvarData>,
//                  let data = sample.data,
//                  let qvar = data.qvar.value,
//                  let dqvar = data.dqvar.value {
//            return PlotEntry(
//                x: Int(sample.timestamp),
//                y: [qvar, dqvar]
//            )
//        }
//        else if let sample = sample as? FeatureSample<ToFMultiObjectDelegate>,
//                  let data = sample.data,
//                  let distances = data.distances.value,
//                  let objectPresence = data.presence.value {
//            return PlotEntry(
//                x: Int(sample.timestamp),
//                y: [qvar, dqvar]
//            )
//        }
        else if let sample = sample as? FeatureSample<EventCounterData>,
                let data = sample.data,
                let counter = data.counter.value {
            return PlotEntry(
                x: Int(sample.timestamp),
                y: [Float(counter)]
            )
        }
        return nil
    }
    
    func toPlotDescription(sample: AnyFeatureSample?) -> String? {
        if let sample = sample as? FeatureSample<AccelerationData>,
           let data = sample.data,
           let accX = data.accelerationX .value,
           let accY = data.accelerationY.value,
           let accZ = data.accelerationZ.value {
            return "TS:\(sample.timestamp) X:\(accX) Y:\(accY) Z:\(accZ)"
        } else if let sample = sample as? FeatureSample<CompassData>,
                  let data = sample.data,
                  let angleValue = data.angle.value {
            return "TS:\(sample.timestamp) Angle:\(angleValue)"
        } else if let sample = sample as? FeatureSample<DirectionOfArrivalData>,
                  let data = sample.data,
                  let angleValue = data.angle.value {
            return "TS:\(sample.timestamp) Angle:\(angleValue)"
        } else if let sample = sample as? FeatureSample<GyroscopeData>,
                  let data = sample.data,
                  let gyroX = data.gyroX.value,
                  let gyroY = data.gyroY.value,
                  let gyroZ = data.gyroZ.value {
            return "TS:\(sample.timestamp) X:\(gyroX) Y:\(gyroY) Z:\(gyroZ)"
        } else if let sample = sample as? FeatureSample<HumidityData>,
                  let data = sample.data,
                  let humidityValue = data.humidity.value {
            return "TS:\(sample.timestamp) Humidity:\(humidityValue)"
        } else if let sample = sample as? FeatureSample<LuminosityData>,
                  let data = sample.data,
                  let luminosityValue = data.luminosity.value {
            return "TS:\(sample.timestamp) Lux:\(luminosityValue)"
        } else if let sample = sample as? FeatureSample<MagnetometerData>,
                  let data = sample.data,
                  let magX = data.magX.value,
                  let magY = data.magY.value,
                  let magZ = data.magZ.value {
            return "TS:\(sample.timestamp) X:\(magX) Y:\(magY) Z:\(magZ)"
        } else if let sample = sample as? FeatureSample<SensorFusionData>,
                  let data = sample.data,
                  let qi = data.quaternionI.value,
                  let qj = data.quaternionJ.value,
                  let qs = data.quaternionS.value,
                  let qk = data.quaternionK.value {
            return "TS:\(sample.timestamp) qi:\(qi) qj:\(qj) qs:\(qs), qk:\(qk)"
        } else if let sample = sample as? FeatureSample<SensorFusionCompactData>,
                  let data = sample.data,
                  let qi = data.samples[0].quaternionI.value,
                  let qj = data.samples[0].quaternionJ.value,
                  let qs = data.samples[0].quaternionS.value,
                  let qk = data.samples[0].quaternionK.value {
            return "TS:\(sample.timestamp) qi:\(qi) qj:\(qj) qs:\(qs), qk:\(qk)"
        } else if let sample = sample as? FeatureSample<MicLevelsData>,
                  let data = sample.data {
            var micLevels: [Float] = []
            data.micLevels.forEach { level in
                if let value = level.value {
                    micLevels.append(Float(value))
                }
            }
            var desc = "TS:\(sample.timestamp)"
            for i in 0..<micLevels.count {
                desc.append(" mic\(i):\(micLevels[i])")
            }
            return desc
        } else if let sample = sample as? FeatureSample<MotionIntensityData>,
                  let data = sample.data,
                  let intensityValue = data.motionIntensity.value {
            return "TS:\(sample.timestamp) Intensity:\(intensityValue)"
        } else if let sample = sample as? FeatureSample<ProximityData>,
                  let data = sample.data,
                  let distanceValue = data.distance.value {
            return "TS:\(sample.timestamp) mm:\(distanceValue)"
        } else if let sample = sample as? FeatureSample<PressureData>,
                  let data = sample.data,
                  let pressure = data.pressure.value {
            return "TS:\(sample.timestamp) Pressure:\(pressure)"
        } else if let sample = sample as? FeatureSample<TemperatureData>,
                  let data = sample.data,
                  let temperatureValue = data.temperature.value {
            return "TS:\(sample.timestamp) Temperature:\(temperatureValue)"
        } else if let sample = sample as? FeatureSample<EulerAngleData>,
                  let data = sample.data,
                  let yaw = data.yaw.value,
                  let pitch = data.pitch.value,
                  let roll = data.roll.value {
            return "TS:\(sample.timestamp) Yaw:\(yaw), Pitch:\(pitch), Roll:\(roll)"
        } else if let sample = sample as? FeatureSample<MemsNormData>,
                  let data = sample.data,
                  let norm = data.norm.value {
            return "TS:\(sample.timestamp) Norm:\(norm)"
        }
//        else if let sample = sample as? FeatureSample<QvarData>,
//                  let data = sample.data,
//                  let qvar = data.qvar.value,
//                  let dqvar = data.dqvar.value {
//            return PlotEntry(
//                x: Int(sample.timestamp),
//                y: [qvar, dqvar]
//            )
//        }
//        else if let sample = sample as? FeatureSample<ToFMultiObjectDelegate>,
//                  let data = sample.data,
//                  let distances = data.distances.value,
//                  let objectPresence = data.presence.value {
//            return PlotEntry(
//                x: Int(sample.timestamp),
//                y: [qvar, dqvar]
//            )
//        }
        else if let sample = sample as? FeatureSample<EventCounterData>,
                let data = sample.data,
                let counter = data.counter.value {
            return "TS:\(sample.timestamp) #:\(counter)"
        }
        return nil
    }
    
    func toPlotConfiguration(sample: AnyFeatureSample?) -> [LineConfig]? {
        if sample is FeatureSample<AccelerationData> {
            return [LineConfig(name: "X", color: ColorLayout.blue.light),
                    LineConfig(name: "Y", color: ColorLayout.red.light),
                    LineConfig(name: "Z", color: ColorLayout.green.light)]
        } else if sample is FeatureSample<CompassData> {
            return [LineConfig(name: "Angle (°)", color: ColorLayout.blue.light)]
        } else if sample is FeatureSample<DirectionOfArrivalData> {
            return [LineConfig(name: "Angle (°)", color: ColorLayout.blue.light)]
        } else if sample is FeatureSample<GyroscopeData> {
            return [LineConfig(name: "X", color: ColorLayout.blue.light),
                    LineConfig(name: "Y", color: ColorLayout.red.light),
                    LineConfig(name: "Z", color: ColorLayout.green.light)]
        } else if sample is FeatureSample<HumidityData> {
            return [LineConfig(name: "Humidity %", color: ColorLayout.blue.light)]
        } else if sample is FeatureSample<LuminosityData> {
            return [LineConfig(name: "Lux", color: ColorLayout.blue.light)]
        } else if sample is FeatureSample<MagnetometerData>  {
            return [LineConfig(name: "X", color: ColorLayout.blue.light),
                    LineConfig(name: "Y", color: ColorLayout.red.light),
                    LineConfig(name: "Z", color: ColorLayout.green.light)]
        } else if sample is FeatureSample<SensorFusionData> {
            return [LineConfig(name: "qi", color: ColorLayout.blue.light),
                    LineConfig(name: "qj", color: ColorLayout.red.light),
                    LineConfig(name: "qk", color: ColorLayout.green.light),
                    LineConfig(name: "qs", color: ColorLayout.ochre.light)]
        } else if sample is FeatureSample<SensorFusionCompactData> {
            return [LineConfig(name: "qi", color: ColorLayout.blue.light),
                    LineConfig(name: "qj", color: ColorLayout.red.light),
                    LineConfig(name: "qk", color: ColorLayout.green.light),
                    LineConfig(name: "qs", color: ColorLayout.ochre.light)]
        } else if sample is FeatureSample<MicLevelsData> {
            var lineConfigs: [LineConfig] = []
            let micLevelsPlotEntry = toPlotEntry(sample: sample)
            if let mics = micLevelsPlotEntry?.y.count {
                for i in 0..<mics {
                    lineConfigs.append(LineConfig(name: "mic\(i)", color: lineConfigColors[i]))
                }
            }
            return lineConfigs
        } else if sample is FeatureSample<MotionIntensityData> {
            return [LineConfig(name: "Intensity", color: ColorLayout.blue.light)]
        } else if sample is FeatureSample<ProximityData> {
            return [LineConfig(name: "Distance (mm)", color: ColorLayout.blue.light)]
        } else if sample is FeatureSample<PressureData> {
            return [LineConfig(name: "Pressure mbar", color: ColorLayout.blue.light)]
        } else if sample is FeatureSample<TemperatureData> {
            return [LineConfig(name: "Temperature °C", color: ColorLayout.blue.light)]
        } else if sample is FeatureSample<EulerAngleData> {
            return [LineConfig(name: "yaw", color: ColorLayout.blue.light),
                    LineConfig(name: "pitch", color: ColorLayout.red.light),
                    LineConfig(name: "roll", color: ColorLayout.green.light)]
        } else if sample is FeatureSample<MemsNormData> {
            return [LineConfig(name: "Norm", color: ColorLayout.blue.light)]
        }
//        else if sample is FeatureSample<QvarData> {
//            return [LineConfig(name: "qvar", color: ColorLayout.blue.light),
//                    LineConfig(name: "dqvar", color: ColorLayout.red.light)]
//        }
//        else if sample is FeatureSample<ToFMultiObjectDelegate> {
//            return nil
//        }
        else if sample is FeatureSample<EventCounterData> {
            return [LineConfig(name: "Counter #", color: ColorLayout.blue.light)]
        }
        return nil
    }
    
    func toPlotAxisLabel(sample: AnyFeatureSample?) -> String? {
        if let sample = sample as? FeatureSample<AccelerationData>,
           let data = sample.data,
           let uom = data.accelerationX.uom {
            return uom
        } else if let sample = sample as? FeatureSample<CompassData> {
            return "Degree"
        } else if let sample = sample as? FeatureSample<DirectionOfArrivalData>,
                  let data = sample.data,
                  let uom = data.angle.uom {
            return uom
        } else if let sample = sample as? FeatureSample<GyroscopeData>,
                  let data = sample.data,
                  let uom = data.gyroX.uom {
            return uom
        } else if let sample = sample as? FeatureSample<HumidityData>,
                  let data = sample.data,
                  let uom = data.humidity.uom {
            return uom
        } else if let sample = sample as? FeatureSample<LuminosityData>,
                  let data = sample.data,
                  let uom = data.luminosity.uom {
            return uom
        } else if let sample = sample as? FeatureSample<MagnetometerData>,
                  let data = sample.data,
                  let uom = data.magX.uom {
            return uom
        } else if let sample = sample as? FeatureSample<SensorFusionData>,
                  let data = sample.data,
                  let uom = data.quaternionI.uom {
            return uom
        } else if let sample = sample as? FeatureSample<SensorFusionCompactData>,
                  let data = sample.data,
                  let uom = data.samples[0].quaternionI.uom {
            return uom
        } else if let sample = sample as? FeatureSample<MicLevelsData>,
                  let data = sample.data {
            return data.micLevels.first?.uom
        } else if let sample = sample as? FeatureSample<MotionIntensityData>,
                  let data = sample.data,
                  let uom = data.motionIntensity.uom {
            return uom
        } else if let sample = sample as? FeatureSample<ProximityData>,
                  let data = sample.data,
                  let uom = data.distance.uom {
            return uom
        } else if let sample = sample as? FeatureSample<PressureData>,
                  let data = sample.data,
                  let uom = data.pressure.uom {
            return uom
        } else if let sample = sample as? FeatureSample<TemperatureData>,
                  let data = sample.data,
                  let uom = data.temperature.uom {
            return uom
        } else if let sample = sample as? FeatureSample<EulerAngleData>,
                  let data = sample.data,
                  let uom = data.pitch.uom {
            return uom
        } else if let sample = sample as? FeatureSample<MemsNormData>,
                  let data = sample.data,
                  let uom = data.norm.uom {
            return uom
        }
//        else if let sample = sample as? FeatureSample<QvarData>,
//                  let data = sample.data,
//                  let uom = data.qvar.uom {
//            return uom
//        }
//        else if let sample = sample as? FeatureSample<ToFMultiObjectDelegate>,
//                  let data = sample.data,
//                  let uom = data.distances.uom {
//            return uom
//        }
        else if let sample = sample as? FeatureSample<EventCounterData>,
                let data = sample.data,
                let uom = data.counter.uom {
            return uom
        }
        return nil
    }
}
