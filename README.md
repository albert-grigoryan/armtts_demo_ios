## ARMTTS - iOS demo
ARMTTS is a TTS (text-to-speech) engine for the Armenian language. Try it online: https://armtts.online.


### Build
Please follow the steps below to build the project.

1. Prepare the sources
```
git clone https://github.com/albert-grigoryan/armtts_demo_ios.git
cd armtts_demo_ios.git
pod install
```

2. Download and update the models: [fastspeech2.tflite](https://www.dropbox.com/s/614z0qaaim36rf8/fastspeech2.tflite), [mb_melgan.tflite](https://www.dropbox.com/s/i5w76jen4dggtdu/mb_melgan.tflite)


3. Update the **token** in *ContentView.swift*

```
@StateObject var tts = ARMTTS(token: "UPDATE_TOKEN_HERE")
```

4. Build
