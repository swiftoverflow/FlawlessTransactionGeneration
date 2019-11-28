//
//  FlawlessValidation.swift
//  FlawlessValidation
//
//  Created by OMELCHUK Daniil on 28/11/2019.
//  Copyright © 2019 OMELCHUK Daniil. All rights reserved.
//

import Foundation

public final class FlawlessValidation {
    
    public init() {}
    
    // MARK: - Форматирование
    
    ///Форматирвоание номера телефона
    /// - Parameters:
    ///     - phoneNumber: Телефонный номер для форматирования
    /// - Returns:
    ///     Возвращает форматированную строку номера телефона
    public func toPhoneNumber(phoneNumber: String) -> String {
        
        var onlyNumberString: String = getOnlyNumberString(string: phoneNumber)
        
        guard onlyNumberString.count == 11 else { return "" }
        
        if onlyNumberString.hasPrefix("8") {
            onlyNumberString.remove(at: onlyNumberString.startIndex)
            return onlyNumberString.replacingOccurrences(of: "(\\d{3})(\\d{3})(\\d{2})", with: "+7 ($1) $2-$3-$4", options: .regularExpression, range: nil)
        } else {
            return onlyNumberString.replacingOccurrences(of: "(\\d{1})(\\d{3})(\\d{3})(\\d{2})", with: "+$1 ($2) $3-$4-$5", options: .regularExpression, range: nil)
        }
    }
    
    ///Возвращает только числа из строки
    ///
    /// - Parameters:
    ///     - string: Строка для извлечения цифр
    /// - Returns:
    ///     Строка содержащая только цифры
    private func getOnlyNumberString(string: String) -> String {
        let onlyNumberString: String = string
            .components(separatedBy:CharacterSet.decimalDigits.inverted)
            .joined()
        
        return onlyNumberString
    }
    
    ///Форматирования номера карты
    /// - Parameters:
    ///     - cardNumber: Номер карты
    /// - Returns:
    ///     Возвращает форматированную строку карты
    public func toCardFormat(cardNumber: String) -> String {
        
        guard cardNumber.count >= 16 && cardNumber.count <= 19 else { return "" }
        
        let indexForFirstTuple: String.Index =  cardNumber.index(cardNumber.startIndex, offsetBy: 4)
        let indexForSecondTuple: String.Index =  cardNumber.index(indexForFirstTuple, offsetBy: 4)
        let indexForThirdTuple: String.Index = cardNumber.index(indexForSecondTuple, offsetBy: 4)
        
        let firstTuple: String = String(cardNumber[..<indexForFirstTuple])
        let secondTuple: String = String(cardNumber[indexForFirstTuple..<indexForSecondTuple])
        let thirdTuple: String = String(cardNumber[indexForSecondTuple..<indexForThirdTuple])
        let fourthTuple: String = String(cardNumber[indexForThirdTuple..<cardNumber.endIndex])
        
        return "\(firstTuple)-\(secondTuple)-\(thirdTuple)-\(fourthTuple)"
    }
    
    ///Форматирвоание номера счета
    /// - Parameters:
    ///     - accountNumber: Номер счета
    /// - Returns:
    ///     Возвращает форматированную строку счета
    public func toAccountFormat(accountNumber: String) -> String {
        let onlyNumberString: String = getOnlyNumberString(string: accountNumber)
        guard onlyNumberString.count == 20 else { return "" }
        return onlyNumberString.replacingOccurrences(of: "(\\d{3})(\\d{2})(\\d{3})(\\d{1})(\\d{4})(\\d{7})", with: "$1—$2—$3—$4—$5—$6", options: .regularExpression, range: nil)
    }
    
    // MARK: - Валидация
    
    ///Валидация номера каты с помощью Алгоритма Луна
    /// - Parameters:
    ///     - cardNumber: Номер карты
    /// - Returns:
    ///     true - если номер карты валиден, false - если номер карты не валиден
    public func PanValidate(cardNumber: String) -> Bool {
        let panInInt: [Int] = cardNumber.compactMap{Int(String($0))}
        var newPan: [Int] = panInInt
        
        for (index, element) in panInInt.enumerated() {
            if (index + 1) % 2 != 0 {
                let doubledElement = element * 2
                newPan[index] = doubledElement
                if newPan[index] > 9 {
                    newPan[index] = newPan[index] - 9
                }
            }
        }
        let totalSum: Int = newPan.reduce(0, +)
        if totalSum % 10 == 0 {
            print("\nВалидация номера карты пройдена")
            return true
        } else {
            print("\nВалидация номера карты не пройдена")
            return false
        }
    }
    
    ///Валидация счета с использования БИК для этого счета
    /// - Parameters:
    ///     - accountNumber: Номер счета
    ///     - bik: Номер БИК
    /// - Returns:
    ///     Возвращает true  - валидный, false - не валидный
    public func isValid(accountNumber: String, bik: String) -> Bool {
        let accountInInt: [Int] = accountNumber.compactMap{Int(String($0))}     // перевод строки в массив интов
        let bikInInt: [Int] = bik.compactMap{Int(String($0))}
        
        let bikRs: ArraySlice<Int> = bikInInt.suffix(3) + accountInInt  // 3 последних цифры БИК + счет
        
        let coefficients: [Int] = [7, 1, 3, 7, 1, 3, 7, 1, 3, 7, 1, 3, 7, 1, 3, 7, 1, 3, 7, 1, 3, 7, 1]
        
        let proizv: [Int] = zip(coefficients, bikRs).map { $0 * $1 }  // произведение БИК + счет на коэффициенты
        
        var sum: Int = 0
        for i in proizv {
            sum += i % 10   // сумма младших разрядов
            
        }
        if sum % 10 == 0 {  // если младший разряд полученной суммы равен 0, то расчетный счет считается верным
            print("\n\n\nСчет прошел валидацию")
            return true
        } else {
            print("\nСчет не прошел валидацию")
            return false
        }
    }
    
