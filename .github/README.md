<div id="top"></div>

[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
        <li><a href="#distribution">Distribution</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>

## About The Project
[![Product Name Screen Shot][product-screenshot]](https://example.com)

This app aggregates blog posting by SwiftLee (Antoine van der Lee), who has a blog on iOS software development. 

Please note that this app is only **a SwiftLee aggregator and not an app developed by SwiftLee**. Like any RSS aggregator, the author of the aggregator has no influence on SwiftLee’s blog posts. And SwiftLee has no responsibility for the aggregator. In case you are wondering, both parties did align ;-)

The aggregator asynchronously fetches data from an existing SwiftLee RSS feed. The RSS data is converted to JSON on the fly via an online RSS-to-JSON convertor. And the JSON is then decoded and rendered within the app. Clicking on a item in the aggregator opens the associated SwiftLee post in a browser tab.

<p align="right">(<a href="#top">back to top</a>)</p>

### Built With
* [Swift](https://www.swift.org)
* [SwiftUI](https://developer.apple.com/xcode/swiftui/)
* [RSS to JSON convertor](https://rss2json.com/)

<p align="right">(<a href="#top">back to top</a>)</p>

### Distribution
The app will only be available via GitHub. It isn’t and won’t be distributed via the Apple App Store to prevent confusion. And, frankly, the app doesn’t provide add enough functionality anyway to the existing SwiftLee website: the app is partly intended to try out some techniques (like async/await and decoding a complete JSON feed).

<p align="right">(<a href="#top">back to top</a>)</p>

## Getting Started
To get a local copy up and running follow these example steps. The installation procedure uses GitHub’s `Open with Xcode` feature. Those who prefer a command line route typically manage perfectly fine on their own.

<p align="right">(<a href="#top">back to top</a>)</p>

### Installation
1. Get a free API key at [rss2json.com](https://rss2json.com/docs)). This involves signing up for a free account with rss2json. Their free plan should be enough to view a single feed as often as you like. Save the API key code.
It allows you to generate a fair amount of traffic to rss2json.com without worrying about the traffic of others.
2. Clone the repository to your development environment: `Code` ,  `Code` ,  `Open with Xcode`, `Allow` GitHub to launch Xcode, select a suitable directory location, and press `Clone`.
3. Enter your personal API key in the file `Utilities`/`ApiKey.swift`
Don’t forget to uncomment the line. By default it reads:
```
// insert your rss2json.com API key and uncomment
// let apiKey = "thisisthespotwhereyouinsertyourownapikey" 
```
The line is commented out because I have a second file containing my own key. That second file doesn't get mirrored on GitHub.
4. You can now compile to install it on a real device (it should work for half a year) or run the code on one of XCode's simulators in the usual way.

<p align="right">(<a href="#top">back to top</a>)</p>

## Usage
There is little to say about usage. Just launch the app. If you click on an post in the scrollable List, it will launch the associated post in a browser tab. The current app does not store any data on your device, so you will need to be online (else you currently see an empty List). 

<p align="right">(<a href="#top">back to top</a>)</p>

## Roadmap
- [ ] Complete the readme
- [ ] Automatically fetch older posts via extra fetch requests (at 10 posts per request)
	- [ ] Add a search bar to filter the list (needed if there are hundreds of posts)

See the [open issues](https://github.com/vdhamer/SwiftLeeAggregator/issues) for a full list of proposed features (and known issues).

<p align="right">(<a href="#top">back to top</a>)</p>

## Contributing
Any contributions you make are **greatly appreciated**. If you have a suggestion that would make this better, please fork the repo and create a pull request.  The command line version (but the Xcode IDE has equivalent commands under `Source Control`):

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

You can alternatively submit a new issue with a tag like ”enhancement" or “bug” without having to provide a solution yourself. 
Don't forget to give the project a star in GitHub!

<p align="right">(<a href="#top">back to top</a>)</p>

## License
Distributed under the MIT License. See `LICENSE.txt` for more information.

## Contact
Peter van den Hamer - github@vdhamer.com

Project Link: [https://github.com/vdhamer/SwiftLeeAggregator](https://github.com/vdhamer/SwiftLeeAggregator)

<p align="right">(<a href="#top">back to top</a>)</p>

## Acknowledgments

* [A weekly Swift Blog on Xcode and iOS Development - SwiftLee](https://www.avanderlee.com)
* ["JSON Parsing in Swift explained with code examples" - SwiftLee](https://www.avanderlee.com/swift/json-parsing-decoding/)
* [RSS to JSON Converter online - rss2json.com](https://rss2json.com/#rss_url=https%3A%2F%2Fwww.avanderlee.com%2Ffeed)

<p align="right">(<a href="#top">back to top</a>)</p>

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/vdhamer/SwiftLeeAggregator.svg?style=for-the-badge
[contributors-url]: https://github.com/vdhamer/SwiftLeeAggregator/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/vdhamer/SwiftLeeAggregator.svg?style=for-the-badge
[forks-url]: https://github.com/vdhamer/SwiftLeeAggregator/network/members
[stars-shield]: https://img.shields.io/github/stars/vdhamer/SwiftLeeAggregator.svg?style=for-the-badge
[stars-url]: https://github.com/vdhamer/SwiftLeeAggregator/stargazers
[issues-shield]: https://img.shields.io/github/issues/vdhamer/SwiftLeeAggregator.svg?style=for-the-badge
[issues-url]: https://github.com/vdhamer/SwiftLeeAggregator/issues
[license-shield]: https://img.shields.io/github/license/vdhamer/SwiftLeeAggregator.svg?style=for-the-badge
[license-url]: https://github.com/vdhamer/SwiftLeeAggregator/blob/master/LICENSE.txt
[product-screenshot]: images/screenshot.png
