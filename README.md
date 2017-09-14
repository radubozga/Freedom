# Freedom

Freedom is an iOS Swift App that helps the romanian deaf communicate with foreigners. We use Google's Speech and Translation APIs to translate from speech in english to text in romanian.

The app is still in development - I am still testing it to find bugs and other useful features to implement. 
We hope to add multi-language support soon. We are also looking for a way to add punctuation signs (,.?!:) and to detect and capitalize proper nouns. 

## Demo
![alt tag](https://media.giphy.com/media/3ov9jQG52ouPV1lH5m/giphy.gif)

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.


### Prerequisites

```
Mac Machine (XCode is available only for Mac)
xCode
Cacaoapods
Google Translation and Speech API keys
```

### Installing

To copy this repository to to your machine type in Terminal/Command Prompt:
```
git clone https://github.com/radubozga/freedom Freedom
```
This will clone the repository into your existing folder as Freedom.

Using the Terminal/Command Prompt to enter the **Speech-gRPC-Streaming** folder and install the Pods. Open the project by opening the *Speech.xcworkspace* file. 

Pod installation - type this in the Termainal/after entering the **Speech-gRPC-Streaming** folder:
```
pod install
```
To use the pods open the project by opening the *Speech.xcworkspace* file. For example, Mac users type:
```
open Speech.xcworkspace
```
**KNOWN BUG - IMPORTANT** - when running/building the app  for the first time Google's Translation Pod wrongly initializes a set of links in the project. xCode will highlight you the links. 
**FIX:** Delete the entire links EXCEPT the name of the final file.
**Example** If the link is *google/api/link/isbrokenbutcanbefixed.bjopch* delete the *google/api/link/* . Finally, your link should be *isbrokenbutcanbefixed.bjopch*

## Built With

* Cacaopods - dependency manager - https://cocoapods.org
* Google Speech API - Speech-to-Text - https://cloud.google.com/speech/
* Google Translation API - Tranlation from EN to RO - https://cloud.google.com/translate/
* Dynamic Button - Swift Button Library - https://github.com/yannickl/DynamicButton
* NVActivityIndicatorView - Swift Animations Library - https://github.com/ninjaprox/NVActivityIndicatorView

## Contributing

Please feel free to Contribute to Freedom.
If you like Freedom and have any idea on how to add any of the following features let me know :) 
* Multi-language support soon
* Detect where to add and add punctuation signs (,.?!:)
* Detect and capitalize proper nouns. 


## License

This project is licensed under the Apache 2.0 License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* <div>Ear Icon made by <a href="http://www.freepik.com" title="Freepik">Freepik</a> from <a href="https://www.flaticon.com/" title="Flaticon">www.flaticon.com</a> is licensed by <a href="http://creativecommons.org/licenses/by/3.0/" title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a></div>
* Freedom is built on top of Google's Speech example Swift app. Modifications - adding Translation API support, word parsing from original JSON returned by the API, changing the front-end, deleting Google's unused files
