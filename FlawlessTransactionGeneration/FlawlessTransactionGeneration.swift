//
//  FlawlessTransactionGeneration.swift
//  FlawlessTransactionGeneration
//
//  Created by OMELCHUK Daniil on 28/11/2019.
//  Copyright © 2019 OMELCHUK Daniil. All rights reserved.
//

import Foundation

public class FlawlessTransactionGeneration {
    
    private var sort: BaseSort = BaseSort()
    
    public init() {}
    
    ///Выводит в консоль информацию о транзакциях
    ///
    /// - Parameters:
    ///     - statements: массив транзакций
    public func printStatementInfo(print statements: [Statement]) {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMMM-yyyy hh:mm:ss"
        
        print("\nСписок транзакций\n")
        
        for statement in statements {
            
            var value: Decimal = 0  //Переменная для хранения округленного значения типа Decimal
            var temp: Decimal = statement.amount.value
            NSDecimalRound(&value, &temp, 2, .plain)
            print("Дата транзакции - \(dateFormatter.string(from: statement.date))\nОперация - \(statement.title)\nСтоимость - \(value) \(statement.amount.currency.grapheme.rawValue)\nКатегория - \(statement.kind.rawValue)\nВалюта - \(statement.amount.currency.name), Краткое имя - \(statement.amount.currency.shortName), Код - \(statement.amount.currency.code.rawValue), Символ - \(statement.amount.currency.symbol.rawValue)")
            print("\n")
        }
    }
    
    ///Генерирует случайные транзакции в интервале времени от 10 суток назад до сегодняшенго дня
    /// - Returns:
    ///     Массив сгенерированных транзакций
    public func getRandomTransaction() -> [Statement] {
        let transaction = Transaction(date: Date(), title: "", amount: ATMMoney(value: 0, currency: Currency(name: "", shortName: "", code: .rur, symbol: .rur, grapheme: .rur)), kind: .cashDeposit, clientCardId: 1)

        return transaction.generateStatements(clientCardId: 1)
    }
    
    ///Сортирует транзакции по датам
    ///
    /// - Parameters:
    ///     - statements: Сортируемые транзакции
    public func printTransactionOrderByDate(statements: [Statement]) {
        sort.sortStrategy = SortByDates()
        let statistics = sort.sortStrategy?.getStatistics(statements: statements)
        guard let statistic = statistics as? [Date : [Statement]] else {return}
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMMM-yyyy"
        
        print("\nПокупки отсортированные по датам\n")
        for date in statistic {
            if date.value.count > 0 {
                print("Дата - \(dateFormatter.string(from: date.key))")
                printStatementInfo(print: date.value)
            }
        }
    }
    
    ///Сортирует транзакции по категориям
    ///
    /// - Parameters:
    ///     - statements: Сортируемые транзакции
    public func printTransactionSortByCategory(statements: [Statement]) {
        sort.sortStrategy = SortByCategory()
        let statistics = sort.sortStrategy?.getStatistics(statements: statements)
        guard let statistic = statistics as? [TransactionKind : [Statement]] else {return}
        print("\nПокупки отсортированные по категориям\n")
        for category in statistic {
            if category.value.count > 0 {
                print("Категория - \(category.key.rawValue)")
                printStatementInfo(print: category.value)
            }
        }
    }
    
    ///Сортирует транзакции по количеству потраченных денег в каждой категории
    ///
    /// - Parameters:
    ///     - statements: Сортируемые транзакции
    public func printTransactionSortByTotalForCategories(statement: [Statement]) {
        sort.sortStrategy = SortByTotalForCategories()
        let statistics = sort.sortStrategy?.getStatistics(statements: statement)
        guard let statistic = statistics as? [TransactionKind : [ATMMoney]] else {return}
        print("\nВывод общей суммы потраченых денег по категориям\n")
        for stata in statistic {
            if stata.value.count > 0 {
                print("Категория - \(stata.key.rawValue)")
                for total in stata.value {
                    var value: Decimal = 0  //Переменная для хранения округленного значения типа Decimal
                    var temp: Decimal = total.value
                    NSDecimalRound(&value, &temp, 2, .plain)
                    print("Потрачено \(value) \(total.currency.grapheme.rawValue)")
                }
                print("\n")
            }
        }
    }
}
