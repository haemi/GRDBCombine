import Combine
import GRDB
import XCTest

class PlayersTests: XCTestCase {
    
    private func makeDatabase() throws -> DatabaseQueue {
        // Players needs a database.
        // Setup an in-memory database, for fast access.
        let database = DatabaseQueue()
        try AppDatabase().setup(database)
        return database
    }
    
    func testPopulateIfEmptyFromEmptyDatabase() throws {
        let database = try makeDatabase()
        let players = Players(database: database)
        
        try XCTAssertEqual(database.read(Player.fetchCount), 0)
        try XCTAssertTrue(players.populateIfEmpty())
        try XCTAssertGreaterThan(database.read(Player.fetchCount), 0)
    }
    
    func testPopulateIfEmptyFromNonEmptyDatabase() throws {
        let database = try makeDatabase()
        let players = Players(database: database)
        
        var player = Player(id: 1, name: "Arthur", score: 100)
        try database.write { db in
            try player.insert(db)
        }
        
        try XCTAssertFalse(players.populateIfEmpty())
        try XCTAssertEqual(database.read(Player.fetchAll), [player])
    }
    
    func testDeleteAll() throws {
        let database = try makeDatabase()
        let players = Players(database: database)
        
        try database.write { db in
            var player = Player(id: 1, name: "Arthur", score: 100)
            try player.insert(db)
        }
        
        try players.deleteAll()
        try XCTAssertEqual(database.read(Player.fetchCount), 0)
    }
    
    func testRefreshPopulatesEmptyDatabase() throws {
        let database = try makeDatabase()
        let players = Players(database: database)
        
        try XCTAssertEqual(database.read(Player.fetchCount), 0)
        try players.refresh()
        try XCTAssertGreaterThan(database.read(Player.fetchCount), 0)
    }
    
    func testPlayerCountPublisher() throws {
        let database = try makeDatabase()
        let players = Players(database: database)
        
        var actualElements: [Int] = []
        let expectation = self.expectation(description: "")
        let testSubject = PassthroughSubject<Int, Error>()
        let testCancellable = testSubject
            .collect(3)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case let .failure(error):
                        XCTFail("unexpected error \(error)")
                    case .finished:
                        break
                    }
            },
                receiveValue: { elements in
                    actualElements = elements
                    expectation.fulfill()
            })

        
        let playersCancellable = players
            .playerCountPublisher()
            .subscribe(testSubject)
        
        var player1 = Player(id: 1, name: "Arthur", score: 100)
        var player2 = Player(id: 2, name: "Barbara", score: 200)
        var player3 = Player(id: 3, name: "Craig", score: 300)
        try database.write { db in
            try player1.insert(db)
            try player2.insert(db)
        }
        try database.write { db in
            try player3.insert(db)
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        testCancellable.cancel()
        playersCancellable.cancel()
        
        XCTAssertEqual(actualElements, [0, 2, 3])
    }

    func testHallOfFamePublisher() throws {
        let database = try makeDatabase()
        let players = Players(database: database)
        
        var actualElements: [Players.HallOfFame] = []
        let expectation = self.expectation(description: "")
        let testSubject = PassthroughSubject<Players.HallOfFame, Error>()
        let testCancellable = testSubject
            .collect(3)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case let .failure(error):
                        XCTFail("unexpected error \(error)")
                    case .finished:
                        break
                    }
            },
                receiveValue: { elements in
                    actualElements = elements
                    expectation.fulfill()
            })

        
        let playersCancellable = players
            .hallOfFamePublisher(maxPlayerCount: 1)
            .subscribe(testSubject)
        
        var player1 = Player(id: 1, name: "Arthur", score: 100)
        var player2 = Player(id: 2, name: "Barbara", score: 200)
        var player3 = Player(id: 3, name: "Craig", score: 300)
        try database.write { db in
            try player1.insert(db)
            try player2.insert(db)
        }
        try database.write { db in
            try player3.insert(db)
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        testCancellable.cancel()
        playersCancellable.cancel()
        
        let expectedElements: [Players.HallOfFame] = [
            Players.HallOfFame(playerCount: 0, bestPlayers: []),
            Players.HallOfFame(playerCount: 2, bestPlayers: [player2]),
            Players.HallOfFame(playerCount: 3, bestPlayers: [player3]),
        ]
        XCTAssertEqual(actualElements, expectedElements)
    }
}
