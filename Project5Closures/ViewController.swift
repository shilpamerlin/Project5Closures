//
//  ViewController.swift
//  Project5Closures
//
//  Created by Shilpa Joy on 2021-03-12.
//

import UIKit

class ViewController: UITableViewController {
    
    var allwords = [String]()
    var usedWords = [String]()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(startGame))
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWords = try? String(contentsOf: startWordsURL) {
                allwords = startWords.components(separatedBy: "\n")
            }
        }
        if allwords.isEmpty {
            allwords = ["Silkworm"]
        }
        startGame()
    }
     @objc func startGame() {
        title = allwords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    @objc func resetGame(){
        title = allwords.randomElement()
        
    }

   
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word",for : indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    @objc func promptForAnswer(){
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField() //method just adds an editable text input field to the UIAlertController.
        
        /*ac.addAction(UIAlertAction(title: "Submit", style: .default, handler: submit))
        present(ac, animated: true)*/
      
       let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak ac] action in
            guard let answer = ac?.textFields?[0].text else { return } //read out the value that was inserted
            self?.submit(answer)
        }

        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    /*func submit(action: UIAlertAction) {
    }*/
    
    func submit(_ answer : String) {
        let lowerAnswer = answer.lowercased()
        
        if isPossible(word: lowerAnswer){
            if duplicateWord    (word: lowerAnswer){
                if isReal(word: lowerAnswer){
                    usedWords.insert(answer, at: 0) //index 0. This means "add it to the start of the array
                    
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic) //Adding one cell is also significantly easier than having to reload() everything, hence used this method instead of tableview.reloadData()
                    return
                } else {
                    showErrorMessage(errorTitle: "Word not recognised", errorMessage: "You can't just make them up, you know!")
                }
            } else {
                showErrorMessage(errorTitle: "Word used already", errorMessage: "Be more original!")
            }
        }else {
            guard let title = title?.lowercased() else { return }
            showErrorMessage(errorTitle: "Word not possible", errorMessage: "You can't spell that word from \(title)")
        }
       
    }
    
    func isPossible(word: String) -> Bool {
        guard var tempWord = title?.lowercased() else { return false }

        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                print(position)
                tempWord.remove(at: position)
            } else {
                return false
            }
        }

        return true
    }
    
    func duplicateWord(word: String) -> Bool {
        guard word != title  else { return false }
        var flag: Bool = true
        for item in usedWords {
            word.compare(item)
            flag = false
        }
        return flag
    }
    
    func isReal(word: String) -> Bool {
        
        guard word.count > 3 else { return false }
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        print("Misspelled \(misspelledRange), NSNotFOUND value \(NSNotFound)")
        return misspelledRange.location == NSNotFound
    }
    func showErrorMessage(errorTitle: String,errorMessage: String){
        
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}

