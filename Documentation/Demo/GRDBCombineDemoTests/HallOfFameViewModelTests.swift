import GRDB
import XCTest

class HallOfFameViewModelTests: XCTestCase {
    // TODO: test title, titlePublisher, bestPlayersPublisher, objectWillChange
    
    override func setUp() {
        // HallOfFameViewModel needs a Current World.
        // Setup one with an in-memory database, for fast access.
        let dbQueue = DatabaseQueue()
        try! AppDatabase().setup(dbQueue)
        Current = World(database: { dbQueue })
    }
    
    func testInitialStateFromEmptyDatabase() throws {
        let viewModel = HallOfFameViewModel()
        XCTAssertTrue(viewModel.bestPlayers.isEmpty)
    }
    
    func testInitialStateFromNonEmptyDatabase() throws {
        try Current.players().populateIfEmpty()
        let viewModel = HallOfFameViewModel()
        XCTAssertFalse(viewModel.bestPlayers.isEmpty)
    }
}
