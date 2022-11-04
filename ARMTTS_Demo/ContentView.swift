import SwiftUI

extension String {
  func trunc(length: Int, trailing: String = "") -> String {
    return (self.count > length) ? self.prefix(length) + trailing : self
  }
}

struct ContentView: View {
    @StateObject var tts = ARMTTS(token: "UPDATE_TOKEN_HERE")
    
    
    @State var text = "Ողջույն, իմ անունը Գոռ է։"
    let maxLength = 300
    let themeColor = Color(red: 0.26, green: 0.85, blue: 0.72)
    
    var body: some View {
        VStack {
            TextEditor(text: $text).onChange(of: text) { _ in
                if text.count > maxLength { text = text.trunc(length: maxLength) }
            }
            Button {
                tts.speak(string: text)
            } label: {
                Label("Speak", systemImage: "speaker.1")
                    .foregroundColor(themeColor)
            }
        }
        .padding()
    }
    
}
