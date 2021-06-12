# eKreative Lifebase Internship Test Assignment

### Targeted on iOS 14, SwiftUI

## Tasks

- Create a mobile app that uses FB and Google means of authorization
- Use Youtube APIs to present a list of uploads from eKreative channel with a
 possibility of playing a chosen video

## Setup

First of all, this project uses CocoaPods, install dependencies using `pod install`.

Open the project using the `*.xcworkspace` file

Here you will need a lot of keys and IDs. All of them are in the Info.plist

1. Facebook

You will need to get an app id from 
[FB apps](https://developers.facebook.com/apps/)

Paste it according to 
[this guide](https://developers.facebook.com/docs/facebook-login/ios/), step 4

Also, you will need to paste this id to the `CFBundleURLSchemes` array. 
Leave `fb` there, so the resulting value should be like
 `<string>fb0123456789</string>`

2. Google

From Google, you will need to get `CLIENT_ID`s and `API_Key`

 - Probably the easiest way to get `CLIENT_ID`s is to go 
 through the interactive process on step 2 
 from [here](https://developers.google.com/identity/sign-in/ios/start?ver=swift).
  You will get some credentials.plist file, just copy id and reversed id 
  into appropriate places in the Info.plist. 
  Don't forget the URL scheme one.

 - `API_KEY` can be generated 
 [here](https://console.cloud.google.com/apis/credentials), paste in 
 the `YOUTUBE_API_KEY` key


After that, you should be good to go.


## Interesting points

- Here videos are loaded lazily (the proper way), so you can even paste 
the [Roel Van de Paar](https://www.youtube.com/channel/UCPF-oYb2-xN5FbCXy0167Gg)
 link into the `YoutubeChannelURL` key in the Info.plist and smoothly 
 scroll through 500k videos.

- My ad-hoc web image loader (named `URLImage`) sadly doesn't want to work
 properly together with `LazyVStack`, even though when using regular VStack
  it works fine. Thus, I had to use the 3rd party `SDWebImage` library, 
  which works well in this case.
