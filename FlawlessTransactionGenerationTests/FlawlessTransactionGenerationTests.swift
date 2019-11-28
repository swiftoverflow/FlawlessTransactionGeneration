//
//  FlawlessTransactionGenerationTests.swift
//  FlawlessTransactionGenerationTests
//
//  Created by OMELCHUK Daniil on 28/11/2019.
//  Copyright © 2019 OMELCHUK Daniil. All rights reserved.
//

import XCTest
@testable import FlawlessTransactionGeneration

class FlawlessTransactionGenerationTests: XCTestCase {
    
    var transaction: FlawlessTransactionGeneration!

    override func setUp() {
        transaction = FlawlessTransactionGeneration()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testTransactionCount() {
        XCTAssertTrue(transaction.getRandomTransaction().count < 10, "Количество транзакций должно быть меньше 10")
    }

}
