//
//  QuizData.swift
//  T-moji
//
//  Created by Homey Poon on 2023-07-31.
//

import Foundation

struct QuizData {
    static let quizzes: [Quiz] = [
        // Fruit Quiz
        Quiz(id: 0, resultGroup: .fruit, title: "What Fruit Are You?", quizType: .character, question: [
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
            Question(text: "What is your favourite season?", type: .singleChoice, possibleAnswers: [
                        Answer(text: "Spring", correspondingResult: ResultType.rabbit),
                        Answer(text: "Summer", correspondingResult: ResultType.dog),
                        Answer(text: "Autumn", correspondingResult: ResultType.cat),
                        Answer(text: "Winter", correspondingResult: ResultType.tiger)
                     ]),
            Question(text: "What is your favourite color?", type: .singleChoice, possibleAnswers: [
                        Answer(text: "Orange", correspondingResult: ResultType.tiger),
                        Answer(text: "Red", correspondingResult: ResultType.dog),
                        Answer(text: "Black", correspondingResult: ResultType.cat),
                        Answer(text: "Pink", correspondingResult: ResultType.rabbit)
                     ])
        ]),
        // Vehicle Quiz
        Quiz(id: 1, resultGroup: .vehicle, title: "What Vehicle Are You?", quizType: .character, question: [
            Question(text: "Which is your favourite genre?", type: .singleChoice, possibleAnswers: [
                
                Answer(text: "Fantasy", correspondingResult: ResultType.bike),
                Answer(text: "Action", correspondingResult: ResultType.motorcycle),
                Answer(text: "Comedy", correspondingResult: ResultType.car),
                Answer(text: "Romance", correspondingResult: ResultType.bike)
                     ])
            ]),
        // Fruit Quiz
        // CHANGE NEEDED
        Quiz(id: 2, resultGroup: .fruit, title: "What Fruit Are You?", quizType: .character, question: [
            Question(text: "Which is your favourite genre?", type: .singleChoice, possibleAnswers: [
                Answer(text: "Fantasy", correspondingResult: ResultType.apple),
                Answer(text: "Action", correspondingResult: ResultType.banana),
                Answer(text: "Comedy", correspondingResult: ResultType.orange),
                Answer(text: "Romance", correspondingResult: ResultType.strawberry)
            ])
        ]),
    ]


}

