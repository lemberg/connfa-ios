//
//  The MIT License (MIT)
//  Copyright (c) 2014 Lemberg Solutions Limited
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//   The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#ifndef DrupalCon_UIConstants_h
#define DrupalCon_UIConstants_h

#ifdef HCE
#define NAV_BAR_COLOR [UIColor colorWithRed:0.0/255. green:83.0/255. blue: 163./255. alpha: 1.0] // blue
#else
#define NAV_BAR_COLOR [UIColor colorWithRed:0.0/255. green:126.0/255. blue: 200./255. alpha: 1.0] // blue
#endif

#define MENU_SELECTION_COLOR [UIColor colorWithRed:210./255. green:70./255. blue:42./255. alpha:1.0] // red
#define MENU_DESELECTED_ITEM_TITLE_COLOR [UIColor colorWithRed:98./255. green:98./255. blue:98./255. alpha:1.0] // gray

#define NAV_BAR_TITLE_ATTRIBUTES [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,[UIColor whiteColor],NSBackgroundColorAttributeName, [UIFont fontWithName:@"HelveticaNeue-Medium" size:17],NSFontAttributeName,nil]

#endif
