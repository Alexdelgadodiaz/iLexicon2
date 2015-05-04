//
//  ADDDictionarySelectorViewController.m
//  vocabulario
//
//  Created by Alejandro Delgado Diaz on 30/4/15.
//  Copyright (c) 2015 alejandro. All rights reserved.
//

#import "ADDDictionarySelectorViewController.h"
#import "ADDAddWordViewController.h"

@interface ADDDictionarySelectorViewController () <UISearchDisplayDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) NSMutableArray *tableData;
@property (nonatomic, strong) NSMutableArray *searchResult;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ADDDictionarySelectorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem *searchNavButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchWord:)];
    UIBarButtonItem *addWord = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addSomething)];
    
    self.navigationItem.rightBarButtonItems = @[addWord, searchNavButton];
    
//    self.tableView.contentOffset = CGPointMake(0,  self.searchBar.frame.size.height - self.tableView.contentOffset.y);
    self.tableView.contentOffset = CGPointMake(0, self.searchDisplayController.searchBar.frame.size.height);
    
    self.tableData = [@[@"One",@"Two",@"Three",@"Twenty-one"] mutableCopy];
    
    self.searchResult = [NSMutableArray arrayWithCapacity:[self.tableData count]];
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
//    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private methods

- (void) addSomething{
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Add new:"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Word", @"List", @"Dictionary", nil];
    
    [actionSheet showInView:self.view];

}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    [self.searchResult removeAllObjects];
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", searchText];
    
    self.searchResult = [NSMutableArray arrayWithArray: [self.tableData filteredArrayUsingPredicate:resultPredicate]];
}

#pragma mark - ActionSheet Delegates

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {

            ADDAddWordViewController *addWordVC = [[ADDAddWordViewController alloc]init];
            UINavigationController *addWordNav = [[UINavigationController alloc] initWithRootViewController:addWordVC];

            [self presentViewController:addWordNav animated:YES completion:nil];
            break;
        }
        case 1:
        {
            
            break;
        }
            
        default:
            break;
    }
    
    NSLog(@"You have pressed the %@ button", [actionSheet buttonTitleAtIndex:buttonIndex]);
}

#pragma mark - TableView Delegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        return [self.searchResult count];
    }
    else
    {
        return [self.tableData count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        cell.textLabel.text = [self.searchResult objectAtIndex:indexPath.row];
    }
    else
    {
        cell.textLabel.text = self.tableData[indexPath.row];
    }
    
    return cell;
}

#pragma mark - Search methods

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return YES;
}

@end
