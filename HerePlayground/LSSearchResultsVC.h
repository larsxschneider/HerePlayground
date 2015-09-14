//
//  LSSearchResultsVC.h
//  HerePlayground
//
//  Created by Lars Schneider on 14/09/15.
//  Copyright (c) 2015 lars. All rights reserved.
//
//  View controller for the places search results table view on the second tab.
//

#import <UIKit/UIKit.h>

typedef void(^SelectResultBlock)(NSDictionary *result);

@interface LSSearchResultsVC : UITableViewController

@property (nonatomic, strong) NSArray *results;
@property (nonatomic, copy) SelectResultBlock selectResult;

@end
