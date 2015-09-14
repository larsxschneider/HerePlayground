//
//  LSItineraryVC.m
//  HerePlayground
//
//  Created by Lars Schneider on 14/09/15.
//  Copyright (c) 2015 lars. All rights reserved.
//

#import "LSItineraryVC.h"
#import <AFNetworking.h>
#import "LSSearchResultsVC.h"
#import "LSHereAPI.h"


@interface LSItineraryVC () <UISearchResultsUpdating, UISearchControllerDelegate>

@property (nonatomic, strong) NSMutableArray *itinerary;
@property (nonatomic, strong) UISearchController *searchController;

@end


@implementation LSItineraryVC


- (void)viewDidLoad {
    [super viewDidLoad];

    self.itinerary = [NSMutableArray array];

    UINavigationController *searchResultsController = [[self storyboard]
        instantiateViewControllerWithIdentifier:@"TableSearchResultsNavigationController"];

    LSSearchResultsVC* searchResultsVC = (LSSearchResultsVC *)searchResultsController.topViewController;
    searchResultsVC.selectResult = ^(NSDictionary *result) {
        self.searchController.searchBar.text = @"";
        [self.itinerary addObject:result];
        [self.tableView reloadData];
        [self postItineraryUpdateNotification];
    };

    self.searchController = [[UISearchController alloc] initWithSearchResultsController:searchResultsController];
    self.searchController.searchResultsUpdater = self;
    [self.searchController.searchBar sizeToFit];

    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.tableView.editing = YES;
    self.title = @"Itinerary";
}


- (void)postItineraryUpdateNotification {
    NSDictionary *info = @{@"itinerary": [self.itinerary copy]};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ItineraryChange"
                                                        object:nil userInfo:info];
}


#pragma mark - UISearchResultsUpdating


- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchString = searchController.searchBar.text;
    if (searchString.length > 0) {
        [LSHereAPI searchWithQuery:searchString
                      success:^(NSArray *results) {
                          UINavigationController* nc = (UINavigationController *)searchController.searchResultsController;
                          LSSearchResultsVC* searchResultsVC = (LSSearchResultsVC *)nc.topViewController;
                          searchResultsVC.results = results;
                          [searchResultsVC.tableView reloadData];
                      }
                      failure:^() {
                          [searchController.searchBar resignFirstResponder];
                          [[[UIAlertView alloc] initWithTitle:@"Error"
                                                      message:@"Search request failed."
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil] show];
                      }];
    }
}


#pragma mark - UITableViewDelegate


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.itinerary.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ItineraryVCCell";
    UITableViewCell *cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    cell.textLabel.text = self.itinerary[indexPath.row][@"title"];
    return cell;
}


-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSDictionary* item = [self.itinerary objectAtIndex:sourceIndexPath.row];
    [self.itinerary removeObjectAtIndex:sourceIndexPath.row];
    [self.itinerary insertObject:item atIndex:destinationIndexPath.row];
    [self postItineraryUpdateNotification];
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.itinerary removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self postItineraryUpdateNotification];
}


@end
