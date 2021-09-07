//
//  ContentView.swift
//  WordScramble
//
//  Created by Andres on 2021-06-22.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State private var score = 0
    
    let colors: [Color] = [.red, .green, .blue]
    
    var body: some View {
        NavigationView {
            ZStack {
                RadialGradient(gradient: Gradient(colors: [Color.black, Color.white, Color.gray, Color.white, Color.gray, Color.white, Color.black]), center: .center, startRadius: 5, endRadius: 500).ignoresSafeArea()
                VStack {
                    TextField("Enter your word", text: $newWord, onCommit: addNewWord)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .autocapitalization(.none)
                    
                    Text("Score: \(score)")
                        .bold()
                        .coordinateSpace(name: "ListFrame")
                   
                    List(usedWords, id: \.self) { word in
                        GeometryReader { geometry in
                            HStack {
                                Image(systemName: "\(word.count).circle")
                                    .foregroundColor(self.colors.randomElement())
                                Text(word)
                                    .font(.title2)
                            }
                            .frame(width: geometry.size.width)
                            .background(Color.white)
                            .padding(.bottom)
                            .rotation3DEffect(.degrees(-Double(geometry.frame(in: .global).minY - geometry.size.height) / 25), axis: (x: 0, y: 1, z: 0))
                            .accessibilityElement(children: .ignore)
                            .accessibility(label: Text("\(word), \(word.count) letters"))
                        }
                        .frame(height: 30)
                    }
                    
                }
            }
            .navigationBarTitle(rootWord)
            .navigationBarItems(trailing: Button(action: startGame) {
                Text("Restart")
                    .foregroundColor(.black)
                    .padding()
            })
            .onAppear(perform: startGame)
            
            .alert(isPresented: $showingError) {
                Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
            
        }
    }
    
    func addNewWord() {
        // lowercase and trim the word
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        //exit if string empty
        guard answer.count > 0 else {
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not possible", message: "That is not even a word")
            return
        }
        
        usedWords.insert(answer, at: 0)
        score += answer.count
        newWord = ""
    }
    
    func startGame() {
        // Find URL for txt in app bundle
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            //Load txt into string
            if let startWords = try? String(contentsOf: startWordsURL) {
                //Split string into array by line breaks
                let allWords = startWords.components(separatedBy: "\n")
                
                //Pick one random word or use "silkworm" as default
                rootWord = allWords.randomElement() ?? "silkworm"
                
                //exit if everything worked
                return
            }
        }
        
        fatalError("Could not load start.txt from bundle")
    }
    
    //checks word wasnt used already
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    //checks word is contained within root
    func isPossible(word:String) -> Bool {
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
    
    //check word exist in dictionary
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        //check answer > 3 letters and not same as rootword
        if word.count > 2 && word != rootWord {
            return misspelledRange.location == NSNotFound
        } else {
            return false
        }
    }
    
    //shows errors
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
