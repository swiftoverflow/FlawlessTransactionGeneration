//
//  Transaction.swift
//  FlawlessTransactionGeneration
//
//  Created by OMELCHUK Daniil on 28/11/2019.
//  Copyright © 2019 OMELCHUK Daniil. All rights reserved.
//

import Foundation
import FlawlessValidation

protocol SortStatisticsStrategy {
    func getStatistics(statements: [Statement]) -> Dictionary<AnyHashable, Any>
}

// MARK: - Вид транзакции

public enum TransactionKind : String, CaseIterable {
    case transfer = "Осуществить перевод"
    case penalty = "Оплатить штраф"
    case phone = "Оплатить телефон"
    case withdraw = "Снятие наличных"
    case cashDeposit = "Внесение наличных"
    case exchange = "Обмен валюты"
}

public protocol Statement {
    var date: Date { get }
    var title: String { get }
    var amount: Money { get }
    var kind: TransactionKind { get }
    var clientCardId: Int { get }
}

struct Transaction: Statement {
    let date: Date
    let title: String
    let amount: Money
    let kind: TransactionKind
    let clientCardId: Int
    private let validation = FlawlessValidation()
    
    private let tittleArrayWithKind: [String : TransactionKind] =
                                    ["Осуществлен перевод на карту 5469 3800 3289 6865" : .transfer,
                                     "Оплачен штраф за парковку" : .penalty,
                                     "Оплачен телефон +7 (964) 377-00-00" : .phone,
                                     "Снятие наличных" : .withdraw,
                                     "Внесение наличных" : .cashDeposit,
                                     "Обмен валюты" : .exchange,
                                     "Осуществлен перевод на карту 6789 7645 2345 4536" : .transfer,
                                     "Оплачен штраф за превышение скорости" : .penalty,
                                     "Оплачен телефон +7 (985) 773-43-57" : .phone]
    
    ///Генерирует случайную категорию покупки
    /// - Returns:
    ///     Возвращает кортеж где первый элемент это Название покупки, а второй это тип покупки
    private func generateTitleForStatement() -> (String, TransactionKind) {
        guard let title = tittleArrayWithKind.randomElement() else {return ("Снятие наличных",.withdraw)}
        return title
    }
    
    ///Генерирует сумму для категории покупки
    ///
    /// - Parameters:
    ///     - type: Категория товара, для которой сгенерируется сумма
    /// - Returns:
    ///     Возвращает объект типа Money
    private func generateMoneyForStatement(for type: TransactionKind) -> Money {

        let money: Money
        let currency: Currency = Currency(name: "Российский рубль", shortName: "руб", code: .rur, symbol: .rur, grapheme: .rur)
        
        switch type {
        case .transfer:
            switch currency.code {
            case .rur:
                let cost: Double = Double.random(in: 500..<50_000)
                money = ATMMoney(value: Decimal(cost), currency: currency)
            case .usd:
                let cost: Double = Double.random(in: 500..<50_000) / 65.0
                money = ATMMoney(value: Decimal(cost), currency: currency)
            }
        case .penalty:
            switch currency.code {
            case .rur:
                let cost: Double = Double.random(in: 500..<5_000)
                money = ATMMoney(value: Decimal(cost), currency: currency)
            case .usd:
                let cost: Double = Double.random(in: 500..<5_000) / 65.0
                money = ATMMoney(value: Decimal(cost), currency: currency)
            }
        case .phone:
            switch currency.code {
            case .rur:
                let cost: Double = Double.random(in: 100..<1_000)
                money = ATMMoney(value: Decimal(cost), currency: currency)
            case .usd:
                let cost: Double = Double.random(in: 100..<1_000) / 65.0
                money = ATMMoney(value: Decimal(cost), currency: currency)
            }
        case .withdraw:
            switch currency.code {
            case .rur:
                let kf: Int = Int.random(in: 1..<10)
                let cost: Double = 1000.0 * Double(kf)
                money = ATMMoney(value: Decimal(cost), currency: currency)
            case .usd:
                let kf: Int = Int.random(in: 1..<10)
                let cost: Double = 1000.0 * Double(kf) / 65.0
                money = ATMMoney(value: Decimal(cost), currency: currency)
            }
        case .cashDeposit:
            switch currency.code {
            case .rur:
                let kf: Int = Int.random(in: 1..<10)
                let cost: Double = 1000.0 * Double(kf)
                money = ATMMoney(value: Decimal(cost), currency: currency)
            case .usd:
                let kf: Int = Int.random(in: 1..<10)
                let cost: Double = 1000.0 * Double(kf) / 65.0
                money = ATMMoney(value: Decimal(cost), currency: currency)
            }
        case .exchange:
            switch currency.code {
            case .rur:
                let cost: Double = Double.random(in: 1000..<50_000)
                money = ATMMoney(value: Decimal(cost), currency: currency)
            case .usd:
                let cost: Double = Double.random(in: 300..<2000) / 65.0
                money = ATMMoney(value: Decimal(cost), currency: currency)
            }
        }
        return money
    }
    
