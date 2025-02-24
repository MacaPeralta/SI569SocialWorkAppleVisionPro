import SwiftUI
import AVKit

// Model for checklist items
struct ChecklistItem: Identifiable {
    var id = UUID()
    var question: String
    var options: [String] = ["0", "1", "2", "3"]
    var selectedOption: Int? = nil
}

struct ContentView: View {
    
    @Binding var immersiveSpaceID: String //Changing id for different immersive space 360 views
    
    // Environment Property Wrappers for immersive space
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    
    // State variables
    @State private var immersiveSpaceActive: Bool = false
    @State private var selectedRoom: String = "Living Room" // Default room
    @State private var showInterviewQuestions = false
    @State private var checklistItems = [
            
            // Kitchen Section
            ChecklistItem(question: "Are the floors, sinks, and surfaces clean?"),
            ChecklistItem(question: "Is the fridge clean?"),
            ChecklistItem(question: "Is there an adequate amount of food and drink present for the size of their family?"),
            ChecklistItem(question: "Are all foods and drinks stored appropriately, within expiration dates?"),
            ChecklistItem(question: "Are waste bins clean and not overflowing?"),
            ChecklistItem(question: "No moldy or rotten smells?"),
            ChecklistItem(question: "Are cooking implements, cutlery, and crockery in good condition?"),
            ChecklistItem(question: "Are the walls, doors, and windows in good condition?"),
            
            // Living Area Section
            ChecklistItem(question: "Are the floors clean and free of clutter?"),
            ChecklistItem(question: "Are there safety hazards like exposed wires or furniture blocking pathways?"),
            ChecklistItem(question: "Are the furniture and appliances in good condition?"),
            ChecklistItem(question: "Is there adequate lighting in the room?"),
            ChecklistItem(question: "Are the windows clean and in good condition?"),
            
            // Bathroom Section
            ChecklistItem(question: "Is the bathroom clean and free of mold?"),
            ChecklistItem(question: "Are the shower and bath facilities in working condition?"),
            ChecklistItem(question: "Are there sufficient toiletries like soap, toilet paper, and towels?"),
            ChecklistItem(question: "Is the bathroom floor clean and dry?"),
            
            // Bedroom Section
            ChecklistItem(question: "Is the bed in good condition with clean linens?"),
            ChecklistItem(question: "Is the bedroom free of clutter?"),
            ChecklistItem(question: "Is the closet organized and free of hazards?"),
        ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                headerView
                roomTabsView
                clientInformationView
                instructionsView
                
                if !showInterviewQuestions {
                    checklistView(for: selectedRoom)
                    generateInterviewQuestionsButton
                } else {
                    interviewQuestionsView
                }
            }
            .padding(40)
        }
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
        
        // Button to control the immersive environment
        Button(immersiveSpaceActive ? "Exit Environment" : "View Environment") {
            Task {
                if !immersiveSpaceActive {
                    let result = await openImmersiveSpace(id: immersiveSpaceID) // Use immersiveSpaceID here
                    immersiveSpaceActive = true
                } else {
                    await dismissImmersiveSpace()
                    immersiveSpaceActive = false
                }
            }
        }
        .padding()
    }
    
    // Title and Room Tabs View
    private var headerView: some View {
        Text("Social Worker Home Visit Checklist")
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(.black)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 16)
    }
    
    private var roomTabsView: some View {
        HStack {
            Button("Living Room") {
                selectedRoom = "Living Room"
                immersiveSpaceID = "LivingRoom_360"
                print("Immersive Space ID set to: \(immersiveSpaceID)")
            }
            .buttonStyle(TabButtonStyle(isSelected: selectedRoom == "Living Room"))

            Button("Kitchen") {
                selectedRoom = "Kitchen"
                immersiveSpaceID = "Kitchen_360"
                print("Immersive Space ID set to: \(immersiveSpaceID)")
            }
            .buttonStyle(TabButtonStyle(isSelected: selectedRoom == "Kitchen"))

            Button("Bathroom") {
                selectedRoom = "Bathroom"
                immersiveSpaceID = "Bathroom_360"
            }
            .buttonStyle(TabButtonStyle(isSelected: selectedRoom == "Bathroom"))

            Button("Bedroom") {
                selectedRoom = "Bedroom"
                immersiveSpaceID = "Bedroom_360"
            }
            .buttonStyle(TabButtonStyle(isSelected: selectedRoom == "Bedroom"))
        }
        .padding(.top, 10)
    }
    
    private func checklistView(for room: String) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: room)
            ForEach(checklistItemsForRoom(room)) { item in
                checklistItemView(item)
            }
        }
        .padding()
    }
    
    private func checklistItemsForRoom(_ room: String) -> [ChecklistItem] {
        switch room {
        case "Living Room":
            return Array(checklistItems[8..<13]) // Adjust these ranges as per the data and any added checklist item questions
        case "Kitchen":
            return Array(checklistItems[0..<8])
        case "Bathroom":
            return Array(checklistItems[13..<17])
        case "Bedroom":
            return Array(checklistItems[17..<20])
        default:
            return []
        }
    }
    
    private func checklistItemView(_ item: ChecklistItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.question)
                .font(.body)
                .foregroundColor(.black)
            
            HStack {
                ForEach(item.options, id: \.self) { option in
                    Button(action: {
                        if let selectedIndex = item.options.firstIndex(of: option) {
                            if let index = checklistItems.firstIndex(where: { $0.id == item.id }) {
                                checklistItems[index].selectedOption = selectedIndex
                                
                                // Print the updated selection
                                print("Selected Option for '\(item.question)': \(option) (Index: \(selectedIndex))")
                                
                                // Call isChecklistComplete to update the button state
                                print("isChecklistComplete() result: \(isChecklistComplete())")
                            }
                        }
                    }) {
                        Text(option)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(item.selectedOption == item.options.firstIndex(of: option) ? Color.green : Color.gray.opacity(0.3))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                            .font(.body)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private var generateInterviewQuestionsButton: some View {
        Button(action: {
            if isChecklistComplete() {
                showInterviewQuestions = true
            }
        }) {
            Text("Generate Interview Questions")
                .frame(maxWidth: .infinity)
                .padding()
                .background(isChecklistComplete() ? Color.blue : Color.gray)
                .cornerRadius(8)
                .foregroundColor(.white)
                .font(.headline)
        }
        .disabled(!isChecklistComplete())
    }
    
    private func isChecklistComplete() -> Bool {
        let incompleteItems = checklistItems.filter { $0.selectedOption == nil }
        
        // Check if the items are all checked to generate the interview questions button
        let allCompleted = incompleteItems.isEmpty
        return allCompleted
    }
    
    private var interviewQuestionsView: some View {
        VStack {
            Text("Interview Questions")
                .font(.title)
                .padding()

            ForEach(interviewQuestions, id: \.self) { question in
                Button(action: {
                    playSampleVideo(for: question)
                }) {
                    Text(question)
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.bottom, 8)
            }
        }
    }
    
    private func playSampleVideo(for question: String) {
        print("Playing video for question: \(question)")
        
        // Use the same video URL for all questions
        guard let videoURL = URL(string: "https://www.youtube.com/watch?v=zPmAGTft4as") else {
            print("Invalid video URL!")
            return
        }

        // Create an AVPlayer
        let player = AVPlayer(url: videoURL)
        
        // Create an AVPlayerViewController
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player

        // Present the video regardless of immersive space
        if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
            rootViewController.present(playerViewController, animated: true) {
                // Start playing the video
                player.play()
            }
        }
    }

    // Sample interview questions
    private var interviewQuestions: [String] {
        [
            "Question 1: How do you ensure safety in the home?",
            "Question 2: Describe a time you handled a difficult situation.",
            "Question 3: What steps do you take to ensure child welfare?",
            "Question 4: How do you manage family dynamics?",
            "Question 5: How do you assess the child's well-being?",
            "Question 6: What resources do you suggest to families in need?",
            "Question 7: How do you ensure confidentiality in your reports?"
        ]
    }
    
    private struct SectionHeader: View {
        var title: String
        var body: some View {
            Text(title)
                .font(.headline)
                .foregroundColor(.black)
                .padding(.top, 20)
                .padding(.bottom, 5)
        }
    }
    
    private var clientInformationView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Client Information")
                .font(.headline)
                .padding(.top, 10)
                .foregroundColor(.black)
            
            Text("Full Name: ________________________________")
                .font(.body)
                .foregroundColor(.gray)
            Text("Date of Birth: ______________________________")
                .font(.body)
                .foregroundColor(.gray)
            Text("Date of Home Visit: _______________________")
                .font(.body)
                .foregroundColor(.gray)
            Text("Address: ___________________________________")
                .font(.body)
                .foregroundColor(.gray)
        }
    }
    
    private var instructionsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Instructions: For each of the questions below, provide a score between 0 to 3:")
                .font(.body)
                .foregroundColor(.black)
                .padding(.top, 10)
        }
    }
}

// Custom button style for tabs
struct TabButtonStyle: ButtonStyle {
    var isSelected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
            .foregroundColor(isSelected ? .white : .black)
            .cornerRadius(8)
            .font(.headline)
            .scaleEffect(configuration.isPressed ? 1.1 : 1)
            .animation(.easeInOut, value: configuration.isPressed)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(immersiveSpaceID: .constant("LivingRoom_360"))
    }
}
