//
//  ResultType.swift
//  T-moji
//
//  Created by Homey Poon on 2023-07-31.
//

import Foundation

enum ResultType: String {
    
    case dog = "dog", cat = "cat", rabbit = "rabbit", tiger = "tiger"
    case car = "car", bike = "bike", motorcycle = "motorcycle", bus = "bus", ship = "ship", helicopter = "helicopter"
    case apple = "apple", banana = "banana", orange = "orange", strawberry = "strawberry", mango = "mango", pineapple = "pineapple"
    case belle = "belle", mulan = "mulan", moana = "moana", ariel = "ariel", rapunzel = "rapunzel", elsa = "elsa"
    
    case baby = "baby", child = "child", adult = "adult", senior = "senior"
    case brownBear = "brown bear", polarBear = "polar bear", panda = "panda", koala = "koala"
    case ice = "ice", water = "water", fire = "fire", nature = "nature"
    case rainbow = "rainbow", sunny = "sunny", cloudy = "cloudy", rainy = "rainy", thunderstorm = "thunderstorm"
    case evergreenTree = "evergreen tree", deciduousTree = "deciduous tree", palmTree = "palmTree", christmasTree = "christmas tree"
    case ant = "ant", ladybug = "ladybug", bee = "bee", butterfly = "butterfly"
    
    
    // ALERT: Watch how long each result message is + word length
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
        case .ship:
            return "You have a strong and resilient personality, much like a mighty ship navigating through rough waters. Your determination and adaptability help you weather any storm, and you're a reliable source of support for those around you."
            
        case .helicopter:
            return "You have a unique perspective and a knack for seeing the bigger picture. Your ability to rise above challenges and provide support is appreciated by those around you."
            // Fruits
        case .apple:
            return "You possess a balanced and grounded personality. People appreciate your reliability and practicality. You have a strong sense of responsibility and value honesty in your interactions."
        case .banana:
            return "You have a vibrant and energetic personality that brings positivity to those around you. Your cheerful nature and sense of humor make you a delightful presence in any situation."
        case .orange:
            return "You are a sociable and friendly individual who enjoys connecting with others. Your warmth and approachability make people feel comfortable in your presence. You have a knack for building strong relationships."
        case .strawberry:
            return "You have a passionate and lively personality. Your enthusiasm for life is infectious, and you inspire others with your zest and energy. Your optimism and determination propel you towards success."
        case .mango:
            return "You have a bold and exotic personality that draws people in. Your energy for life makes you an unforgettable presence, and you always bring a touch of excitement to any situation."
        case .pineapple:
            return "You have a warm and welcoming personality that makes everyone feel at ease. Your hospitality and generosity are your strengths, and you have a way of turning ordinary moments into special memories."
            
            // disney princess
            
        case .belle:
            return "You are intelligent, curious, and possess a love for books and learning. Your independent and adventurous spirit sets you apart. You value inner beauty and possess a caring and empathetic nature."
        case .mulan:
            return "You are courageous, determined, and unafraid to challenge societal expectations. Your bravery and loyalty inspire those around you. You value honor and are willing to go to great lengths to protect the ones you love."
        case .moana:
            return "You are adventurous, bold, and have a deep connection with your roots and the sea. Your wanderlust drives you to explore and discover new horizons. You have a strong sense of identity and are driven by your intuition and determination."
        case .ariel:
            return "You are adventurous and curious about the world around you. Your love for exploration and your free spirit make you a beacon of independence and determination."
        case .rapunzel:
            return "You possess boundless creativity and a desire for self-discovery. Your optimism and enthusiasm for life are infectious, and your ability to find beauty in everything is truly inspiring."
        case .elsa:
            return "You have a powerful and resilient spirit. Your journey of self-acceptance and your ability to embrace your uniqueness is a source of inspiration. Your strength lies in your authenticity and inner power."
            
            // mental age
        case .baby:
            return "You are a reminder of the beauty in simplicity, a testament to the awe-inspiring process of creation and growth. As you journey through life, you leave a trail of wonder and adoration in your wake."
        case .child:
            return "Inquisitive and full of wonder, you embody the essence of childhood curiosity. Your eyes eagerly take in the world around you as you explore every nook and cranny with a boundless sense of adventure."
        case .adult:
            return "Your demeanor exudes a sense of purpose and self-assuredness that comes from navigating life's twists and turns. Each step you take is deliberate, a reflection of the wisdom you've gained over the years."
        case .senior:
            return "Your presence is a source of comfort, offering reassurance to others as they navigate their own journeys. Your ability to listen without judgment and offer guidance is a beacon of light in the world."
            
            // Bear
        case .brownBear:
            return "Your interactions are marked by a balanced blend of assertiveness and empathy. You have a natural gift for leadership, and you’re great at guiding others with a calm and authoritative presence."
        case .panda:
            return "Your ability to exude calm amidst chaos and nurture connections makes you a cherished presence in the lives of those you touch. Your presence enriches the lives of those fortunate enough to know you."
            
