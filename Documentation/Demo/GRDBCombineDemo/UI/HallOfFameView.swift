import SwiftUI
import GRDBCombine

struct HallOfFameView: View {
    @EnvironmentObject var viewModel: HallOfFameViewModel
    
    var body: some View {
        VStack {
            list
            toolbar
            }
            .navigationBarTitle(Text(viewModel.title))
    }
    
    var list: some View {
        List(viewModel.bestPlayers.identified(by: \.id)) {
            PlayerRow(player: $0)
        }
    }
    
    var toolbar: some View {
        HStack {
            Button(
                action: { Players.deletePlayers() },
                label: { Image(systemName: "trash")})
            Spacer()
            Button(
                action: { Players.refreshPlayers() },
                label: { Image(systemName: "arrow.clockwise")})
            Spacer()
            Button(
                action: { Players.stressTest() },
                label: { Text("💣") })
            }
            .padding()
        
    }
}

struct PlayerRow: View {
    var player: Player
    
    var body: some View {
        HStack {
            Text(player.name)
            Spacer()
            Text("\(player.score)")
        }
    }
}