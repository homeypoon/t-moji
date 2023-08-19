//
//  QuizData.swift
//  T-moji
//
//  Created by Homey Poon on 2023-07-31.
//

import Foundation

struct QuizData {
    static let quizzes: [Quiz] = [
        // Animal Quiz
        Quiz(id: 0, resultGroup: .animal, title: "What Animal Are You?", quizType: .character, questions: [
            Question(text: "Where would you like to travel to?", type: .multipleChoice, possibleAnswers: [
                Answer(text: "New York, USA", correspondingResult: ResultType.dog),
                Answer(text: "Paris, France", correspondingResult: ResultType.cat),
                Answer(text: "Tokyo, Japan", correspondingResult: ResultType.rabbit),
                Answer(text: "Jaipur, India", correspondingResult: ResultType.tiger)
            ]),
            Question(text: "How introverted or extraverted are you?", type: .ranged, possibleAnswers: [
                Answer(text: "Introverted", correspondingResult: ResultType.cat),
                Answer(text: "Slightly Introverted", correspondingResult: ResultType.rabbit),
                Answer(text: "Slightly Extraverted", correspondingResult: ResultType.tiger),
                Answer(text: "Extraverted", correspondingResult: ResultType.dog)
            ]),
            Question(text: "What is your favourite season?", type: .multipleChoice, possibleAnswers: [
                Answer(text: "Spring", correspondingResult: ResultType.rabbit),
                Answer(text: "Summer", correspondingResult: ResultType.dog),
                Answer(text: "Autumn", correspondingResult: ResultType.cat),
                Answer(text: "Winter", correspondingResult: ResultType.tiger)
            ]),
            Question(text: "What is your favourite color?", type: .multipleChoice, possibleAnswers: [
                Answer(text: "Orange", correspondingResult: ResultType.tiger),
                Answer(text: "Red", correspondingResult: ResultType.dog),
                Answer(text: "Black", correspondingResult: ResultType.cat),
                Answer(text: "Pink", correspondingResult: ResultType.rabbit)
            ]),
            Question(text: "Which superpower would you choose?", type: .multipleChoice, possibleAnswers: [
                Answer(text: "Super strength", correspondingResult: ResultType.tiger),
                Answer(text: "Shape-shifting", correspondingResult: ResultType.cat),
                Answer(text: "Invisibility", correspondingResult: ResultType.rabbit),
                Answer(text: "Telepathy", correspondingResult: ResultType.dog)
            ]),
            Question(text: "What's your preferred leisure activity?", type: .multipleChoice, possibleAnswers: [
                Answer(text: "Going for a hike", correspondingResult: ResultType.dog),
                Answer(text: "Curling up with a good book", correspondingResult: ResultType.cat),
                Answer(text: "Exploring new places", correspondingResult: ResultType.rabbit),
                Answer(text: "Engaging in sports", correspondingResult: ResultType.tiger)
            ])
        ]),
        // Vehicle Quiz
        Quiz(id: 1, resultGroup: .vehicle, title: "What Vehicle Are You?", quizType: .character, questions: [
            Question(text: "Which is your favourite genre?", type: .multipleChoice, possibleAnswers: [
                
                Answer(text: "Fantasy", correspondingResult: ResultType.bus),
                Answer(text: "Action", correspondingResult: ResultType.motorcycle),
                Answer(text: "Comedy", correspondingResult: ResultType.car),
                Answer(text: "Romance", correspondingResult: ResultType.bike)
            ]),
            Question(text: "How would your friends describe you?", type: .multipleChoice, possibleAnswers: [
                Answer(text: "Reliable", correspondingResult: ResultType.car),
                Answer(text: "Adventurous", correspondingResult: ResultType.motorcycle),
                Answer(text: "Calm", correspondingResult: ResultType.bike),
                Answer(text: "Caring", correspondingResult: ResultType.bus)
            ]),
            Question(text: "Indoors or Outdoors?", type: .ranged, possibleAnswers: [
                Answer(text: "Indoors", correspondingResult: ResultType.car),
                Answer(text: "", correspondingResult: ResultType.bus),
                Answer(text: "", correspondingResult: ResultType.ship),
                Answer(text: "Outdoors", correspondingResult: ResultType.helicopter)
            ]),
            Question(text: "Which type of music do you prefer?", type: .multipleChoice, possibleAnswers: [
                Answer(text: "Rock", correspondingResult: ResultType.motorcycle),
                Answer(text: "Pop", correspondingResult: ResultType.car),
                Answer(text: "Electronic", correspondingResult: ResultType.helicopter),
                Answer(text: "Classical", correspondingResult: ResultType.ship)
            ]),
            Question(text: "What's your ideal weekend getaway?", type: .multipleChoice, possibleAnswers: [
                Answer(text: "Camping in the mountains", correspondingResult: ResultType.bike),
                Answer(text: "Luxury resort by the beach", correspondingResult: ResultType.ship),
                Answer(text: "Exploring a bustling city", correspondingResult: ResultType.bus),
                Answer(text: "Quiet cabin in the woods", correspondingResult: ResultType.car)
            ]),
            Question(text: "Sweet or Spicy?", type: .ranged, possibleAnswers: [
                Answer(text: "Sweet", correspondingResult: ResultType.bus),
                Answer(text: "Slightly Sweet", correspondingResult: ResultType.helicopter),
                Answer(text: "Slightly Spicy", correspondingResult: ResultType.ship),
                Answer(text: "Spicy", correspondingResult: ResultType.motorcycle)
            ]),
            Question(text: "What type of weather do you prefer?", type: .multipleChoice, possibleAnswers: [
                Answer(text: "Sunny and warm", correspondingResult: ResultType.car),
                Answer(text: "Rainy and cozy", correspondingResult: ResultType.bus),
                Answer(text: "Snowy and cold", correspondingResult: ResultType.ship),
                Answer(text: "Breezy and mild", correspondingResult: ResultType.helicopter)
            ])
            
        ]),
        
        // Fruit Quiz
        // CHANGE NEEDED
        Quiz(id: 2, resultGroup: .fruit, title: "What Fruit Are You?", quizType: .character, questions: [
            Question(text: "Which is your favourite genre?", type: .multipleChoice, possibleAnswers: [
                Answer(text: "Fantasy", correspondingResult: ResultType.apple),
                Answer(text: "Action", correspondingResult: ResultType.banana),
                Answer(text: "Comedy", correspondingResult: ResultType.orange),
                Answer(text: "Romance", correspondingResult: ResultType.strawberry)
            ]),
            Question(text: "Tea or Coffee?", type: .ranged, possibleAnswers: [
                Answer(text: "Tea", correspondingResult: ResultType.pineapple),
                Answer(text: "Slightly Tea", correspondingResult: ResultType.apple),
                Answer(text: "Slightly Coffee", correspondingResult: ResultType.banana),
                Answer(text: "Coffee", correspondingResult: ResultType.mango)
            ]),
            Question(text: "Which outdoor activity do you enjoy the most?", type: .multipleChoice, possibleAnswers: [
                Answer(text: "Picnicking in the park", correspondingResult: ResultType.apple),
                Answer(text: "Going out with friends", correspondingResult: ResultType.orange),
                Answer(text: "Getting food", correspondingResult: ResultType.strawberry),
                Answer(text: "Relaxing at the countryside", correspondingResult: ResultType.banana)
            ]),
            Question(text: "Morning or Night person?", type: .ranged, possibleAnswers: [
                Answer(text: "Morning person", correspondingResult: ResultType.orange),
                Answer(text: "Slightly Morning person", correspondingResult: ResultType.apple),
                Answer(text: "Slightly Night person", correspondingResult: ResultType.banana),
                Answer(text: "Night person", correspondingResult: ResultType.strawberry)
            ]),
            Question(text: "How do you like to spend your evenings?", type: .multipleChoice, possibleAnswers: [
                Answer(text: "Baking a treat", correspondingResult: ResultType.apple),
                Answer(text: "Dancing and partying", correspondingResult: ResultType.mango),
                Answer(text: "Watching a movie", correspondingResult: ResultType.orange),
                Answer(text: "Reading a book", correspondingResult: ResultType.strawberry)
            ]),
            Question(text: "What's your favorite way to stay active?", type: .multipleChoice, possibleAnswers: [
                Answer(text: "Going for a run", correspondingResult: ResultType.banana),
                Answer(text: "Yoga and meditation", correspondingResult: ResultType.pineapple),
                Answer(text: "Playing team sports", correspondingResult: ResultType.apple),
                Answer(text: "Hiking and exploring nature", correspondingResult: ResultType.mango)
            ]),
        ]),
        
        // Disney Princess Quiz
        Quiz(id: 3, resultGroup: .disneyPrincess, title: "Which Disney Princess Are You?", quizType: .character, questions: [
            Question(text: "How do you face challenges?", type: .multipleChoice, possibleAnswers: [
                Answer(text: "Adapt and overcome", correspondingResult: ResultType.moana),
                Answer(text: "Stay determined", correspondingResult: ResultType.rapunzel),
                Answer(text: "Be courageous", correspondingResult: ResultType.mulan),
                Answer(text: "Embrace my strength", correspondingResult: ResultType.elsa)
            ]),
            Question(text: "What do you want to do the most?", type: .multipleChoice, possibleAnswers: [
                Answer(text: "Travel the world", correspondingResult: ResultType.moana),
                Answer(text: "Gain knowledge", correspondingResult: ResultType.belle),
                Answer(text: "Make others proud of me", correspondingResult: ResultType.mulan),
                Answer(text: "Understand my identity", correspondingResult: ResultType.rapunzel)
            ]),
            Question(text: "What's Your Greatest Fear?", type: .multipleChoice, possibleAnswers: [
                Answer(text: "Losing family", correspondingResult: ResultType.moana),
                Answer(text: "Isolation", correspondingResult: ResultType.ariel),
                Answer(text: "Being judged", correspondingResult: ResultType.belle),
                Answer(text: "Losing control", correspondingResult: ResultType.elsa),
            ]),
            Question(text: "City or Countryside?", type: .ranged, possibleAnswers: [
                Answer(text: "City", correspondingResult: ResultType.ariel),
                Answer(text: "Slightly City", correspondingResult: ResultType.rapunzel),
                Answer(text: "Slightly Countryside", correspondingResult: ResultType.mulan),
                Answer(text: "Countryside", correspondingResult: ResultType.belle)
            ]),
            Question(text: "Qualities of Ideal Friend?", type: .multipleChoice, possibleAnswers: [
                Answer(text: "Fearless & bold", correspondingResult: ResultType.moana),
                Answer(text: "Curious & open", correspondingResult: ResultType.ariel),
                Answer(text: "Warm & empathetic", correspondingResult: ResultType.belle),
                Answer(text: "Loyal & dedicated", correspondingResult: ResultType.mulan)
            ]),
            Question(text: "Structure or Spontaneity?", type: .ranged, possibleAnswers: [
                Answer(text: "Structure", correspondingResult: ResultType.elsa),
                Answer(text: "", correspondingResult: ResultType.belle),
                Answer(text: "", correspondingResult: ResultType.rapunzel),
                Answer(text: "Spontaneity", correspondingResult: ResultType.ariel)
            ]),
            Question(text: "What is Your Favorite Element?", type: .multipleChoice, possibleAnswers: [
                Answer(text: "Fire", correspondingResult: ResultType.ariel),
                Answer(text: "Water", correspondingResult: ResultType.moana),
                Answer(text: "Air", correspondingResult: ResultType.rapunzel),
                Answer(text: "Earth", correspondingResult: ResultType.belle)
            ]),
            Question(text: "What is Your Spirit Animal?", type: .multipleChoice, possibleAnswers: [
                Answer(text: "Dolphin", correspondingResult: ResultType.ariel),
                Answer(text: "Squirrel", correspondingResult: ResultType.belle),
                Answer(text: "Falcon", correspondingResult: ResultType.mulan),
                Answer(text: "Wolf", correspondingResult: ResultType.elsa)
            ])
        ])
        
    ]
    
    
}

