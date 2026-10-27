//
//  RegisterStatusView.swift
//  STDemos
//
//  Created by Luca Pezzoni on 21/10/2026.
//

import SwiftUI
import STBlueSDK
import STUI

public struct RegisterStatusView: View {
    let registerName: String
    let register: RegisterStatus
    @State private var isBumping = false

    public var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)

            HStack(alignment: .center, spacing: 0) {
                Spacer()
                    .frame(width: 4)

                VStack(alignment: .leading, spacing: 8) {
                    // Full Register Name Text
                    Text("\(registerName): \(register.registerId)")
                        .font(.title3)
                        .bold()
                        .foregroundColor(SUIColorLayout.primary.color)

                    // Algorithm Name (Optional)
                    if let algorithmName = register.algorithmName {
                        Text(algorithmName)
                            .font(.subheadline)
                            .italic()
                            .foregroundColor(SUIColorLayout.primary.color)
                            .padding(.leading, 4)
                    }

                    // Register Value String
                    let registerValueStr: String = {
                        if let label = register.label {
                            return String(format: "Value: %@ (0x%X)", label, register.value)
                        } else {
                            return String(format: "Value: 0x%X", register.value)
                        }
                    }()

                    Text(registerValueStr)
                        .font(.subheadline)
                        .italic()
                        .foregroundColor(SUIColorLayout.primary.color)
                        .padding(.leading, 4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()
                    .frame(width: 8)

                Image(getAiValueImage(register.label ?? "Default"), bundle: STDemos.bundle)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .foregroundColor(SUIColorLayout.primary.color)
            }
            .foregroundColor(SUIColorLayout.primary.color)
            .padding(8)
        }
        .scaleEffect(isBumping ? 1.1 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.45), value: isBumping)
        .onChange(of: registerAnimationKey) {
            triggerBump()
        }
    }

    private var registerAnimationKey: String {
        "\(register.registerId)-\(register.value)-\(register.label ?? "")-\(register.algorithmName ?? "")"
    }

    private func triggerBump() {
        isBumping = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            isBumping = false
        }
    }

    private func getAiValueImage(_ label: String) -> String {
        switch label {
            /// Activity Recognition
        case "Walking":
            return "mlc_walking"
        case "Running":
            return "mlc_running"
        case "Standing":
            return "mlc_standing"
        case "Biking":
            return "mlc_biking"
        case "Driving":
            return "mlc_driving"
            
            /// Head Gesture
        case "Nod":
            return "mlc_nod"
        case "Shake":
            return "mlc_shake"
        case "Swing":
            return "mlc_swing"
        case "Steady head":
            return "mlc_steady_head"
            
            /// Vibration
        case "No vibration":
            return "mlc_no_vibration"
        case "Low vibration":
            return "mlc_low_vibration"
        case "High vibration":
            return "mlc_high_vibration"
            
            /// Asset Tracking
        case "Stationary upright":
            return "mlc_stationary_upright"
        case "Stationary not upright":
            return "mlc_stationary_no_upright"
        case "Motion":
            return "mlc_motion"
        case "Shaking":
            return "mlc_shaking"
            
            /// Door opening/closing/still
        case "Door closing":
            return "mlc_door_closing"
        case "Door still":
            return "mlc_door_still"
        case "Door Opening":
            return "mlc_door_opening"
            
            /// Gym activity recognition
        case "No activity":
            return "mlc_standing"
        case "Biceps curls":
            return "mlc_biceps_curls"
        case "Lateral raises":
            return "mlc_lateral_raises"
        case "Squat":
            return "mlc_squat"
            
            /// Vehicle
        case "Car moving":
            return "mlc_car_moving"
        case "Car still":
            return "mlc_car_still"
            
            /// Yoga Pose
        case "The tree":
            return "mlc_the_tree"
        case "Boat pose":
            return "mlc_boat_pose"
        case "Bow pose":
            return "mlc_bow_pose"
        case "Plank inverse":
            return "mlc_plank_inverse"
        case "Side angle":
            return "mlc_side_angle"
        case "Plank":
            return "mlc_plank"
        case "Meditation pose":
            return "mlc_meditation_pose"
        case "Cobra":
            return "mlc_cobra"
        case "Child":
            return "mlc_child"
        case "Downward dog pose":
            return "mlc_downward_dog_pose"
        case "Seated forward":
            return "mlc_seated_forward"
        case "Bridge":
            return "mlc_bridge"
        default:
            return "mlc_new_icon"
        }
    }
}
