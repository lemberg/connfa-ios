//
//  Titles.swift
//  Connfa
//
//  Created by Marian Fedyk on 8/21/17.
//

import Foundation

struct Constants {
  struct Title {
    static let sponsors = "Sponsors"
    static let aboutDrupalCon = "About DrupalCon"
    static let aboutApp = "About app"
    static let floorPlan = "Floor plan"
    static let location = "Location"
    static let program = "Program"
    static let venue = "Venue"
    static let interested = "Interested"
    static let more = "More"
  }
  struct Links {
    static let dynamicDomain = "newconnfa.page.link"
  }
  struct Text {
    static let invitation = "Hey, it`a great opportunity to share my schedule of interested events with you. Code: "
    static let choosePinToShow = "Choose pin to show"
    static let cancel = "Cancel"
    static let shareYourPin = "Share my pin"
    static let addPin = "Add a pin"
    static let editPin = "Edit current pin"
    static let delete = "Delete"
    static let remove = "Remove current pin"
    static let deletedSuccessfully = "Deleted successfully!"
    static let noCurrentUser = "Anonymous auth failed. Try again later."
    static let invalidPin = "Invalid pin"
    static let noPin = "Something wrong with your pin"
    static let succeeded = "Succeeded!"
    static let authFailed = "Anonymous auth failed"
    static let firstTime = "It seems you are first time here. You are successfully authorized, and are able to store your own data."
    static let myInterested = "My Interested"
    static let noInternet = "Internet connection is not available at this moment. Please, try later."
  }
  struct StoryboardID {
    static let mainTabBarController = "MainTabBarController"
  }
  struct PList {
    static let fileResourse = "Configurations"
    static let fileExtension = "plist"
    struct Twitter {
      static let outerDictionaryKey = "Twitter"
      static let twitterAPIKey = "API Key"
      static let twitterApiSecret = "API Secret"
      static let twitterSearchQuery = "Search Query"
    }
    struct Colors {
      static let outerDictionaryKey = "Colors"
      static let tintColor = "Tint Color"
    }
    struct Date {
      static let outerDictionaryKey = "Date"
      static let timeZoneIdentifier = "Time Zone Identifier"
      static let startDate = "Start Date"
    }
    struct Title {
      static let outerDictionaryKey = "Title"
      static let calendarName = "Calendar name"
    }
  }
}