    /// Динамически генерирует список транзакций
    ///
    /// - Parameters:
    ///     - since: Дата от которой нужно сгенерировать список транзакций
    /// - Returns:
    ///     Массив транзакций
    func generateStatements(clientCardId: Int) -> [Statement] {
        
        var statementArray: [Statement] = []
        
        let currentDate: Date = Date()
        //Получаем дату от текущей на 10 дней назад
        let randomSinceDate: Date = validation.getDateFrom(daysAgo: 10)
        let dayDifference: Int = validation.getDaysInterval(from: randomSinceDate, to: currentDate)
        
        let transactionCount: Int = Int.random(in: 7..<10)
        
        for _ in 0..<transactionCount {
            let statement = generateTitleForStatement()
            let randomDate: Date = validation.randomDate(days: dayDifference)
            let money: Money = generateMoneyForStatement(for: statement.1)
            statementArray.append(Transaction(date: randomDate, title: statement.0, amount: money, kind: statement.1, clientCardId: clientCardId))
        }
        
        return statementArray
    }
}


// MARK: - Использование паттерна Strategy

final class BaseSort {
    var sortStrategy: SortStatisticsStrategy?
    
    func applySort(statements: [Statement]) -> Dictionary<AnyHashable, Any>{
        if let sortStatistics = sortStrategy {
            return sortStatistics.getStatistics(statements: statements)
        }
        return [:]
    }
}

final class SortByDates: SortStatisticsStrategy {
    
    func getStatistics(statements: [Statement]) -> Dictionary<AnyHashable, Any>  {

        var orderByDates: [Date : [Statement]] = [:]
        
        // 1. Сортировать по дате и категорям ()
        let calendar: Calendar = Calendar.current
        
        //Заполняем уникальными датами
        for statement in statements {
            let date: Date? = calendar.date(from: calendar.dateComponents([.year, .month, .day], from: statement.date))
            orderByDates[date!] = []
        }
        
        //каждой дате ставим в соответствие транзакцию
        for statement in statements {
            let date: Date? = calendar.date(from: calendar.dateComponents([.year, .month, .day], from: statement.date))
            orderByDates[date!]?.append(statement)
        }
        return orderByDates
    }
    
}

final class SortByCategory: SortStatisticsStrategy {
    
    func getStatistics(statements: [Statement]) -> Dictionary<AnyHashable, Any>  {
        
        var orderByCategory: [TransactionKind : [Statement]] = [:]
        
        //Заполняем всеми возможными типами транзакций
        for statementType in TransactionKind.allCases {
            orderByCategory[statementType] = []
        }
        
        //Добавляем транзакцию в соответствии с ее типом
        for statement in statements {
            orderByCategory[statement.kind]?.append(statement)
        }
        return orderByCategory
    }
}

final class SortByTotalForCategories: SortStatisticsStrategy {
    
    func getStatistics(statements: [Statement]) -> Dictionary<AnyHashable, Any> {
        
        var totalForCategories: [TransactionKind : [Money]] = [:]

        //Заполняем всеми возможными типами транзакций
        for statementType in TransactionKind.allCases {
            totalForCategories[statementType] = []
        }
        
        //Добавляем транзакцию в соответствии с ее типом
        for statement in statements {
            totalForCategories[statement.kind]?.append(statement.amount)
        }
        
        var sumRub: Decimal = 0 //Общая сумма в рублях

        for key in totalForCategories {
            //Подсчитываем сумму в соответствии с валютой
            for i in 0..<key.value.count {
                sumRub += key.value[i].value
            }
            //После подсчета всей суммы обнуляем массивы содержащий сумму транзакции так как они нам больше не нужны
            totalForCategories[key.key] = []
            if sumRub > 0 { //Если были транзакции с рублем, то записываем об этом информацию
                let moneyRub: Money = ATMMoney(value: sumRub, currency: Currency(name: "Российский рубль", shortName: "руб", code: .rur, symbol: .rur, grapheme: .rur))
                totalForCategories[key.key]?.append(moneyRub)
            }
            //Обнуляем для подсчета суммы для остальных категорий
            sumRub = 0
        }
        
        return totalForCategories
    }
}
