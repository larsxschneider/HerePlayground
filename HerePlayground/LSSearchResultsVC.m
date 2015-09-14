//
//  LSSearchResultsVC.m
//  HerePlayground
//
//  Created by Lars Schneider on 14/09/15.
//  Copyright (c) 2015 lars. All rights reserved.
//

#import "LSSearchResultsVC.h"


@implementation LSSearchResultsVC


#pragma mark - UITableViewDelegate


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.results.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"SearchResultsVCCell";
    UITableViewCell *cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    cell.textLabel.text = self.results[indexPath.row][@"title"];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectResult) {
        self.selectResult(self.results[indexPath.row]);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
