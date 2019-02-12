//
//  WebViewViewData.swift
//  Connfa
//
//  Created by Marian Fedyk on 7/28/17.
//  Copyright (c) 2017 Lemberg Solution Ltd. All rights reserved.
//

import UIKit

struct WebViewData {
  var content: String
  var style: CssFileName
  
  var htmlDocument: String? {
    return HTMLManager.makeDocument(withContent: content, withStyle: style)
  }  
}
