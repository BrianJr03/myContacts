# myContacts

A simple contacts app, built with Flutter.

![myContacts Homepage](https://github.com/BrianJr03/myContacts/blob/master/myContacts_homepage_tiny.jpg)
![Update Info Dialog](https://github.com/BrianJr03/myContacts/blob/master/updateInfoDialog_tiny.jpg)

## Features

- ### Create, Update, and Delete contacts.

- ### Search Functionality
  - A user can filter through their contacts via `name` or `number` with the help of a search bar.
  
- ### Scrollable Contacts List with Sections
  - Each section of contacts is labeled in `alphabetical order` by the first letter.
  - Example: The 'B' section has all contacts whose name begin with 'B'.
  
- ### Dynamic Header
  - The user's contact card is the first card to appear before the user's contact list.
  
    - This card contains a `photo`, `name` and `description` of the user. 
    - These values can be updated in the `Update Info Dialog`.
    
- ### Phone Calls / SMS / Email
  - After clicking on a contact card, the user can reach the contact either via direct `phone call`, `SMS` or `email`.
  - If there are no matching contacts after search, a user can Call or SMS the query if it's a phone number.
  - A `dial pad` can be toggled to make entering phone numbers easy.

- ### Customizable Theme
  - A user can chose the theme of their app with the help of a `color picker`.
  
- ### Clean Architecture
  - The source code for this project is cleanly written and follows best practices.

## How to Run
This application as-is has seen limited iOS testing and there may be bugs/issues present. Run at your own risk.
1. Install Flutter SDK and an emulator of your choice (or offload to a physical device).
2. In your code editor, attach a running emulator or a physical device to the project.
3. Find the root of the project in `lib/main.dart`. Run the main() method, which will run the application on your emulator or device. You can also use `flutter run` in a shell, with additional arguments to customize the configuration.

Instructions for how to install Flutter SDK can be found [here](https://docs.flutter.dev/get-started/install). Before running the Flutter application, run the following command in your terminal to download external packages: `flutter pub get`. If you run into trouble with your Flutter installation, try running `flutter doctor` to verify that your Flutter SDK is properly installed and configured with your environments.

If you have trouble running on an iOS device or emulator, ensure that you have the CocoaPods manager installed, which manages dependencies for Xcode projects. Instructions for how to install can be found [here](https://guides.cocoapods.org/using/getting-started.html). Once CocoaPods is installed, you can install the pods for this project by setting the directory to `ios` and running `pod install` (this process will run automatically when running the main method). Other CocoaPods commands can be used for troubleshooting, such as `pod outdated` and `pod update`, but only when the directory is set to `ios`. Ensure that your version of the app has been signed with an Apple account, which can be done through Xcode. A Developer account is not required to run the app, but an account must be used to sign the app.

## Issues
 - Limited iOS testing. There *may* be iOS config and other platform-specific issues.
 - After initially approving the permission to import contacts, the app will immediately close. 
   - Re-open the app and it'll work as intended.

*These issues are currently being worked on. If you find any other bugs or have suggestions, email me @* `thaballa79@gmail.com`
