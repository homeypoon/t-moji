//
//  ResultType.swift
//  T-moji
//
//  Created by Homey Poon on 2023-07-31.
//

import Foundation

enum ResultType: Character {
    
    case dog = "🐶", cat = "🐱", rabbit = "🐰", tiger = "🐯"
    case car = "🚗", bike = "🚲", motorcycle = "🏍️", bus = "🚌"
    case apple = "🍎", banana = "🍌", orange = "🍊", strawberry = "🍓"
    
    
    var message: String {
        switch self {
        case .dog:
            return "You are loyal, friendly, and enjoy spending time with others. You value companionship and are known for your faithfulness and protective nature."
        case .cat:
            return "You are independent, curious, and have a strong sense of self. You enjoy your personal space and prefer to be in control of your own surroundings."
        case .rabbit:
            return "You are gentle, affectionate, and have a playful nature. You appreciate harmony and enjoy spending time with loved ones in a calm and peaceful environment."
        case .tiger:
            return "You are bold, confident, and have a strong presence. You possess great strength and leadership qualities, and you're not afraid to take risks to achieve your goals."
            
            // Vehicles
        case .car:
            return "You are a reliable and efficient individual. You are practical, always ready to handle any task, and value a smooth and comfortable experience for others."
        case .bike:
            return "You are a carefree and active individual. You embrace a slower pace of life and enjoy exploring the world at your own leisure, savoring the simple pleasures along the way."
        case .motorcycle:
            return "You are an adventurous and free-spirited soul. Fearless and independent, you thrive on the adrenaline of the open road, seeking exhilaration and freedom in every twist and turn."
        case .bus:
            return "You are a social and community-oriented person who enjoys being part of a group. Known for your welcoming nature and strong sense of community, you are always ready to bring people together and create shared experiences."
        case .apple:
            return "You possess a balanced and grounded personality. People appreciate your reliability and practicality. You have a strong sense of responsibility and value honesty in your interactions."
        case .banana:
            return "You have a vibrant and energetic personality that brings positivity to those around you. Your cheerful nature and sense of humor make you a delightful presence in any situation."
        case .orange:
            return "You are a sociable and friendly individual who enjoys connecting with others. Your warmth and approachability make people feel comfortable in your presence. You have a knack for building strong relationships."
        case .strawberry:
            return "You have a passionate and lively personality. Your enthusiasm for life is infectious, and you inspire others with your zest and energy. Your optimism and determination propel you towards success."
        }
    }
    
    var character: Character {
        return rawValue
    }
    
}

extension ResultType: Codable { }

extension ResultType: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(character)
    }
    static func == (lhs: ResultType, rhs: ResultType) -> Bool {
        return lhs.character == rhs.character
    }
}

extension ResultType: Comparable {
    static func < (lhs: ResultType, rhs: ResultType) -> Bool {
        return lhs.character < rhs.character
    }
}
