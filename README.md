# Permission Gateway

Prompts users with a gateway prior to displaying a system permission prompt.

### What problem is this solving?

The problem with permissions on iOS is that there are many ways your app which may be used and
requesting these permissions all at once results in a blitzkrieg of system prompts without
any context of how the app will use each permission. Users do not typically grant these
permissions without understanding why they are needed. According to the article linked below
it is as low as 40%.

Why is this a problem? When 60% of your users are unable to use critical features because they
deny permissions which enable those features they are very likely to post **negative reviews**
and **delete your app**. It results in a low star rating which will prevent strong *user growth*.
Helping the users understand why your app needs to request permissions and also giving them a 
path forward if they do deny a permission by sending them to the Settings app in the context
of your app will prevent dead ends.

With a permission gateway your app can prompt the user for a required permission in the
context of the action they just initiated. If they just tapped the "Upload a photo" button and
the gateway comes up to explain that the app needs permission to access their photo album
the user understands it in context. They can cancel without any penalty or even trigger the
system prompt and deny the permission if they choose. Later if they want to use that feature
the gateway will give them the option to open Settings to allow that permission.

For a more detailed explanation of the problem and suggestions for an improved user
experience read the article below.

 * [The Right Way To Ask Users For iOS Permissions](http://techcrunch.com/2014/04/04/the-right-way-to-ask-users-for-ios-permissions/) (TechCrunch) 

### User Settings

As Natasha The Robot points out on her blog it is possible to send the user to their settings
for the app with simple technique which allows for deep linking into Settings which makes it
much easier to help a user get into the settings for the app which cannot be changed in the
app, such as denied permissions.

 * [iOS: Taking the user to settings](http://natashatherobot.com/ios-taking-the-user-to-settings/)

### Possible Bug

Currently denied permissions will result in sending users to the Settings app to change the
required permission. When they return to the app which is still active the status is not
changing. Somehow the system needs to be refreshed so the status changes.

### Requires iOS 8

Due to various updates to the permissions model this library currently requires iOS 8 and
above which is now the common baseline for many apps due to the high install rate of iOS 8
and 9. You can look at earlier versions of this library which used the older system APIs if
you do need to support iOS 7. At this time there are no plans to support iOS versions before
iOS 8.

### License

MIT

---

Brennan Stehling  
http://twitter.com/brennanSV