    ///Валидация ИНН
    /// - Parameters:
    ///     - innString: Номер ИНН
    /// - Returns:
    ///     true - если ИНН валиден, false - если ИНН не валиден
    public func innValidation(innString: String) -> Bool {
        
        switch innString.count {
        case 10:
            if tenLengthInnValidation(validate: innString) {
                print("10-ти значный ИНН валиден")
                return true
            }
            else {
                print("10-ти значный ИНН не валиден")
                return false
            }
        case 12:
            if twelveLengthInnValidation(validate: innString) {
                print("12-ти значный ИНН валиден")
                return true
            }
            else {
                print("12-ти значный ИНН не валиден")
                return false
            }
        default:
            print("Не правильный инн")
        }
        
        return false
    }
    
    ///Валидация 10-ти значного ИНН
    ///
    /// - Parameters:
    ///     - inn: Номер ИНН
    /// - Returns:
    ///     true - если ИНН валиден, false - если ИНН не валиден
    private func tenLengthInnValidation(validate inn: String) -> Bool {
        let innIntArray: [Int] = inn.compactMap{Int(String($0))}
        let checkTenDigits: [Int] = [2, 4, 10, 3, 5, 9, 4, 6, 8]
        
        let checkSum: Int = calculateCkeckSum(for: innIntArray, checkDigits: checkTenDigits)
        let checkNumber: Int = checkSum % 11 % 10
        
        if checkNumber == innIntArray[9]{
            return true
        }
        return false
    }
    
    ///Валидация 12-ти значного ИНН
    ///
    /// - Parameters:
    ///     - inn: Номер ИНН
    /// - Returns:
    ///     true - если ИНН валиден, false - если ИНН не валиден
    private func twelveLengthInnValidation(validate inn: String) -> Bool {
        let innIntArray: [Int] = inn.compactMap{Int(String($0))}
        let checkElevenDigits: [Int] = [7, 2, 4, 10, 3, 5, 9, 4, 6, 8]
        let checkTwelveDigits: [Int] = [3, 7, 2, 4, 10, 3, 5, 9, 4, 6, 8]
        
        let checkElevenSum: Int = calculateCkeckSum(for: innIntArray, checkDigits: checkElevenDigits)
        let checkElevenNumber: Int = checkElevenSum % 11 % 10
        
        let checkTwelveSum: Int = calculateCkeckSum(for: innIntArray, checkDigits: checkTwelveDigits)
        let checkTwelveNumber: Int = checkTwelveSum % 11 % 10
        
        if checkElevenNumber == innIntArray[10] && checkTwelveNumber == innIntArray[11] {
            return true
        }
        return false
    }
    
    ///Вычисляет контрольную сумму с определнными весовыми коэффициентами
    ///
    /// - Parameters:
    ///     - array: Номер ИНН
    ///     - checkDigits: Весовые коэффийциенты
    /// - Returns:
    ///     Возвращается контрольная сумма
    private func calculateCkeckSum(for array: [Int], checkDigits: [Int]) -> Int {
        var sum: Int = 0
        for i in 0..<checkDigits.count {
            sum += array[i] * checkDigits[i]
        }
        return sum
    }
    
    // MARK: - Работа с датами
    
    ///Генерирует случайное значение даты не позднее days с текущего момента
    ///
    /// - Parameters:
    ///     - days: Количество дней назад в рамках которых можно генерировать дату
    /// - Returns:
    ///     Сгенерированная дата
    public func randomDate(days: Int) -> Date {
        // Получаем интервал для текущей даты
        let interval: TimeInterval =  Date().timeIntervalSince1970
        // В дне 86 400 миллисекунд
        // Умножаем 86 400 миллисекунд на допустимый диапазон дней.
        let intervalRange: Double = Double(86_400 * days)
        // Выбираем случайный моментв интервале
        let random: Double = Double.random(in: 0...intervalRange)
        //Чтобы дата была только в прошлом
        let newInterval: Double = interval - random
        
        return Date(timeIntervalSince1970: newInterval)
    }
    
    ///Генерирует дату равная days назад в соответствии с текущим временем
    ///
    /// - Parameters:
    ///     - days: Количество дней назад от текущей даты
    /// - Returns:
    ///     Сгенерированную дату
    public func getDateFrom(daysAgo days: Int) -> Date {
        // Получаем интервал для текущей даты
        let interval: TimeInterval =  Date().timeIntervalSince1970
        // В дне 86 400 миллисекунд
        // Умножаем 86 400 миллисекунд на допустимый диапазон дней.
        let intervalRange: Double = Double(86_400 * days)
        //Получаем дату days дней назад
        let newInterval: Double = interval - intervalRange
        
        return Date(timeIntervalSince1970: newInterval)
    }
    
    ///Подсчитывает количество дней до введенной даты
    ///
    /// - Parameters:
    ///     - secondDate: Введенная дата
    /// - Returns:
    ///     Разница в днях между двумя датами
    public func getDaysInterval(from firstDate: Date, to secondDate: Date, calendar: Calendar = Calendar.current) -> Int {
        return calendar.dateComponents([.day], from: firstDate, to: secondDate).day!
    }
}
