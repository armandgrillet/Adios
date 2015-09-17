[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/ArmandGrillet/Adios?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

# Adios
<p align="center">
<img src="https://raw.githubusercontent.com/ArmandGrillet/Adios/without-cloudkit/Adios/Assets.xcassets/AppIcon.appiconset/Icon-60%403x.png">
</p>
Adios is the first ad blocker for iOS devices. It offers all the features of an ad blocker for desktop browsers:

- More than 20 ad lists available, each of them blocking all the ads of websites from a specific country. 
- Adios removes all the social media buttons and block all the malicious scripts attempting to your privacy. 
- If you need to see the ads on a specific website, use the whitelist to do so.

tl;dr Adios is offering you the next Web. You don't want to be tracked, you don't want to see silly ads. 
You deserve a fast and readable Web that is not killing your data quota. You deserve Adios.

## What should I do with it?

Adios is an open-source base for an ad-blocker. The code has been developed in one month so some parts are quite messy. I encourage you to fork this project and start your own content-blocker using the good parts of Adios (the parser for example).

## What is the difference between the two branches?
### Master
The branch `master` works with CloudKit so if you use it you need to configure a CloudKit database first. This database is really simple:
- One record type `Update`
- One field for this type called `Version` and make it a Int(64)
- One record of this type, the name doesn't matter

When a user configure Adios it'll create a new subscription to this record, if you update this record from the CloudKit Dashboard the app will download the updated lists using the lists urls given in `ListsManager.swift`

The branch master needs a JS back-end, the lists used by Adios have to be on a website so that the app don't need to parse them. If you want to see how does it look, the first version of Adios was storing the lists [here](https://gitlab.com/ArmandGrillet/lists/tree/master). To parse the lists (you'll need to do it, lists need to be updated frequently), use [this npm module](https://github.com/ArmandGrillet/Adios-Engine). If you want a demo, you can find one [here](http://armand.gr/Adios-Engine-Demo/).

### Without-cloudkit
The simplest app, the parsing is made directly in the app in `DownloadManager.swift` using `Parser.swift`. You do not need to set up a CloudKit database but the configuration of Adios will take a longer time. This application doesn't do background updates so it's not made for production.
