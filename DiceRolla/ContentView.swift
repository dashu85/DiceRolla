//
//  ContentView.swift
//  DiceRolla
//
//  Created by Marcus Benoit on 11.09.24.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: \PersistentDiceRollResult.date, order: .reverse) private var savedResults: [PersistentDiceRollResult]
    
    @State private var numberOfSides: Int = 6
    @State private var numberOfDice: Int = 3
    @State private var totalAmount: Int = 0
    // Actual results of the roll
    @State private var diceRollResults = [TemporaryDiceRollResult]()
    
    //Rolling animation
    @State private var isRolling = false  // Animation state
    @State private var rollTimer: Timer?  // Timer for the rolling animation
    @State private var displayedResults = [Int]() // Use Int for displaying during animation

    // Haptic feedback generator
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
    
    var body: some View {
        NavigationStack {
            VStack {
                if !displayedResults.isEmpty {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 65))]) {
                        ForEach(Array(displayedResults.enumerated()), id: \.offset) { index, roll in
                            ZStack {
                                Color.green
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.white)
                                
                                VStack {
                                    Text("\(roll)")
                                        .font(.title3)
                                        .foregroundStyle(.black)
                                }
                                .padding(20)
                                .multilineTextAlignment(.center)
                            }
                            .frame(width: 65, height: 65)
                            .shadow(radius: 5)
                        }
                    }
                    .background(.green)
                    .frame(height: 200)
                    .padding(.horizontal)
                } else {
                    ContentUnavailableView("Please select your dice and roll!", systemImage: "dice")
                        .background(.green)
                }
                
                Form {
                    Section("Dice Settings") {
                        Stepper("Number of Sides: \(numberOfSides)", value: $numberOfSides, in: 4...20, step: 2)
                            .onChange(of: numberOfSides) {
                                resetResults()
                            } // Reset when number of sides changes
                        Stepper("Number of Dice: \(numberOfDice)", value: $numberOfDice, in: 1...10, step: 1)
                            .onChange(of: numberOfDice) {
                                resetResults()
                            } // Reset when number of sides changes
                    }
                    .listRowBackground(Color(.sRGB, red: 0.36, green: 0.54, blue: 0.66))
                    .shadow(radius: 10)
                }
                .scrollContentBackground(.hidden)
                .frame(height: 150)
                
                HStack {
                    Text("Total Amount: \(totalAmount)")
                        .padding(.trailing)
                    
                    Button("Roll the dice!") {
                        startRollingAnimation()
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                }
                
                ScrollView {
                    Section {
                        ForEach(savedResults) { result in
                            Text("Rolled Total: \(result.value)") // on \(result.date, formatter: dateFormatter)")
                        }
                    } header: {
                        Text("History")
                            .padding()
                    }
                    .headerProminence(.increased)
                }
                .navigationTitle("DiceRolla")
                .toolbar {
                    Button("Trash", systemImage: "trash") {
                        try? modelContext.delete(model: PersistentDiceRollResult.self)
                    }
                }
            }
            .background(.green)
            .onDisappear {
                rollTimer?.invalidate() // Stop the timer when the view disappears
            }
        }
    }
    
    func rollDice() {
        resetResults()
        
        // Ensure that results array matches the current number of dice
        diceRollResults = (0..<numberOfDice).map { _ in
            TemporaryDiceRollResult(value: Int.random(in: 1...numberOfSides))
        }
        // Calculate the total amount
        totalAmount = diceRollResults.reduce(0) { $0 + $1.value }
        displayedResults = diceRollResults.map { $0.value }
        saveTotalAmount()
    }
    
    // Function to reset the results when settings change
    func resetResults() {
        diceRollResults.removeAll()
        displayedResults.removeAll()
        totalAmount = 0
    }
    
    // Function to save the temporary results into the Container
    func saveTotalAmount() {
        let newResult = PersistentDiceRollResult(value: totalAmount, date: .now)
        modelContext.insert(newResult)
        try? modelContext.save()
    }
    
    // Function to start the rolling animation
    func startRollingAnimation() {
        isRolling = true
        displayedResults = Array(repeating: 1, count: numberOfDice) // Start with initial numbers
        var interval = 0.05  // Initial speed for the animation
        
        rollTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            // Update displayed results with random numbers
            displayedResults = (0..<numberOfDice).map { _ in
                Int.random(in: 1...numberOfSides)
            }
            
            // Trigger haptic feedback during the animation
            feedbackGenerator.impactOccurred()
            
            // Gradually slow down the animation by increasing the interval
            interval *= 1.15
            
            // When interval exceeds threshold, stop animation and show the final roll
            if interval >= 1.0 {
                timer.invalidate()  // Stop the timer
                isRolling = false
                rollDice()  // Show the final roll results
            }
        }
    }
}

// Define a struct for dice roll results
struct TemporaryDiceRollResult: Identifiable, Hashable {
    let id = UUID()
    let value: Int
}

// Formatter for displaying dates
private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()

#Preview {
    ContentView()
}
