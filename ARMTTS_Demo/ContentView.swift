import SwiftUI

extension String {
  func trunc(length: Int, trailing: String = "") -> String {
    return (self.count > length) ? self.prefix(length) + trailing : self
  }
}

struct ContentView: View {
    @StateObject var tts = ARMTTS()
    var voices = ["Gor"]
    @State private var selectedVoice = "Gor"
    
    @State var text = "Նոր Զելանդիա, 1950 թվական, մայրերը հանում են իրենց երեխաների մանկասայլակները հասարակական տրանսպորտից։"
    
    var body: some View {
        ZStack {
            VStack {
                Image("Logo")
                    .frame(height: 20)
                Text("TTS ENGINE FOR THE ARMENIAN LANGUAGE")
                    .frame(minHeight: 10)
                    .font(Font.custom("Genos-Regular", size: 8))
                    .foregroundColor(.white)
                    .padding(.top, 7)
                HStack {
                    Text("Voice")
                        .foregroundColor(.black)
                        .padding(.leading)
                    Spacer()
                    Picker("Please choose a color", selection: $selectedVoice) {
                        ForEach(voices, id: \.self) {
                            Text($0)
                        }
                    }
                }
                .frame(height: 40)
                .background(Color.white)
                .cornerRadius(14)
                .padding(.top, 10)
                ZStack {
                    VStack {
                        TextEditor(text: $text)
                            .onChange(of: text) { _ in
                                if text.count > 300 {
                                    text = text.trunc(length: 300)
                                }
                            }
                        Text("\(text.count) / 300")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .foregroundColor(text.count == 300 ? Color.red : Color.black)
                            .padding(.trailing, 4)
                            .padding(.bottom, 2)
                    }
                }
                .frame(maxHeight: 220, alignment: .top)
                .background(Color.white)
                .cornerRadius(11)
                .padding(.top)
                Button(action: {
                    tts.speak(string: text)
                }, label: {
                    HStack(spacing: 8) {
                        Text("PLAY")
                            .frame(width: 99, height: 32)
                            .font(Font.system(size: 15, weight: .heavy))
                            .foregroundColor(Color.black)
                            .background(Color.white)
                    }
                    .frame(width: 99, height: 32)
                    .cornerRadius(14)
                })
                .accentColor(Color.white)
                .shadow(color: Color(red: 0, green: 0, blue: 0, opacity: 0.15), radius: 4, x: 2, y: 4)
                .padding(.top, 20)
                Spacer()
            }
            .padding()
        }
        .background(Color(red: 0.263, green: 0.851, blue: 0.722).ignoresSafeArea(edges: .all))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
