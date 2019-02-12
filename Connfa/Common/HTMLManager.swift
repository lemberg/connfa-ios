//
//  HTMLDocumentManager.swift
//  ConnfaCore
//
//  Created by Marian Fedyk on 9/6/17.
//

import Foundation

public enum CssFileName: String {
  case event = "event_detail_style"
  case `default` = "style"
}

public struct HTML{
  public static let fileName = "Declaration"
  public static let fileExtension = ".html"
  public struct PlaceHolders {
    public static let contentPlaceHolder = "@content"
    public static let cssURLPlaceHolder = "@filecss"
  }
}

public class HTMLManager {
  private static func htmlDeclarationString(resourse: String, fileExtension: String) -> String? {
    guard let url = Bundle.main.url(forResource: resourse, withExtension: fileExtension) else {
      return nil
    }
    let html = try? String(contentsOf: url, encoding: String.Encoding.utf8)
    return html
  }
  
  public static func makeDocument(forResourse: String? = HTML.fileName, withExtension: String? = HTML.fileExtension, withContent: String, withStyle: CssFileName) -> String? {
    guard let resourse = forResourse, let ext = withExtension else {
      return nil
    }
    guard let htmlString = HTMLManager.htmlDeclarationString(resourse: resourse, fileExtension: ext) else {
      return nil
    }
    let contentedHTML = htmlString.replacingOccurrences(of: HTML.PlaceHolders.contentPlaceHolder, with: withContent)
    let styledHTML = contentedHTML.replacingOccurrences(of: HTML.PlaceHolders.cssURLPlaceHolder, with: withStyle.rawValue + ".css")
    return styledHTML
  }
}
