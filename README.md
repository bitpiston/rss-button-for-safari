# RSS Button for Safari
A native app extension written in Swift for Safari 12+ adding feed discovery via toolbar button. 

Inspired by Syndicate by Reda Lemeden:  
https://github.com/kaishin/syndicate/

Motiviation thanks to Apple depreciating Safari legacy extensions in Safari 12:  
https://developer.apple.com/documentation/safariextensions


## Installation

RSS Button for Safari can be purchased from the Mac App Store:  

<a href="https://itunes.apple.com/us/app/rss-button-for-safari/id1437501942?ls=1&mt=12"><img src="https://rss-extension.bitpiston.com/img/appstore-130x38@2x.png" width="130" height="38"></a>

Why isn't it free? To cover the cost of the Apple Developer Program fee required to sign and distribute the extension.

Alternatively you can checkout the source and build the application and extension yourself allowing unsigned extensions from the develop menu in Safari.

To install this extension after purchasing on the App Store or compiling from source:

1) Open RSS Button for Safari from Applications.

3) Choose your preferred news reader:

![Choose news reader](https://rss-extension.bitpiston.com/screens/choose-default-reader@2x.webp)

4) Enable the extension from Safari Preferences under the extensions tab:

![Enable extension in Safari](https://rss-extension.bitpiston.com/screens/enable-extension-from-safari@2x.webp)

6) If the toolbar button does not appear automatically in Safari go to View > Customize Toolbar and drag the RSS Button to your toolbar. 


## Requirements

Requires macOS 10.12 or newer and Safari 12 or newer.

RSS Button for Safari requires either a desktop news reader supporting RSS, Atom or JSON feeds or an account with an online news reader. If your preferred application or online news reader isn't one the below services feel free to contact me or open an issue on GitHub. 


### Compatible news reader applications

Compatible news reader applications include:
- Cappuccino 
- Feedy (not to be confused with Feedly)
- Leaf
- Newsflow
- News Explorer
- News Menu
- NetNewsWire
- ReadKit
- Reeder 4 or 5
- Stripes

News reader applications that are not compatible or have known issues opening feed URLs automatically:
- Feedly
- Pulp
- Mozilla Thunderbird
- NewsBar
- Reeder 3 or older
- RSS Reader
- An Otter RSS Reader


### Supported news reader services

- Feedbin
- Feedly
- FeedHQ
- Feed Wrangler
- Inoreader
- NewsBlur
- The Old Reader
- BazQuz Reader

Custom URLs are also supported for self-hosted web services.


## Usage

![Active toolbar button when a page has feeds](https://rss-extension.bitpiston.com/screens/page-has-feeds@2x.webp)

![Inactive toolbar button when a page does not have feeds](https://rss-extension.bitpiston.com/screens/no-feeds-available@2x.webp)

![List of available feeds for a page](https://rss-extension.bitpiston.com/screens/simply-view-feeds@2x.webp)

![Subscribing a feed](https://rss-extension.bitpiston.com/screens/subscribe-to-feed@2x.webp)


## Known Issues

- Some pages do not publish the alternate links for auto-discovery of their RSS feeds and the extension cannot pick up feeds without them. 
- When installing from the Mac App Store rarely the extension will fail to load in Safari. Quitting Safari and relaunching tends to resolve the issue.

## Privacy

RSS Button for Safari does not collect or retain any data from users. Absolutely no requests to external or third party services are made from the application or extension at any time.
