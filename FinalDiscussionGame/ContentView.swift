import SwiftUI
import AVKit

//CHECKLIST ITEM MODEL
struct ChecklistItem: Identifiable {
    var id = UUID()
    var question: String
    var options: [String] = ["0", "1", "2", "3"]
    var selectedOption: Int? = nil
    var note: String? = ""
}

struct ContentView: View {
    @State private var progress = 0.0
    
    // Environment Property Wrappers for immersive space
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    
    @Environment(ViewController.self) var viewController
    
    // State variables
    @State private var selectedRoom: String = "Living Room" // Home Inspection Default room
    @State private var showInterviewQuestions = false
    @State private var checklistItems = [
            
            // Kitchen Section
            ChecklistItem(question: "Are the floors, sinks, and surfaces clean?"),
            ChecklistItem(question: "Is the fridge clean and storing food appropriately (i.e., within expiration dates)?"),
            ChecklistItem(question: "Are all cooking implements, cutlery, and crockery in good condition?"),
            ChecklistItem(question:"Are waste bins clean and not overflowing?"),
            ChecklistItem(question: "Is there adequate food and drink for the family’s size and needs?"),
            
            // Living Area Section
            ChecklistItem(question: "Are the floors clean and free of clutter?"),
            ChecklistItem(question: "Are there safety hazards like exposed wires or furniture blocking pathways?"),
            ChecklistItem(question: "Are the furniture and appliances in good condition?"),
            ChecklistItem(question: "Is the room well-lit and safe, especially for children?"),
            ChecklistItem(question: "Are smoke detectors installed and functioning properly?"),
            
            // Bathroom Section
            ChecklistItem(question: "Is the bathroom clean and free of mold?"),
            ChecklistItem(question: "Are the shower and bath facilities in working condition and safe for children?"),
            ChecklistItem(question: "Are there sufficient toiletries like soap, toilet paper, and towels?"),
            ChecklistItem(question: "Is the bathroom floor clean and dry to avoid slip hazards?"),
            ChecklistItem(question: "Is there proper ventilation (e.g., exhaust fan or window) to prevent moisture buildup?"),
                          
            
            // Bedroom Section
            ChecklistItem(question: "Is the bed in good condition with clean linens?"),
            ChecklistItem(question: "Is the bedroom free of clutter or items that could pose a safety risk?"),
            ChecklistItem(question: "Is the closet organized and free of sharp or hazardous objects?"),
            ChecklistItem(question: "Is the room a safe and quiet environment conducive to sleep?"),
            ChecklistItem(question: "Are smoke detectors installed and functioning in the bedroom?"),
            
        ]
    
        @State private var countdown = 1200 // 20 minutes in seconds
        @State private var timerColor: Color = .black
        @State private var timerIsActive = false
        @State private var showExitButton = false
        @State private var showRoomToolbar = true // Add this state for the toolbar visibility
        @Binding var checklistWindowWidth: CGFloat
        @Binding var showNotesPanel: Bool
    
        //CHECKLIST MAIN BUTTON STATES
        @State var checklistButtonActive: Bool = false
        @State var interviewButtonActive: Bool = false
        @State var notesButtonActive: Bool = false
        @State var isInstructorChecklist: Bool = false
        

