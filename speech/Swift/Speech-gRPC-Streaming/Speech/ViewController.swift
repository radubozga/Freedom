//
// Copyright 2016 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//import UIKit
import AVFoundation
import googleapis
import DynamicButton
import ROGoogleTranslate
import SwiftyJSON
import NVActivityIndicatorView

let SAMPLE_RATE = 16000
var x = 0;


//Screen sizes - needed for button animations
let screenSize = UIScreen.main.bounds
let screenWidth = screenSize.width
let screenHeight = screenSize.height
//will have to adjut button location according to screen size in an elif

extension String {
    func capitalizeFirst() -> String {
        let firstIndex = self.index(startIndex, offsetBy: 1)
        return self.substring(to: firstIndex).capitalized + self.substring(from: firstIndex).lowercased()
    }
}

class ViewController : UIViewController, AudioControllerDelegate {
  @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var ROTextView: UITextView!
    @IBOutlet weak var roLabel: UITextView!
    @IBOutlet weak var enLabel: UITextView!
    @IBOutlet weak var Animation: NVActivityIndicatorView!
    @IBOutlet weak var AnimationEN: NVActivityIndicatorView!
    @IBOutlet weak var BGButton: DynamicButton!
    @IBOutlet var Button: DynamicButton!
  
    var audioData: NSMutableData!

  override func viewDidLoad() {
    super.viewDidLoad()
    AudioController.sharedInstance.delegate = self
  }
    
    
    
    func updateLabels() -> Void {
        UIView.animate(withDuration: 0.3, animations: {
            self.roLabel.text = "RO"
            self.enLabel.text = "EN"
        }, completion: nil)
    }
    
    func startStreaming() { //animation and connection
        Button.style = .stop
        print("STARTING SESSION")
        BGButton.style = .stop
        print("BG Pressed - STARTING SESSION")
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
        } catch {
            
        }
        audioData = NSMutableData()
        _ = AudioController.sharedInstance.prepare(specifiedSampleRate: SAMPLE_RATE)
        SpeechRecognitionService.sharedInstance.sampleRate = SAMPLE_RATE
        _ = AudioController.sharedInstance.start()
        
    }
    
    func stopStreaming() { //animation and connection
        Button.style = .dot
        print("ENDING SESSION")
        BGButton.style = .dot
        print("BG Pressed - ENDING SESSION")
        
        UIView.animate(withDuration: 10, animations: {
            self.Button.layer.masksToBounds = true
            self.Button.layer.cornerRadius = 0
        }, completion: nil)
        _ = AudioController.sharedInstance.stop()
        SpeechRecognitionService.sharedInstance.stopStreaming()
    }
    
    func startStreamingFirstTime() //animation and connection
    {
        print("STARTING SESSION - FIRST TIME")
        Button.style = .stop
        BGButton.style = .stop
        
        UIView.animate(withDuration: 0.3, animations: {
            self.Button.frame.origin.y = screenHeight - 113
            self.BGButton.frame.origin.y = screenHeight - 125
            
        }, completion: nil)
        
        //show Labels
        updateLabels()
        
    }
    
    func txt(text: String) -> String { //gets transcript. Removes "" and uppercases first character
        var k = 0
        let textArray = text.components(separatedBy: " ")
        var transcript = "miau" //needs to be initialized
        //retrieve transcript
        for word in textArray {
            if word == "transcript:" && k == 0 {
                k = 1 //next words will be saved
            }
            else if k == 1 && (word != "confidence:" && word != "}") {
                k = 2
                transcript = word
            }
            else if k == 2 && (word != "confidence:" && word != "}") {
                transcript = transcript + " " + word
            }
            else if word == "confidence:" || word == "}" {
                //finished
                k = 3
            }
        }
        
        //remove " "
        transcript.remove(at: transcript.startIndex)
        if let i = transcript.characters.index(of: "\"") {
            transcript.remove(at: i)
        }
        
        //Uppercase first char
        transcript = transcript.capitalizeFirst()
        
        //return final form
        return transcript
        
    }
    
    @IBAction func recordAudio(_ sender: DynamicButton) {
        x = x + 1 //if x == 1 streaming starts. Sign (semafor) value
        print("PRESSED") //Console debugging
        
        if (x == 1) //Streaming Starts for the first time
        {
            //Start Loading Animation
            Animation.startAnimating()
            AnimationEN.startAnimating()
            
            //Open Connection for the First time. Lower the button. Show labels
            startStreamingFirstTime()

        }
        if (x % 2 == 1) //Streaming starts
        {
            //Clear BOTH TextViews
            ROTextView.text = ""
            textView.text = ""
           
            //Start Loading Animation
            Animation.startAnimating()
            AnimationEN.startAnimating()
            
            //Open Connection
            startStreaming()
        }
        else { //if x % 2 == 0 streaming stops
            //Stop Loading Animation
            Animation.stopAnimating()
            AnimationEN.stopAnimating()
            
            //Close Connection
            stopStreaming()

        }

    }
    
    
  @IBAction func stopAudio(_ sender: NSObject) {
    _ = AudioController.sharedInstance.stop()
    SpeechRecognitionService.sharedInstance.stopStreaming()
  }
  
    func processSampleData(_ data: Data) -> Void {
    audioData.append(data)

    // We recommend sending samples in 100ms chunks
    let chunkSize : Int /* bytes/chunk */ = Int(0.1 /* seconds/chunk */
      * Double(SAMPLE_RATE) /* samples/second */
      * 2 /* bytes/sample */);

    if (audioData.length > chunkSize) {
      SpeechRecognitionService.sharedInstance.streamAudioData(audioData,
                                                              completion:
        { [weak self] (response, error) in
            guard let strongSelf = self else {
                return
            }
            
            if let error = error {
                strongSelf.textView.text = self?.txt(text: error.localizedDescription)
            } else if let response = response {
                var finished = false
                print(response)
                for result in response.resultsArray! {
                    if let result = result as? StreamingRecognitionResult {
                        if result.isFinal {
                            finished = true
                        }
                    }
                }
                if finished { //ends connection. Updates button status
                    //Stop Loading Animation
                    self?.Animation.stopAnimating()
                    self?.AnimationEN.stopAnimating()
                    
                    //Stop Connection
                    strongSelf.stopAudio(strongSelf)
                    self?.stopStreaming()
                    x = x + 1

                    //JSON to String
                    let text = response.description
                    //Parses String and returns transcript
                    let transcript = self?.txt(text: text)
                    
                    strongSelf.textView.text = transcript //english
                    
                    //Translate text
                    var params = ROGoogleTranslateParams(source: "en",
                                                         target: "ro",
                                                         text:   transcript!)
                    
                    let translator = ROGoogleTranslate()
                    translator.apiKey = "AIzaSyDgmPYQ7_fj3asEB4V2xpNiXu5WtgCZtjk"
                    
                    translator.translate(params: params) { (result) in
                        DispatchQueue.main.async {
                            strongSelf.ROTextView.text = "\(result)"
                        }
                    }
                    
                }
            }
      })
      self.audioData = NSMutableData()
    }
  }
}
