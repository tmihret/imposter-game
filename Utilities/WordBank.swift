//
//  WordBank.swift
//  imposterFinalProject
//
//  Created by admin on 4/26/26.
//


struct WordBank {
    static let categories: [String: [String]] = [
        "Fortnite POIs": [
            "Tilted Towers", "Pleasant Park", "Loot Lake",
            "Dusty Depot", "Retail Row", "Haunted Hills"
        ],
        "Things That Should Not Be Warm": [
            "Toilet Seat", "Ice Cream", "Pillow",
            "Gatorade", "Fridge", "Salad"
        ],
        "Terrible Ice Cream Flavor Ideas": [
            "Pizza", "Asparagus", "Meat",
            "Curry", "Beetroot", "Caesar Dressing"
        ],
        "Places you would not want to eat in": [
            "Sewer", "Bathroom", "Nuclear Plant",
            "In the rain", "In a Volcano", "Under the bed"
        ],
        "Villains": [
            "Diddy", "Thanos", "Osama Bin Laden",
            "Joker", "Green Goblin", "Hitler"
        ],
        "Detectives": [
            "Sherlock Holmes", "Scooby Doo", "Spider-Noir",
            "Batman", "Shaggy"
        ],
        
        "Geniuses": [
            "Albert Einstein", "Megamind", "Issac Newton", "Peter Parker", "Micheal Jordan", "Mark Zuckerberg"
        ],
        
        "Things That Fly": [
            "Paper", "Superman", "Bird", "Bee", "Airplane", "Flea"
        ]
    ]
    
    static func randomWord() -> (category: String, word: String) {
        let category = categories.keys.randomElement()!
        let word = categories[category]!.randomElement()!
        return (category, word)
    }
}
