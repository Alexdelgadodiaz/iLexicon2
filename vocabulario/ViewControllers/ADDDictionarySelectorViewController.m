//
//  ADDDictionarySelectorViewController.m
//  vocabulario
//
//  Created by Alejandro Delgado Diaz on 30/4/15.
//  Copyright (c) 2015 alejandro. All rights reserved.
//

#import "ADDDictionarySelectorViewController.h"
#import "ADDAddWordViewController.h"
#import "AddWordSelectorViewController.h"
#import "ADDWordTableViewCell.h"

static NSString *wordCellIdentifier = @"WordCell";


@interface ADDDictionarySelectorViewController ()
<UISearchDisplayDelegate,
UIActionSheetDelegate,
UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSMutableArray *tableData;
@property (nonatomic, strong) NSMutableArray *searchResult;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *testForHight;

@property (nonatomic, strong) UILongPressGestureRecognizer *pressGestureRecognizer;


@end

@implementation ADDDictionarySelectorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if ([self.title isEqualToString:@"Vocabulary"]) {
        [self.tableView registerNib:[UINib nibWithNibName:@"ADDWordTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:wordCellIdentifier];
    }
    
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];

    
    UIBarButtonItem *searchNavButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchWord:)];
    UIBarButtonItem *addWord = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addSomething)];
    
    self.navigationItem.rightBarButtonItems = @[addWord, searchNavButton];
    
//    self.tableView.contentOffset = CGPointMake(0,  self.searchBar.frame.size.height - self.tableView.contentOffset.y);
    self.tableView.contentOffset = CGPointMake(0, self.searchDisplayController.searchBar.frame.size.height);
    
    self.pressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressOnCell:)];
    self.pressGestureRecognizer.minimumPressDuration = 0.7; //seconds
    self.pressGestureRecognizer.delegate = self;
    self.pressGestureRecognizer.enabled=YES;
    self.pressGestureRecognizer.numberOfTouchesRequired =1;
    
    [self.tableView addGestureRecognizer:self.pressGestureRecognizer];
    
    self.tableData = [@[@"One",@"Two",@"Three",@"Twenty-one"] mutableCopy];
    
    self.searchResult = [NSMutableArray arrayWithCapacity:[self.tableData count]];
}

- (void) longPressOnCell:(UILongPressGestureRecognizer *)longPress
{
    
//    UILongPressGestureRecognizer *longPress = (UILongPressGestureRecognizer *)sender;
    UIGestureRecognizerState state = longPress.state;
    
    CGPoint location = [longPress locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    
    static UIView       *snapshot = nil;        ///< A snapshot of the row user is moving.
    static NSIndexPath  *sourceIndexPath = nil; ///< Initial index path, where gesture begins.
    
    switch (state) {
        case UIGestureRecognizerStateBegan: {
            if (indexPath) {
                sourceIndexPath = indexPath;
                
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                
                // Take a snapshot of the selected row using helper method.
                snapshot = [self customSnapshoFromView:cell];
                
                // Add the snapshot as subview, centered at cell's center...
                __block CGPoint center = cell.center;
                snapshot.center = center;
                snapshot.alpha = 0.0;
                [self.tableView addSubview:snapshot];
                [UIView animateWithDuration:0.25 animations:^{
                    
                    // Offset for gesture location.
                    center.y = location.y;
                    snapshot.center = center;
                    snapshot.transform = CGAffineTransformMakeScale(1.05, 1.05);
                    snapshot.alpha = 0.98;
                    cell.alpha = 0.0;
                    
                } completion:^(BOOL finished) {
                    
                    cell.hidden = YES;
                    
                }];
            }
            break;
        }
            
        case UIGestureRecognizerStateChanged: {
            CGPoint center = snapshot.center;
            center.y = location.y;
            snapshot.center = center;
            
            // Is destination valid and is it different from source?
            if (indexPath && ![indexPath isEqual:sourceIndexPath]) {
                
                // ... update data source.
                [self.tableData exchangeObjectAtIndex:indexPath.row withObjectAtIndex:sourceIndexPath.row];
                
                // ... move the rows.
                [self.tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:indexPath];
                
                // ... and update source so it is in sync with UI changes.
                sourceIndexPath = indexPath;
            }
            break;
        }
            
        default: {
            // Clean up.
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:sourceIndexPath];
            cell.hidden = NO;
            cell.alpha = 0.0;
            
            [UIView animateWithDuration:0.25 animations:^{
                
                snapshot.center = cell.center;
                snapshot.transform = CGAffineTransformIdentity;
                snapshot.alpha = 0.0;
                cell.alpha = 1.0;
                
            } completion:^(BOOL finished) {
                
                sourceIndexPath = nil;
                [snapshot removeFromSuperview];
                snapshot = nil;
                
            }];
            
            break;
        }
    }
}

