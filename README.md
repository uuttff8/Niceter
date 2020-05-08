# Niceter

![Alt text](Niceter/design/screenshots/readme/readme_scr.png  "")

Niceter is a unofficial client to [Gitter](https://gitter.im) for iOS

How to compile and generate .xcworkspace file

1. Clone repo and cd

	`git clone https://github.com/uuttff8/Niceter.git`
    
    `cd Niceter`
2. Run Pod Install
 
 	`pod install`
    
 Next step you should create Your own gitter app here: https://developer.gitter.im/apps
 
 3. Create file GitterSecrets-Dev.plist under Niceter/Resources/Secrets/
 4. Fill it with data: 

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>OAuthClientId</key>
	<string>*Your-OAuthClientId*</string>
	<key>OAuthClientSecret</key>
	<string>*Your-OAuthClientSecret*</string>
	<key>OAuthCallback</key>
	<string>*Your-OAuthCallback*</string>
</dict>
</plist>
```

5. Copy and Paste `OAuthClientId`, `OAuthClientSecret`, `OAuthCallback ` to file.


And you are done!

### Getting Help 
We use [Gitter](https://gitter.im/Niceter-all/community) for real-time debugging, community updates, and general talk about Texture. [Enter](https://gitter.im/Niceter-all/community) here or email uuttff8@gmail.com to get an invite.

### Contributing 
We welcome any contributions. See the CONTRIBUTING file for how to get involved.


### License 
The Niceter project is available for free use, as described by the LICENSE (MIT).

