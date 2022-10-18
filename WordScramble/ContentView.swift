//
//  ContentView.swift
//  WordScramble
//
//  Created by DJ on 9/8/22.
//

import SwiftUI
struct Blue: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.largeTitle)
            .shadow(color: .teal, radius: 5)
            .foregroundColor(.purple)
            .frame(maxWidth: 300)
            .padding(.vertical, 20)
            .background(.thickMaterial)
            .background(Color.orange)
            .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

extension View {
    func titleStyle() -> some View {
        modifier(Blue())
    }
}

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var wordScore = 0
    @State private var totalScore = 0
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var errorShowing = false
    @FocusState private var amountIsFocused: Bool
    
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    Form {
                         Section() {
                             TextField("Enter your word", text: $newWord)
                                 .keyboardType(.default)
                                 .focused($amountIsFocused)
                         } header: {
                             Text("Make a different word from the above word")
                         }
                        Section {
                            ForEach(usedWords, id: \.self) { word in
                                HStack {
                                    Image(systemName: "\(word.count).circle.fill")
                                    Text(word)
                                        .autocapitalization(.allCharacters)
                                }
                            }
                            Text("Your score for \(rootWord) is \(wordScore)")
                        }
                        
                        Section {
                            HStack {
                                Text("Your total score is \(totalScore)")
                                    .titleStyle()
                            }
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .toolbar {
                Button("Play again", action: startGame)
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        amountIsFocused = false
                    }
                }
            }
            .onSubmit { addNewWord() }
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $errorShowing) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
        func addNewWord() {
            let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            guard answer.count >= 3 && answer != rootWord else {
                wordError(title: "Word not valid", message: "Too short or the same as the given word!")
                return }
            
            guard isOriginal(word: answer) else {
                wordError(title: "Word used already", message: "Be more origial!")
                return
            }
            
            guard isPossible(word: answer) else {
                wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'")
                return
            }
            
            guard isReal(word: answer) else {
                wordError(title: "Word not recognized", message: "You can't just make them up, ya know!")
                return
            }
            
            withAnimation {
                usedWords.insert(answer, at: 0)
            }
            newWord = ""
            wordScore += answer.count
        }
        
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                totalScore += wordScore
                wordScore = 0
                usedWords = [String]()
                return
            }
        }
        fatalError("Could not load start.txt from bundle.")
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        errorShowing = true
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
