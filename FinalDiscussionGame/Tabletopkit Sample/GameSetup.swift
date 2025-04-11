/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Setup of the table for the game.
*/

import TabletopKit
import RealityKit
import SwiftUI
import TabletopGameSampleContent
import Spatial

enum GameMetrics {
    static let tableEdge: Float = 0.7
    static let tableThickness: Float = 0.0146
    static let playerAreaDistanceFromCenter: Float = 0.29
    static let boardEdge: Float = 0.4
    static let smallHeight: Float = 0.001
    static let boardHeight: Float = 0.055
    static let playerAreaSize: SIMD2<Float> = SIMD2(0.4, 0.1)
    static let playerHandSize: SIMD2<Float> = SIMD2(0.2, 0.1)
}

@MainActor
class GameSetup {
    let root: Entity
    var setup: TableSetup
    //let board: Board
    //var cardStockGroup: CardStockGroup
    let counter: ScoreCounter
    var pawns: [PlayerPawn] = []
    var cards: [Card] = []
    var seats: [PlayerSeat] = []
    var miniCards: [Card] = []

    // This is an incrementing counter to generate unique IDs for each piece of equipment.
    struct IdentifierGenerator {
        private var count = 0

        mutating func newId() -> Int {
            count += 1
            return count
        }
    }
    var idGenerator = IdentifierGenerator()

    /*
     The table has a board in the center,
     with a hand and a pawn for each player around the sides.
     The side without a seat has the deck and the die.
     
            +---+
            |die|   +------+
            +---+   | deck |
                    +------+
       pawn
       +-+     +---+-+-+-+-+-+-+---+
       +-+     |   | | | | | | |   |
               +---+-+-+-+-+-+-+---+  +-----+
     +-----+   |---|           |---|  |     |
     |     |   |---|           |---|  |hand |
     |hand |   |---|  board    |---|  |     |
     |     |   |---|           |---|  |     |
     |     |   |---|           |---|  |     |
     |     |   +---+-+-+-+-+-+-+---+  +-----+
     +-----+   |   | | | | | | |   |
               +---+-+-+-+-+-+-+---+    +-+
                                        +-+
           +-+   +-----------+          pawn
           +-+   |           |
           pawn  |   hand    |
                 +-----------+
     */
    var normalDeckGroup: CardStockGroup
    var miniDeckGroup: CardStockGroup

    init(root: Entity) {
        self.root = root
        setup = TableSetup(tabletop: Table())

        // Fill `seats` array
        for (index, pose) in PlayerSeat.seatPoses.enumerated() {
            let seat = PlayerSeat(id: TableSeatIdentifier(index), pose: pose)
            seats.append(seat)
            setup.add(seat: seat)
        }

        // Initialize normal & mini deck groups
        normalDeckGroup = CardStockGroup(id: EquipmentIdentifier(idGenerator.newId()))
        miniDeckGroup   = CardStockGroup(id: EquipmentIdentifier(idGenerator.newId()))
        setup.add(equipment: normalDeckGroup)
        setup.add(equipment: miniDeckGroup)

        // Initialize the counter
        counter = ScoreCounter(id: .init(idGenerator.newId()))
        setup.add(counter: counter)

        // No “return” statements inside init!
        // Nothing else you need here if you have no more stored properties.

        // init now ends properly, with all properties assigned.
    }





    
   /* func loadRoadGroups() {
        for tileConfig in ConveyorTile.tiles {
            // Transform from a pose on a unit square to an absolute pose in the table's coordinate space.
            let positionX = (tileConfig.0.x - 0.5) * ConveyorTile.positionScale
            let positionY = (tileConfig.0.z - 0.5) * ConveyorTile.positionScale
            let tile = ConveyorTile(id: EquipmentIdentifier(self.idGenerator.newId()),
                                    boardID: board.id,
                                    position: .init(x: positionX, z: positionY),
                                    category: tileConfig.1)
            setup.add(equipment: tile)
        }
    } */
    
    func loadPlayerCardGroups() {
        for seat in self.seats {
            let group = CardGroup(id: EquipmentIdentifier(self.idGenerator.newId()), seat: seat, root: root)
            setup.add(equipment: group)
        }
    }
    
    func loadEntityEquipment() {
        // --- Normal/Full Cards ---
        let cardEntities = [
            (try! ModelEntity.load(named: "card_arm_01_assembly", in: tabletopGameSampleContentBundle), Card.Classification.arm),
            (try! ModelEntity.load(named: "card_flower_01_assembly", in: tabletopGameSampleContentBundle), Card.Classification.flower),
            (try! ModelEntity.load(named: "card_leg_01_assembly", in: tabletopGameSampleContentBundle), Card.Classification.leg)
        ]

        let audioResource = try! AudioFileResource.load(named: "/Root/pickUpCard_mp3",
                                                        from: "static_scene.usda",
                                                        in: tabletopGameSampleContentBundle)

        // For example, create 5 copies of each normal card:
        for _ in 0..<5 {
            for cardEntity in cardEntities {
                let card = Card(
                    id: EquipmentIdentifier(idGenerator.newId()),
                    classification: cardEntity.1,
                    parent: normalDeckGroup.id,  // <-- Assign to normalDeckGroup
                    entity: cardEntity.0.clone(recursive: true),
                    audioResource: audioResource
                )
                cards.append(card)
                setup.add(equipment: card)
            }
        }

        // --- Mini/Green Cards ---
        let flowerEntity = try! ModelEntity.load(named: "miniCard", in: tabletopGameSampleContentBundle)
        for _ in 0..<10 {
            let miniCard = Card(
                id: EquipmentIdentifier(idGenerator.newId()),
                classification: .flower,
                parent: miniDeckGroup.id,  // <-- Assign to miniDeckGroup
                entity: flowerEntity.clone(recursive: true),
                audioResource: audioResource
            )
            miniCards.append(miniCard)
            setup.add(equipment: miniCard)
        }
    }

}

extension Game {
    @MainActor

    func resetGame() {
        // Optional: Move both deck groups back to the center or hide one.
        // For example, show normal deck at center:
        showNormalDeck()
    }
    @MainActor
    func showNormalDeck() {
        // First, re-parent any loose mini cards back under `miniDeckGroup`.
        for card in setup.miniCards {
            tabletopGame.addAction(
                .moveEquipment(
                    matching: card.id,
                    childOf: setup.miniDeckGroup.id
                )
            )
        }

        // Then move miniDeckGroup out of sight:
        tabletopGame.addAction(
            .moveEquipment(
                matching: setup.miniDeckGroup.id,
                childOf: .tableID,
                pose: .init(position: .init(x: 2.0, z: 2.0),
                            rotation: .degrees(0))
            )
        )

        // Lastly, bring the normal deck in:
        tabletopGame.addAction(
            .moveEquipment(
                matching: setup.normalDeckGroup.id,
                childOf: .tableID,
                pose: .init(position: .init(x: 0, z: 0),
                            rotation: .degrees(90))
            )
        )
    }


    @MainActor
    func showMiniDeck() {
        // Move normal deck out of sight:
        tabletopGame.addAction(
            .moveEquipment(
                matching: setup.normalDeckGroup.id,
                childOf: .tableID,
                pose: .init(position: .init(x: 2.0, z: 2.0),
                            rotation: .degrees(0))
            )
        )

        // Center the mini deck:
        tabletopGame.addAction(
            .moveEquipment(
                matching: setup.miniDeckGroup.id,
                childOf: .tableID,
                pose: .init(position: .init(x: 0, z: 0),
                            rotation: .degrees(90))
            )
        )
    }



}



