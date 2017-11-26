# DopeSettings
Spice up the settings page

Changes cell titles in settings app's main view

* **How it works**

Every cell in the settings app has a specifier. The specifier has an identifier and name. The name property is used as cell title. That's what the tweak alters
When the settings app is opened, the tweak grabs all identifiers and names from specifiers.
Some default values come with the tweak. System values are replaced with those
The tweak saves the IDs and names to a preference file
Edit the preference file and replace the system value to make the tweak show the string you want
Preference is given to user's strings.

* **How to put custom values**

Edit `/private/var/mobile/Library/Preferences/xyz.xninja.dopesettings.plist`

Example would key-value pair looks like
```
<key>net.whatsapp.WhatsApp</key>
<string>WhatsApp</string>
```
Change the string to anything you want

```
<key>net.whatsapp.WhatsApp</key>
<string>Shitty App</string>
```
Leave the key intact. It's used to identify the specifier

* **Reset a value**

Just make the string empty
```
<key>net.whatsapp.WhatsApp</key>
<string></string>
```