/** @brief Returns a customized snapshot of a given view. */
- (UIView *)customSnapshoFromView:(UIView *)inputView {
    
    // Make an image from the input view.
    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, NO, 0);
    [inputView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Create an image view.
    UIView *snapshot = [[UIImageView alloc] initWithImage:image];
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.0;
    snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    snapshot.layer.shadowRadius = 5.0;
    snapshot.layer.shadowOpacity = 0.4;
    snapshot.backgroundColor = [UIColor redColor];
    return snapshot;
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    //    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];

}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
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

            AddWordSelectorViewController *wordSelector = [[AddWordSelectorViewController alloc]init];
            wordSelector.title = @"Dictionary";
            wordSelector.objectToAdd = ADDObjectToAddWord;
            UINavigationController *wordSelectorNav = [[UINavigationController alloc] initWithRootViewController:wordSelector];

            [self presentViewController:wordSelectorNav animated:YES completion:nil];
            break;
        }
        case 1:
        {
            AddWordSelectorViewController *wordSelector = [[AddWordSelectorViewController alloc]init];
            wordSelector.title = @"Dictionary";
            wordSelector.objectToAdd = ADDObjectToAddList;
            UINavigationController *wordSelectorNav = [[UINavigationController alloc] initWithRootViewController:wordSelector];
            
            [self presentViewController:wordSelectorNav animated:YES completion:nil];
            break;
        }
        case 2:
        {
            ADDAddWordViewController *addWordVC = [[ADDAddWordViewController alloc]init];
            addWordVC.title = @"Add Dictionary";
            addWordVC.objectToAdd = ADDObjectToAddDictionary;
            UINavigationController *addWordNav = [[UINavigationController alloc] initWithRootViewController:addWordVC];

            [self presentViewController:addWordNav animated:YES completion:nil];
            break;
        }
            
        default:
            break;
    }
    
    NSLog(@"You have pressed the %@ button", [actionSheet buttonTitleAtIndex:buttonIndex]);
}

#pragma mark - TableView Delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([self.title isEqualToString:@"Vocabulary"]) {
        return 36;
    }else return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([self.title isEqualToString:@"Vocabulary"]) {

        ADDWordTableViewCell *wordCell = (ADDWordTableViewCell *)[tableView dequeueReusableCellWithIdentifier:wordCellIdentifier];
        wordCell.word1.text = @"ejemplo2";
        wordCell.word1.editable = NO;
        wordCell.word2.text = @"ejemplo1";
        wordCell.word2.editable = NO;
        wordCell.word1.selectable = NO;
        wordCell.word2.selectable = NO;
        
        wordCell.backgroundColor = [UIColor redColor];
        
        return wordCell;
    }
    
    return nil;
}

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


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // devolvemos el tamaño al mismo que el background que hemos puesto+
    
    if ([self.title isEqualToString:@"Vocabulary"])
    {
        ADDWordTableViewCell *wordCell = self.testForHight[indexPath.row];
        return wordCell.word1.contentSize.height > wordCell.word2.contentSize.height ? wordCell.word1.contentSize.height : wordCell.word2.contentSize.height;
    }else{
        return 50;
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *normalCellIdentifier = @"NormalCell";
    
    if ([self.title isEqualToString:@"Vocabulary"])
    {
        ADDWordTableViewCell *wordCell = (ADDWordTableViewCell *)[tableView dequeueReusableCellWithIdentifier:wordCellIdentifier];
                
        if (wordCell == nil) {
            wordCell = [[ADDWordTableViewCell alloc]init];
        }
        
        if (tableView == self.searchDisplayController.searchResultsTableView){
           
            wordCell.word1.text = [self.searchResult objectAtIndex:indexPath.row];
            wordCell.word2.text = @"ejemplo dos";
            
            
        }else{
            
            wordCell.word1.text = [NSString stringWithFormat:@"ejemplo %ld", indexPath.row];
            wordCell.word1.editable = NO;
            wordCell.word2.text = @"ejemplo1";
            wordCell.word2.editable = NO;
            
        }
        
        if (indexPath.row % 2 ==0) {
            
            UIImageView *imagecell=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
            imagecell.image=[UIImage imageNamed:@"barraSearchVoca"];
            wordCell.backgroundView=imagecell;
        }else{
            
            UIImageView *imagecell=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
            imagecell.image=[UIImage imageNamed:@"barraSearchVoca2"];
            wordCell.backgroundView=imagecell;
        }
        
        if (self.testForHight == nil) {
            self.testForHight = [NSMutableArray new];
        }
        
        [self.testForHight addObject:wordCell];
        
        return wordCell;
        

    }else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:normalCellIdentifier];
        
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:normalCellIdentifier];
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
    
    return nil;

}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *moreAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Info" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        // maybe show an action sheet with more options
        ADDAddWordViewController *addWordVC = [[ADDAddWordViewController alloc]init];
        addWordVC.title = @"Dictionary info";
        if ([self.title isEqualToString:@"List"]) {
            addWordVC.objectToAdd =ADDObjectToAddList;
        }else{
            addWordVC.objectToAdd = ADDObjectToAddWord;

        }
        UINavigationController *addWordNav = [[UINavigationController alloc] initWithRootViewController:addWordVC];
        
        [self presentViewController:addWordNav animated:YES completion:nil];
        
        [self.tableView setEditing:NO];
    }];
    moreAction.backgroundColor = [UIColor lightGrayColor];
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        [self.tableData removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
    
    return @[deleteAction, moreAction];
}

// From Master/Detail Xcode template
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.tableData removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![self.title isEqualToString:@"Vocabulary"]) {
        ADDDictionarySelectorViewController *listSelectorVC = [[ADDDictionarySelectorViewController alloc]init];
        if ([self.title isEqualToString:@"Dictionaries"]) {
            listSelectorVC.title = @"List";
        }else{
            listSelectorVC.title = @"Vocabulary";
        }
        
        [self.navigationController pushViewController:listSelectorVC animated:YES];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];

    }

}

#pragma mark - Search methods

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return YES;
}

@end
