//
//  AddWordSelectorViewController.m
//  vocabulario
//
//  Created by Alejandro Delgado Diaz on 5/5/15.
//  Copyright (c) 2015 alejandro. All rights reserved.
//

#import "AddWordSelectorViewController.h"
#import "ADDAddWordViewController.h"

@interface AddWordSelectorViewController () <UISearchDisplayDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (nonatomic, strong) NSMutableArray *tableData;
@property (nonatomic, strong) NSMutableArray *searchResult;

@end

@implementation AddWordSelectorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if ([self.title isEqualToString:@"Dictionary"]) {
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelSelection)];
        
        self.navigationItem.leftBarButtonItem = cancelButton;
    }

    
    self.tableView.contentOffset = CGPointMake(0, self.searchDisplayController.searchBar.frame.size.height);
    
    self.tableData = [@[@"One",@"Two",@"Three",@"Twenty-one"] mutableCopy];
    
    self.searchResult = [NSMutableArray arrayWithCapacity:[self.tableData count]];
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    //    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    [self.searchResult removeAllObjects];
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", searchText];
    
    self.searchResult = [NSMutableArray arrayWithArray: [self.tableData filteredArrayUsingPredicate:resultPredicate]];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.title isEqualToString:@"List"])
    {
        ADDAddWordViewController *addWordVC = [[ADDAddWordViewController alloc]init];
        addWordVC.title = @"Add word";
        addWordVC.objectToAdd = self.objectToAdd;
        [self.navigationController pushViewController:addWordVC animated:YES];
        
    }else if (self.objectToAdd == ADDObjectToAddWord)
    {
        AddWordSelectorViewController *wordSelectorListVC = [[AddWordSelectorViewController alloc]init];
        wordSelectorListVC.title = @"List";
        wordSelectorListVC.objectToAdd = self.objectToAdd;
        [self.navigationController pushViewController:wordSelectorListVC animated:YES];
        
    }else if (self.objectToAdd == ADDObjectToAddList)
    {
        ADDAddWordViewController *addlistVC = [[ADDAddWordViewController alloc]init];
        addlistVC.title = @"Add list";
        addlistVC.objectToAdd = self.objectToAdd;
        [self.navigationController pushViewController:addlistVC animated:YES];
    }
}

#pragma mark - helper methods

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return YES;
}

- (void)cancelSelection
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end