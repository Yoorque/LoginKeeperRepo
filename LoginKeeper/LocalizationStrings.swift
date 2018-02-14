//
//  LocalizationStrings.swift
//  LoginKeeper
//
//  Created by Dusan Juranovic on 12/19/17.
//  Copyright © 2017 Dusan Juranovic. All rights reserved.
//

import Foundation

//MARK: - App Version & build
let versionLocalized = NSLocalizedString("Version", comment: "")
let buildLocalized = NSLocalizedString("build", comment: "")

//MARK: - Connection Check
let connectionCheckLocalized = NSLocalizedString("Internet connection required. Please check your internet connection", comment: "coonection check")
//MARK: - Premium Purchase
let removeAdsLocalized = NSLocalizedString("Remove ads", comment: "remove ads")
let removedAdsLocalized = NSLocalizedString("No more ads for you. \nCongratulations!", comment: "removed ads")
let alreadyPurchasedLocalized = NSLocalizedString("You have already purchased this functionality!", comment: "already purchased premium")
let successfullyRestoredLocalized = NSLocalizedString("You have successfully restored your purchase!", comment: "restored")
let successfullyPurchasedLocalized = NSLocalizedString("You have successfully purchased Premium version!", comment: "purchased Premium")
let basicVersionLocalized = NSLocalizedString("Basic version", comment: "basic version")
let premiumVersionLocalized = NSLocalizedString("Premium version", comment: "premium version")
let premiumVersionLockedLocalized = NSLocalizedString("Premium version LOCKED!", comment: "premium locked")
let premiumVersionPurchasedLocalized = NSLocalizedString("Premium version PURCHASED!", comment: "purchased")
let unlockPremiumTextLocalized = NSLocalizedString("Purchase Premium and remove ads", comment: "purchase premium text")
let cannotMakePurchaseLocalized = NSLocalizedString("You are not authorized to make a purchase", comment: "no purchase allowed")

//MARK: - About
let aboutLocalized = NSLocalizedString("About LoginKeeper", comment: "about title")
let aboutTextLocalized = NSLocalizedString("LoginKeeper® was developed solely using Apple Libraries and available resources provided by Apple and free open source resources. I, Dusan Juranovic, as a developer of LoginKeeper®, claim all distribution rights of LoginKeeper® as well as all copyrights©. LoginKeeper® is NOT recommended for storing valuable information such as , credit card details, bank details and all other information where loss of such information would bare great impact to individuals or companies alike and therefore LoginKeeper®  and I, Dusan Juranovic (developer), will not be held responsible for loss of any such information or assets. LoginKeeper® is intended only for purpose of not having to remember all of your login details or writing them down on pieces of paper. It is users judgment call to decide which information they enter into the app. If you have any issues or suggestions, please write an email to below provided email address. Thanks.", comment: "long about text")

//MARK: - Account
let accountTextLocalized = NSLocalizedString("Account", comment: "")
let entryNameTextLocalized = NSLocalizedString("Entry name", comment: "")
let usernameTextLocalized = NSLocalizedString("Username", comment: "")
let passwordTextLocalized = NSLocalizedString("Password", comment: "")
let commentTextLocalized = NSLocalizedString("Comment", comment: "")


//MARK - Tutorial
let closeLocalized = NSLocalizedString("Close", comment: "")
let skipLocalized = NSLocalizedString("Skip", comment: "")
let notAuthorisedLocalized = NSLocalizedString("You are not authorised to use this feature.", comment: "")

//MARK: - Save and Fetch Core Data Alerts
let unableToSaveMessageLocalized = NSLocalizedString("Oops! Unable to save changes at this time, please try again!", comment: "message")
let unableToFetchMessageLocalized = NSLocalizedString("Oops! Unable to fetch data at this time, please try again!", comment: "no fetch")

