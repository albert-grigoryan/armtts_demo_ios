import Foundation
import AVFoundation

public class ARMTTS {
    var rate: Float = 1.0
    
    var API_URL = "https://armtts.online:5555/synthesize"
    
    private let fastSpeech2 = try! FastSpeech2(url: Bundle.main.url(forResource: "fastspeech2", withExtension: "tflite")!)
    
    private let mbMelGan = try! MBMelGan(url: Bundle.main.url(forResource: "mb_melgan", withExtension: "tflite")!)

    /// Mel spectrogram hop size
    public let hopSize = 256
    
    /// Vocoder sample rate
    let sampleRate = 22_000

    private let sampleBufferRenderSynchronizer = AVSampleBufferRenderSynchronizer()

    private let sampleBufferAudioRenderer = AVSampleBufferAudioRenderer()

    init() {
        sampleBufferRenderSynchronizer.addRenderer(sampleBufferAudioRenderer)
    }

    public func speak(string: String) {
        let input_ids = process(string)
        
        do {
            let melSpectrogram = try fastSpeech2.getMelSpectrogram(inputIds: input_ids, speedRatio: 2 - rate)
            
            let data = try mbMelGan.getAudio(input: melSpectrogram)
            print(data)
            
            let blockBuffer = try CMBlockBuffer(length: data.count)
            try data.withUnsafeBytes { try blockBuffer.replaceDataBytes(with: $0) }
            
            let audioStreamBasicDescription = AudioStreamBasicDescription(mSampleRate: Float64(sampleRate), mFormatID: kAudioFormatLinearPCM, mFormatFlags: kAudioFormatFlagIsFloat, mBytesPerPacket: 4, mFramesPerPacket: 1, mBytesPerFrame: 4, mChannelsPerFrame: 1, mBitsPerChannel: 32, mReserved: 0)
            
            let formatDescription = try CMFormatDescription(audioStreamBasicDescription: audioStreamBasicDescription)
            
            let delay: TimeInterval = 1
            
            let sampleBuffer = try CMSampleBuffer(dataBuffer: blockBuffer,
                                                  formatDescription: formatDescription,
                                                  numSamples: data.count / 4,
                                                  presentationTimeStamp: sampleBufferRenderSynchronizer.currentTime()
                                                    + CMTime(seconds: delay, preferredTimescale: CMTimeScale(sampleRate)),
                                                  packetDescriptions: [])
            
            sampleBufferAudioRenderer.enqueue(sampleBuffer)
            
            sampleBufferRenderSynchronizer.rate = 1
        }
        catch {
            print(error)
        }
    }
    
    func process(_ text: String) -> [Int32] {
        var sequence: [Int32] = []
        let semaphore = DispatchSemaphore (value: 0)

        let parameters = [
          [
            "key": "text",
            "value": text,
            "type": "text"
          ]] as [[String : Any]]

        let boundary = "Boundary-\(UUID().uuidString)"
        var body = ""
        for param in parameters {
          if param["disabled"] == nil {
            let paramName = param["key"]!
            body += "--\(boundary)\r\n"
            body += "Content-Disposition:form-data; name=\"\(paramName)\""
            if param["contentType"] != nil {
              body += "\r\nContent-Type: \(param["contentType"] as! String)"
            }
            let paramType = param["type"] as! String
            if paramType == "text" {
              let paramValue = param["value"] as! String
              body += "\r\n\r\n\(paramValue)\r\n"
            } else {
              let paramSrc = param["src"] as! String
              let fileData = try! NSData(contentsOfFile:paramSrc, options:[]) as Data
              let fileContent = String(data: fileData, encoding: .utf8)!
              body += "; filename=\"\(paramSrc)\"\r\n"
                + "Content-Type: \"content-type header\"\r\n\r\n\(fileContent)\r\n"
            }
          }
        }
        body += "--\(boundary)--\r\n";
        let postData = body.data(using: .utf8)

        var request = URLRequest(url: URL(string: API_URL)!,timeoutInterval: Double.infinity)
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        request.httpMethod = "POST"
        request.httpBody = postData
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
          guard let data = data else {
            print(String(describing: error))
            semaphore.signal()
            return
          }
          print(String(data: data, encoding: .utf8)!)
            
            let json = try! JSONSerialization.jsonObject(with:data, options :[]) as! [String:Any]
            sequence = json["ids"] as! [Int32]
            
          semaphore.signal()
        }

        task.resume()
        semaphore.wait()
        
        return sequence
    }
    
}

extension ARMTTS: ObservableObject {
    
}