    var body: some View {
        HStack{
            
            //MAIN USER HOME INSPECTION CHECKLIST
            VStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            //Social Work Logo Image
                            Image("Social Work Logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200)
                            Spacer()
                            HStack{
                                //CHECKLIST BUTTON
                                Button(action: {
                                    checklistButtonActive = true
                                    interviewButtonActive = false
                                }) {
                                    Label("Checklist", systemImage: "")
                                        .frame(minWidth: 80)
                                        .padding()
                                        .background(checklistButtonActive ? Color.blue : Color.gray)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                        .shadow(radius: 5)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .onAppear {
                                    checklistButtonActive = true
                                }
                                .padding(10)
                                
                                
                                //INTERVIEW BUTTON
                                Button(action: {
                                    showInterviewQuestions = true
                                    interviewButtonActive = true
                                    checklistButtonActive = false
                                    
                                }) {
                                    Label("Interview", systemImage: "")
                                        .frame(minWidth: 80)
                                        .padding()
                                        .background(isChecklistComplete() && interviewButtonActive ? Color.blue : Color.gray)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                        .shadow(radius: 5)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .disabled(!isChecklistComplete())
                                
                                
                                //TIMER
                                
                                if viewController.immersiveSpaceId != "360image"{
                                    // Timer display
                                    HStack {
                                        
                                        Text(timeFormatted(countdown)) //formatted time mm:ss
                                            .font(.custom("Avenir", size: 20))
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color.white)
                                            .padding()
                                            .background(timerColor)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                    .onAppear {
                                        startTimer() // Start the timer when the view appears
                                    }
                                }
                            }
                            .padding(10)
                        }
                        
                        
                        
                        
                        //CHECKLIST HEADER
                        
                        headerView
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.bottom, 40)
                        
                        
                        //CHECKLIST PROGRESS BAR
                        if viewController.immersiveSpaceId != "360image"{
                            ZStack {
                                Capsule()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 10)
                                
                                GeometryReader { geometry in
                                    Capsule()
                                        .fill(Color(red: 175 / 255.0, green: 182 / 255.0, blue: 255 / 255.0))
                                        .frame(width: geometry.size.width * CGFloat(progress / 100))
                                        .animation(.linear(duration: 0.3), value: progress)
                                }
                                .frame(height: 10)
                            }
                        }
                        
                        //.padding()
                        
                        //clientInformationView
                        //instructionsView
                        
                        if !interviewButtonActive {
                            checklistView(for: selectedRoom)
                        } else {
                            interviewQuestionsView
                        }
                    }
                    .padding(40)
                }
                .background(Color.white)
                .cornerRadius(20)
                .shadow(radius: 10)
                