        case .koala:
            return "Your interactions are marked by a gentle and approachable nature. Your ability to listen without judgment is a gift that fosters trust and encourages open communication."
        case .polarBear:
            return "You understand the value of self-reliance and introspection. Your ability to find strength in introspection and channel it into growth is an inspiration to those around you."
            // Elements
        case .fire:
            return "Your inner fire is a powerful force that fuels your passions and drives you toward your goals. Keep burning bright on your unique journey, and let your passion ignite the world."
        case .ice:
            return "Your effortless style and confident charm are truly magnetic. Keep being your amazing, cool self, because you add a special kind of magic to the world."
        case .water:
            return "Your adaptable nature is a calming presence in our lives. Your ability to navigate life's twists and turns with ease and your capacity for deep empathy remind us of the soothing power of understanding and flexibility."
        case .nature:
            return "Your grounded and steady nature is a true anchor in our lives. Your practicality, reliability, and nurturing presence provide a sense of stability that is deeply cherished."
        case .rainbow:
            return "Your colorful and vibrant spirits are a beacon of joy and positivity.Keep shining brightly and inspiring us all to celebrate our unique colors."
        case .sunny:
            return "Your radiant and positive energy is like a burst of sunshine on even the cloudiest of days. Your cheerful disposition and warm smiles are infectious, brightening the lives of those around you."
        case .cloudy:
            return "Your calm and tranquil presence resembles the gentle embrace of a passing cloud. Your ability to bring a sense of serenity and perspective to life's challenges is truly remarkable."
        case .rainy:
            return "Your nurturing and rejuvenating presence is like a refreshing rain shower in the heat of summer. Keep showering the world with your empathy and compassion."
        case .thunderstorm:
            return "Your energy and intensity shakes up the status quo and sparks change. Your passion and determination to make a difference inspire those around you, bringing growth and transformation."
        case .deciduousTree:
            return "Your ability to gracefully embrace change and transition is truly admirable. Just as leaves fall in the autumn, you shed the old to make way for the new with elegance and resilience."
        case .christmasTree:
            return "Your boundless enthusiasm for celebration and spreading joy is truly contagious. Like the twinkle of holiday lights, your positivity lights up the world around you."
        case .palmTree:
            return "Your laid-back and sunny disposition brings a breath of fresh air wherever you go. Just as palm fronds sway with ease in the breeze, you navigate life's challenges with a calm and adaptable spirit."
        case .evergreenTree:
            return "Your steadfast and unwavering nature is like the constant presence of a reliable friend. Much like the resilient branches that bear leaves throughout the year, you remain strong and dependable through life's seasons."
        case .ladybug:
            return "Your cheerful and vibrant presence lights up every room you enter. Your positivity and warmth are like a lucky charm, spreading happiness to those around you."
        case .butterfly:
            return "Your ability to gracefully embrace change, spread your wings, and bring beauty to the world is truly remarkable. Keep fluttering through life's challenges and joys, inspiring those around you with your radiant spirit."
        case .ant:
            return "Your dedication, diligence, and remarkable work ethic are admirable. Your ability to focus on your goals with unwavering determination and to collaborate effectively in achieving them is truly inspiring."
        case .bee:
            return "Your ability to work tirelessly for the collective good, whether in your career or community, is a testament to your character. Keep buzzing with your determination, for your efforts are vital in creating a sweeter world for all!"
            
        }
    }
    
    var emoji: String {
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
        case .ship:
            return "🛳️"
        case .helicopter:
            return "🚁"
        case .apple:
            return "🍎"
        case .banana:
            return "🍌"
        case .orange:
            return "🍊"
        case .strawberry:
            return "🍓"
        case .mango:
            return "🥭"
        case .pineapple:
            return "🍍"
        case .belle:
            return "🌹"
        case .mulan:
            return "⚔️"
        case .moana:
            return "⛵️"
        case .ariel:
            return "🧜‍♀️"
        case .rapunzel:
            return "💇‍♀️"
        case .elsa:
            return "❄️"
            
            // Ages
        case .baby:
            return "👶"
        case .child:
            return "🧒"
        case .adult:
            return "🧑"
        case .senior:
            return "🧓"
            
            // Bears
        case .brownBear:
            return "🐻"
        case .polarBear:
            return "🐻‍❄️"
        case .panda:
            return "🐼"
        case .koala:
            return "🐨"
            
            // elements
        case .ice:
            return "❄️"
        case .water:
            return "💧"
        case .fire:
            return "🔥"
        case .nature:
            return "🌱"
            
            // Weather
        case .rainbow:
            return "🌈"
        case .sunny:
            return "☀️"
        case .cloudy:
            return "☁️"
        case .rainy:
            return "🌨️"
        case .thunderstorm:
            return "⚡️"
            
            // Tree
        case .evergreenTree:
            return "🌲"
        case .deciduousTree:
            return "🌳"
        case .palmTree:
            return "🌴"
        case .christmasTree:
            return "🎄"
            
            // Insect
        case .ant:
            return "🐜"
        case .ladybug:
            return "🐞"
        case .bee:
            return "🐝"
        case .butterfly:
            return "🦋"
        }
    }
}

enum ResultGroup: String {
    case fruit = "Fruit"
    case vehicle = "Vehicle"
    case animal = "Animal"
    case disneyPrincess = "Disney Princess"
    case mentalAge = "Mental Age"
    case bear = "Bear"
    case element = "Element"
    case tree = "Tree"
    case insect = "Insect"
}

extension ResultType {
    static let groupedTypes: [ResultGroup: [ResultType]] = {
        return [
            .animal: [.dog, .cat, .rabbit, .tiger],
            .vehicle: [.car, .bike, .motorcycle, .bus, .ship, .helicopter],
            .fruit: [.apple, .banana, .orange, .strawberry, .mango, .pineapple],
            .disneyPrincess: [.belle, .mulan, .moana, .ariel, .rapunzel, .elsa],
            .mentalAge: [.baby, .child, .adult, .senior],
            .bear: [.polarBear, .koala, .panda, .brownBear],
            .element: [.ice, .water, .fire, .nature],
            .tree: [.palmTree, .christmasTree, .deciduousTree, .evergreenTree],
            .insect: [.ant, .ladybug, .bee, .butterfly],
            
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