//MARK: - General Alerts
let okLocalized = NSLocalizedString("OK", comment: "")
let errorLocalized = NSLocalizedString("Error!", comment: "")
let leavingLocalized = NSLocalizedString("Leaving LoginKeeper", comment: "leaving message")
let leavingMessageLocalized = NSLocalizedString("You will be redirected to", comment: "first part")
let leavingMessageLocalized2 = NSLocalizedString("Are you sure?", comment: "second part")
let sureAnswerLocalized = NSLocalizedString("I'm sure", comment: "sure")
let cancelAnswerLocalized = NSLocalizedString("Cancel", comment: "cancel")
let inProgressLocalized = NSLocalizedString("In progress...", comment: "progress")
let workingLocalized = NSLocalizedString("We're working on this one!", comment: "working")
let noEntryLocalized = NSLocalizedString("No Entry name!", comment: "no entry name")
let noEntryMessageLocalized = NSLocalizedString("Entry name is required.", comment: "name required")
let noAccountLocalized = NSLocalizedString("No Account name!", comment: "")
let noAccountMessageLocalized = NSLocalizedString("Account name is required.", comment: "name required")
let emptyPasswordLocalized = NSLocalizedString("Empty password", comment: "empty password")
let emptyPasswordMessageLocalized = NSLocalizedString("Please enter your password.", comment: "enter pass")
let passNotMatchLocalized = NSLocalizedString("Passwords do not match!", comment: "no pass match")
let passNotMatchMessageLocalized = NSLocalizedString("Please enter your password again.", comment: "no pass msg")
let enterPasscodeAnswerLocalized = NSLocalizedString("Use Password", comment: "fallback title")
let setPasswordLocalized = NSLocalizedString("Password", comment: "set password")
let setPasswordMessageLocalized = NSLocalizedString("Set your backup password for LoginKeeper", comment: "set pass msg")
let passwordIsRequiredLocalized = NSLocalizedString("Password is required!", comment: "req pass")
let passwordIsRequiredMessageLocalized = NSLocalizedString("Please set your password to continue.", comment: "")
let enterPasswordLocalized = NSLocalizedString("Enter password", comment: "enter pass")
let identifyLocalized = NSLocalizedString("Identify yourself", comment: "id")
let noMailFuncLocalized = NSLocalizedString("You cannot send emails. Check your email settings", comment: "mail")
let chooseAuthMethodLocalized = NSLocalizedString("Choose your authentication method", comment: "choose auth method")
let touchIDLocalized = NSLocalizedString("Touch ID", comment: "touch ID")
let passwordLocalized = NSLocalizedString("Password", comment: "pass")

//MARK: - TableView Swipe
let addEntryLocalized = NSLocalizedString("Add Entry", comment: "")
let deleteEntryLocalized = NSLocalizedString("Delete Entry", comment: "delete")
let deleteAccountLocalized = NSLocalizedString("Delete Acc", comment: "")

//MARK: - Navigation Bar
let doneLocalized = NSLocalizedString("Done", comment: "")
let addNewEntryLocalized = NSLocalizedString("New Entry for", comment: "add new entry")
let detailsLocalized = NSLocalizedString("details", comment: "")
let unlockLocalized = NSLocalizedString("Unlock", comment: "")
let lockLocalized = NSLocalizedString("Lock", comment: "")
let entriesOfLocalized = NSLocalizedString("Entries of", comment: "")

//MARK: - SearchBar
let searchBarPlaceholderLocalized = NSLocalizedString("Search", comment: "search bar")

//MARK: - UserNotifications
let heyThereLocalized = NSLocalizedString("Hey there", comment: "")
let localNotificationLocalized1 = NSLocalizedString("There must be some password you forgot. Come back.", comment: "1")
let localNotificationLocalized2 = NSLocalizedString("We miss you dearly. Show us some love.", comment: "2")
let localNotificationLocalized3 = NSLocalizedString("You got it all figured out? Are you sure?", comment: "3")
let localNotificationLocalized4 = NSLocalizedString("You don't really need to remember everything, you know?", comment: "4")
let localNotificationLocalized5 = NSLocalizedString("Put your mind at ease, store your logins here.", comment: "5")
let localNotificationLocalized6 = NSLocalizedString("Haven't seen you in a while. How have you been lately?", comment: "6")
let localNotificationLocalized7 = NSLocalizedString("And there goes another week without you. You have been missed.", comment: "7")
let localizedNotificationStrings = [localNotificationLocalized1,localNotificationLocalized2,localNotificationLocalized3,localNotificationLocalized4,localNotificationLocalized5,localNotificationLocalized6,localNotificationLocalized7]

//MARK: - Mail

let subjectLocalized = NSLocalizedString("Feedback from", comment: "subject")
let deviceLocalized = NSLocalizedString("Device:", comment: "device")
let appVersionLocalized = NSLocalizedString("App Version:", comment: "app version")
let enterFeedbackLocalized = NSLocalizedString("Please enter your feedback below this line \n--------------------------------------------------", comment: "feedback")

