import SwiftUI

struct ContentView: View {
    @StateObject var tts = ARMTTS()
    
    @State var text = "Նոր Զելանդիա, 1950 թվական, մայրերը հանում են իրենց երեխաների մանկասայլակները հասարակական տրանսպորտից։"
    
    var body: some View {
        VStack {
            TextEditor(text: $text)
            Button {
                tts.speak(string: text)
            } label: {
                Label("Speak", systemImage: "speaker.1")
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
