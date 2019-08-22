import Combine
import GRDB
import GRDBCombine
import Dispatch

/// Players is responsible for high-level operations on the players database.
struct Players {
    private let database: DatabaseWriter
    
    init(database: DatabaseWriter) {
        self.database = database
    }
    
    // MARK: - Modify Players
    
    /// Creates random players if needed, and returns whether the database
    /// was empty.
    @discardableResult
    func populateIfEmpty() throws -> Bool {
        return try database.write(_populateIfEmpty)
    }
    
    func deleteAll() throws {
        try database.write(_deleteAll)
    }
    
    func refresh() throws {
        try database.write(_refresh)
    }
    
    func stressTest() {
        for _ in 0..<50 {
            DispatchQueue.global().async {
                try? self.refresh()
            }
        }
    }
    
    // MARK: - Access Players
    
    /// A Hole of Fame
    struct HallOfFame: Equatable {
        /// Total number of players
        var playerCount: Int
        
        /// The best ones
        var bestPlayers: [Player]
    }
    
    /// A publisher that tracks changes in the Hall of Fame
    func hallOfFamePublisher(maxPlayerCount: Int) -> DatabasePublishers.Value<HallOfFame> {
        ValueObservation
            .tracking(value: { db in
                let playerCount = try Player.fetchCount(db)
                let bestPlayers = try Player
                    .limit(maxPlayerCount)
                    .orderByScore()
                    .fetchAll(db)
                return HallOfFame(playerCount: playerCount, bestPlayers: bestPlayers)
            })
            .publisher(in: database)
    }
    
    /// A publisher that tracks changes in the number of players
    func playerCountPublisher() -> DatabasePublishers.Value<Int> {
        ValueObservation
            .tracking(value: Player.fetchCount)
            .publisher(in: database)
    }
    
    // MARK: - Implementation
    //
    // ⭐️ Good practice: when we want to update the database, we define methods
    // that accept a Database connection, because they can easily be composed.
    
    /// Creates random players if needed, and returns whether the database
    /// was empty.
    private func _populateIfEmpty(_ db: Database) throws -> Bool {
        if try Player.fetchCount(db) > 0 {
            return false
        }
        
        // Insert new random players
        for _ in 0..<8 {
            var player = Player(id: nil, name: Player.randomName(), score: Player.randomScore())
            try player.insert(db)
        }
        return true
    }
    
    private func _deleteAll(_ db: Database) throws {
        try Player.deleteAll(db)
    }
    
    private func _refresh(_ db: Database) throws {
        if try _populateIfEmpty(db) {
            return
        }
        
        // Insert a player
        if Bool.random() {
            var player = Player(id: nil, name: Player.randomName(), score: Player.randomScore())
            try player.insert(db)
        }
        // Delete a random player
        if Bool.random() {
            try Player.order(sql: "RANDOM()").limit(1).deleteAll(db)
        }
        // Update some players
        for var player in try Player.fetchAll(db) where Bool.random() {
            try player.updateChanges(db) {
                $0.score = Player.randomScore()
            }
        }
    }
}