                // Show the Exit button when the timer reaches 0
                if showExitButton &&  viewController.immersiveSpaceId != "360image"{
                    Button("Exit Home Inspection") {
                        Task {
                            showExitButton = false
                            notesButtonActive = true
                            viewController.appState = .discussion
                            viewController.immersiveSpaceId = "360image"
                            let _ = await openImmersiveSpace(id: viewController.immersiveSpaceId)
                            await viewController.updateSpatialTemplate()
                            print("immersive space id set to: \(viewController.immersiveSpaceId)")
                        }
                        
                    }
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding()
                } else {
                    RoomSelectionToolbar(viewController: _viewController, selectedRoom: $selectedRoom)
                }
            }
            
            
            
            
            //STACK 2
            if showNotesPanel{
                //INSTRUCTOR HOME INSPECTION CHECKLIST
                VStack {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                //Social Work Logo Image
                                Image("Social Work Logo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 200)
                                Spacer()
                            }
                            
                            headerInstructorView
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.bottom, 40)
                            //clientInformationView
                            //instructionsView
                            
                            if !interviewButtonActive {
                                instructorChecklistView(for: selectedRoom)
                            } else {
                                instructorInterviewView
                            }
                        }
                        
                        .padding(40)
                    }
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(radius: 10)
                    
                    // Show the Exit button when the timer reaches 0
                    if showExitButton &&  viewController.immersiveSpaceId != "360image"{
                        Button("Exit Home Inspection") {
                            Task {
                                showExitButton = false
                                notesButtonActive = true
                                viewController.appState = .discussion
                                viewController.immersiveSpaceId = "360image"
                                let _ = await openImmersiveSpace(id: viewController.immersiveSpaceId)
                                await viewController.updateSpatialTemplate()
                            }
                        }
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding()
                    } else {
                        // Room Selection Toolbar remains visible while timer is running
                        RoomSelectionToolbar(viewController: _viewController, selectedRoom: $selectedRoom)
                    }
                }
                
            }
        }
    }
    
    //CHECKLIST TITLE TEXT
    private var headerView: some View {
        Text("Social Worker Home Visit Checklist")
            .font(.custom("Avenir", size: 28))
            .fontWeight(.bold)
            .foregroundColor(.black)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 16)
    }
    
    private var headerInstructorView: some View {
        Text("Instructor Answer Checklist")
            .font(.custom("Avenir", size: 28))
            .fontWeight(.bold)
            .foregroundColor(.black)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 16)
    }
    
    //CALUCULATING PROGRESS BAR
    private func updateProgress() {
            let completedItems = checklistItems.filter { $0.selectedOption != nil }
            
        progress = Double(completedItems.count) / Double(20) * 100
            print("progress: ", progress)
            
    }

        // Timer Logic
        func startTimer() {
            countdown = 30 // 20 minutes in seconds
            timerIsActive = true
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                DispatchQueue.main.async {
                    if countdown > 0 {
                        countdown -= 1
                        if countdown <= 5 {
                            timerColor = .red
                        }
                    } else {
                        showExitButton = true
                    }
                }
            }
        }

        // Helper function to format the countdown time (mm:ss)
        func timeFormatted(_ totalSeconds: Int) -> String {
            let minutes = totalSeconds / 60
            let seconds = totalSeconds % 60
            return String(format: "%02d:%02d", minutes, seconds)
        }
    
    
    
    private func checklistView(for room: String) -> some View {
        
        VStack(alignment: .leading, spacing: 16) {
            HStack{
                //ROOM HEADER
                SectionHeader(title: room)
                
                //NOTES BUTTON TOGGLE
                HStack{
                    if viewController.immersiveSpaceId != "360image" {
                        Spacer()
                        Toggle("Notes", systemImage: notesButtonActive ? "text.page.fill" : "text.page.slash.fill", isOn: $notesButtonActive)
                            .tint(.gray)
                            .toggleStyle(.button)
                            .labelStyle(.iconOnly)
                            .font(.largeTitle)
                            .contentTransition(.symbolEffect)
                    }
                    else{
                        Spacer()
                        Button(action: {
                            showNotesPanel.toggle()
                            checklistWindowWidth = checklistWindowWidth == 675 ? 1370 : 675
                        }) {
                            Label {
                                Text("Answer")
                            } icon: {
                                Image(systemName: showNotesPanel ? "key.fill" : "key.slash.fill")
                            }
                            .frame(minWidth: 80)
                        }
                        .font(.custom("Avenir", size: 20))
                        .fontWeight(.semibold)
                        .contentTransition(.symbolEffect)
                        .foregroundColor(.black)
                        
                        
                    }
                     
                }
            }
            
            ForEach(checklistItemsForRoom(room)) { item in
                checklistItemView(item)
            }
        }
        //.padding()
    }
    
    private func checklistItemsForRoom(_ room: String) -> [ChecklistItem] {
        switch room {
        case "Living Room":
            return Array(checklistItems[5..<10])
        case "Kitchen":
            return Array(checklistItems[0..<5])
        case "Bathroom":
            return Array(checklistItems[10..<15])
        case "Bedroom":
            return Array(checklistItems[15..<20])
        default:
            return []
        }
    }
    
    @State private var text: String = ""
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
                                updateProgress()
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
                            .background(item.selectedOption == item.options.firstIndex(of: option) ? Color(red: 175 / 255.0, green: 182 / 255.0, blue: 255 / 255.0) : Color.gray)
                            .cornerRadius(10)
                            .foregroundColor(.black)
                            .font(.body)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.bottom, 10)
            
            if notesButtonActive{
                Text("Notes:")
                    .font(.headline)
                    .foregroundColor(.black)
                
                TextEditor(text: Binding(
                    get: { checklistItems.first(where: { $0.id == item.id })?.note ?? "" }, // Provide a default value
                    set: { newValue in
                        if let index = checklistItems.firstIndex(where: { $0.id == item.id }) {
                            checklistItems[index].note = newValue // Update the note value
                        }
                    }
                ))
                    .padding()
                    .border(Color.gray, width: 1)
                    .frame(height: 100)
                    .foregroundColor(.black)
            }
            

        }
        .padding(.vertical, 8)
    }
    
    func hideKeyboard() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    
    private func isChecklistComplete() -> Bool {
        let incompleteItems = checklistItems.filter { $0.selectedOption == nil }
        
        // Check if the items are all checked to generate the interview questions button
        let allCompleted = incompleteItems.isEmpty
        return allCompleted
    }
    
    //INSTRUCTOR CHECKLIST
    
    private func instructorChecklistView(for room: String) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: room)

            ForEach(checklistItemsForRoom(room).enumerated().map { index, item in
                ChecklistItem(
                    id: item.id,
                    question: item.question,
                    options: item.options,
                    selectedOption: instructorRatings[room]?[index] ?? 0,
                    note: instructorNotes[room]?[index] ?? ""
                )
            }) { item in
                instructorChecklistItemView(item)
            }
        }
    }

    // Move dummy data out of the function so it stays clean
    private let instructorNotes: [String: [String]] = [
        "Kitchen": [
            "Counters and sink are spotless.",
            "Fridge contents are up-to-date.",
            "Cutlery in excellent shape.",
            "Bins were recently emptied.",
            "Pantry is well-stocked."
        ],
        "Living Room": [
            "Tidy and no visible hazards.",
            "No exposed wires found.",
            "Couch needs minor repair.",
            "Plenty of natural light.",
            "Smoke detector working fine."
        ],
        "Bathroom": [
            "Clean and mold-free.",
            "Shower has good pressure.",
            "Toiletries well stocked.",
            "No slip risks detected.",
            "Window provides ventilation."
        ],
        "Bedroom": [
            "Linens freshly washed.",
            "No toys/clutter on floor.",
            "Closet is organized.",
            "Room feels calming and quiet.",
            "Detector beeps when tested."
        ]
    ]

    private let instructorRatings: [String: [Int]] = [
        "Kitchen": [3, 3, 2, 2, 3],
        "Living Room": [2, 3, 1, 3, 3],
        "Bathroom": [3, 2, 3, 2, 3],
        "Bedroom": [3, 2, 3, 2, 3]
    ]
    
    private func instructorChecklistItemView(_ item: ChecklistItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.question)
                .font(.body)
                .foregroundColor(.black)

            // Pre-selected option display (read-only)
            HStack {
                ForEach(item.options, id: \.self) { option in
                    Text(option)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(item.selectedOption == item.options.firstIndex(of: option)
                                    ? Color(red: 255 / 255.0, green: 203 / 255.0, blue: 5 / 255.0) : Color.gray)
                        .cornerRadius(10)
                        .foregroundColor(.black)
                        .font(.body)
                }
            }
            .padding(.bottom, 10)

            // 📝 Instructor Notes Display
            VStack(alignment: .leading, spacing: 4) {
                Text("Instructor Notes:")
                    .font(.headline)
                    .foregroundColor(.black)

                Text(item.note ?? "")
                    .font(.body)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.white))
                    .cornerRadius(8)
                    .foregroundColor(.black)
                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray, lineWidth: 1) // Border around the box
                                    )
            }
        }
        .padding(.vertical, 8)
    }
    
    
    
    
    
    @State private var notesText: String = ""
    @State private var interviewQuestionsStatus: [String: Bool] = [:] //dictionary to identify what questions are selected
    private var interviewQuestionsView: some View {
        VStack {
            HStack{
                Text("Interview Questions")
                    .font(.custom("Avenir", size: 28))
                    .fontWeight(.regular)
                    .padding()
                    .foregroundColor(.black)
                
                if viewController.immersiveSpaceId != "360image"{
                    Spacer()
                    Toggle("Notes", systemImage: notesButtonActive ? "text.page.fill" : "text.page.slash.fill", isOn: $notesButtonActive)
                        .tint(.gray)
                        .toggleStyle(.button)
                        .labelStyle(.iconOnly)
                        .font(.largeTitle)
                        .contentTransition(.symbolEffect)
                }
            }
            

            ForEach(interviewQuestions, id: \.self) { question in
                Button(action: {
                    if interviewQuestionsStatus[question] == nil {
                            interviewQuestionsStatus[question] = true // Initializing to true if not yet set
                        } else {
                            interviewQuestionsStatus[question]?.toggle() // Toggle the existing value
                        }
                   // playSampleVideo(for: question)
                }) {
                    Text(question)
                        .font(.custom("Avenir", size: 20))
                        .fontWeight(.semibold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(interviewQuestionsStatus[question] ?? false ? Color(red: 175 / 255.0, green: 182 / 255.0, blue: 255 / 255.0) : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.bottom, 8)
            }
            
            if notesButtonActive {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes:")
                                .font(.headline)
                                .foregroundColor(.black)
                            
                            TextEditor(text: $notesText)
                                .padding()
                                .frame(minHeight: 500)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                                .border(Color.gray, width: 1)
                                .foregroundColor(.black)
                        }
                        .padding(.top, 16)
                        .padding(.horizontal)
                    }
                
            
            
        }
    }
    
    private var instructorInterviewView: some View{
        VStack {
            HStack {
                Text("Interview Questions")
                    .font(.custom("Avenir", size: 28))
                    .fontWeight(.regular)
                    .padding()
                    .foregroundColor(.black)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(interviewQuestions, id: \.self) { question in
                    HStack {
                        Button(action: {
                        }) {
                            Text(question)
                                .font(.custom("Avenir", size: 20))
                                .fontWeight(.semibold)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(interviewQuestionsStatus[question] ?? false ? Color(red: 255 / 255.0, green: 203 / 255.0, blue: 5 / 255.0) : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(true)
                    }
                }
            }
            .padding(.top, 16)
            
            if notesButtonActive {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes:")
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    // Displaying the notes as static text
                    Text(sampleNotesText)
                        .padding()
                        .frame(minHeight: 500)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .border(Color.gray, width: 1)
                        .foregroundColor(.black)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, 16)
                .padding(.horizontal)
            }
        }
    }
    
    private let sampleNotesText = """
- The home’s living conditions were generally adequate, but there are some concerns with overcrowding in the children’s bedrooms.

- Parents reported feeling overwhelmed with managing the household and indicated a lack of support in caregiving tasks.

- There was a significant issue with sanitation in the kitchen area, as several items were observed to be dirty or improperly stored.

- Multiple safety hazards were identified throughout the home, including unsecured furniture that could pose a risk to young children.

- The children appeared well-nourished, but there were concerns about their access to sufficient educational resources, such as books or learning materials.
"""
    
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
                .font(.custom("Avenir", size: 24))
                .fontWeight(.regular)
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
        }
    }
    
    struct RoomSelectionToolbar: View {
        @Environment(ViewController.self) var viewController
        @Binding var selectedRoom: String
        
        var body: some View {
            HStack {
                // Living Room Button with Icon
                Button(action: {
                    selectedRoom = "Living Room"
                    if viewController.immersiveSpaceId != "360image"{
                        viewController.immersiveSpaceId = "LivingRoom_360"
                    }
                    
                    print("Immersive Space ID set to: \(viewController.immersiveSpaceId)")
                }) {
                    Label("Living", systemImage: "sofa.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(TabButtonStyle(isSelected: selectedRoom == "Living Room"))
                
                // Kitchen Button with Icon
                Button(action: {
                    selectedRoom = "Kitchen"
                    if viewController.immersiveSpaceId != "360image"{
                        viewController.immersiveSpaceId = "Kitchen_360"
                    }
                    
                    print("Immersive Space ID set to: \(viewController.immersiveSpaceId)")
                }) {
                    Label("Kitchen", systemImage: "fork.knife")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(TabButtonStyle(isSelected: selectedRoom == "Kitchen"))
                
                // Bathroom Button with Icon
                Button(action: {
                    selectedRoom = "Bathroom"
                    if viewController.immersiveSpaceId != "360image"{
                        viewController.immersiveSpaceId = "Bathroom_360"
                    }
                    print("Immersive Space ID set to: \(viewController.immersiveSpaceId)")
                }) {
                    Label("Bathroom", systemImage: "bathtub.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(TabButtonStyle(isSelected: selectedRoom == "Bathroom"))
                
                // Bedroom Button with Icon
                Button(action: {
                    selectedRoom = "Bedroom"
                    if viewController.immersiveSpaceId != "360image"{
                        viewController.immersiveSpaceId = "Bedroom_360"
                    }
                    
                    print("Immersive Space ID set to: \(viewController.immersiveSpaceId)")
                }) {
                    Label("Bedroom", systemImage: "bed.double.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(TabButtonStyle(isSelected: selectedRoom == "Bedroom"))
            }
            .padding(.bottom, 40)
            .padding(.leading, 20)
            .padding(.trailing, 20)
            .padding(.top, 10)
            .cornerRadius(8)
        }
    }
    
    
    // Define TabButtonStyle for custom button style
    struct TabButtonStyle: ButtonStyle {
        var isSelected: Bool
        
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .padding()
                .background(isSelected ? Color.blue : Color.gray.opacity(0.3))
                .cornerRadius(8)
                .foregroundColor(.white)
                .font(.body)
        }
    }
}
