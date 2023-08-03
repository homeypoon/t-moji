//
//  ResultType.swift
//  T-moji
//
//  Created by Homey Poon on 2023-07-31.
//

import Foundation

enum ResultType: String {
    
    case dog = "dog", cat = "cat", rabbit = "rabbit", tiger = "tiger"
    case car = "car", bike = "bike", motorcycle = "motorcycle", bus = "bus"
    case apple = "apple", banana = "banana", orange = "orange", strawberry = "strawberry"
    
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
    
    var emoji: Character {
        switch self {
        case .dog:
            return "🐶"
        case .cat:
            return "🐱"
        case .rabbit:
            return "🐰"
        case .tiger:
            return "🐯"
        case .car:
            return "🚗"
        case .bike:
            return "🚲"
        case .motorcycle:
            return "🏍️"
        case .bus:
            return "🚌"
        case .apple:
            return "🍎"
        case .banana:
            return "🍌"
        case .orange:
            return "🍊"
        case .strawberry:
            return "🍓"
        }
    }
    
}

extension ResultType {
    static let groupedTypes: [ResultGroup: [ResultType]] = {
        return [
            .fruit: [.apple, .banana, .orange, .strawberry],
            .vehicle: [.car, .bike, .motorcycle, .bus],
            .animal: [.dog, .cat, .rabbit, .tiger]
            // Add more groups as needed
        ]
    }()
}

extension ResultType {
    static func allGroups() -> [ResultGroup] {
        return Array(groupedTypes.keys)
    }
    
    static func getTypes(for groupName: ResultGroup) -> [ResultType]? {
        return groupedTypes[groupName]
    }
}


extension ResultType: Codable { }

extension ResultType: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(emoji)
    }
    static func == (lhs: ResultType, rhs: ResultType) -> Bool {
        return lhs.emoji == rhs.emoji
    }
}

extension ResultType: Comparable {
    static func < (lhs: ResultType, rhs: ResultType) -> Bool {
        return lhs.emoji < rhs.emoji
    }
}

enum ResultGroup: String {
    case fruit
    case vehicle
    case animal
}
