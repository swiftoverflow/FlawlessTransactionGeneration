//
//  Money.swift
//  FlawlessTransactionGeneration
//
//  Created by OMELCHUK Daniil on 28/11/2019.
//  Copyright © 2019 OMELCHUK Daniil. All rights reserved.
//

import Foundation

// MARK: - Деньги

public protocol Money {
    var value: Decimal { get set }
    var currency: Currency { get }
}

// MARK: - Код валюты

enum CurrencyCode: Int {
    case rur = 810
    case usd = 840
}

// MARK: - Символ валюты

enum CurrencySymbol: String {
    case rur = "RUR"
    case usd = "USD"
}

// MARK: - Графема валюты

enum CurrencyGrapheme: String {
    case rur = "₽"
    case usd = "$"
}

// MARK: - Структура валюты

public struct Currency {
    let name: String
    let shortName: String
    let code: CurrencyCode
    let symbol: CurrencySymbol
    let grapheme: CurrencyGrapheme
    
    init() {
        self.name = "Российский рубль"
        self.shortName = "руб."
        self.code = .rur
        self.symbol = .rur
        self.grapheme = .rur
    }
    
    init(name: String, shortName: String, code: CurrencyCode, symbol: CurrencySymbol, grapheme: CurrencyGrapheme) {
        self.name = name
        self.shortName = shortName
        self.code = code
        self.symbol = symbol
        self.grapheme = grapheme
    }
}

// MARK: - Структура денег

struct ATMMoney: Money {
    var value: Decimal
    let currency: Currency
}
