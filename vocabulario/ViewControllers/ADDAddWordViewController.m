//
//  ADDAddWordViewController.m
//  vocabulario
//
//  Created by Alejandro Delgado Diaz on 4/5/15.
//  Copyright (c) 2015 alejandro. All rights reserved.
//

#import "ADDAddWordViewController.h"

@interface ADDAddWordViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITableViewCell *wordOneCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *wordTwoCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *commentsCell;
@property (weak, nonatomic) IBOutlet UITextView *commentsTextView;

@property (nonatomic, strong) NSArray *cellsArray;

@end

@implementation ADDAddWordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"New word";
    
    self.cellsArray = @[self.wordOneCell, self.wordTwoCell, self.commentsCell];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAdding)];
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveWord)];

    self.navigationItem.leftBarButtonItem = cancelButton;
    self.navigationItem.rightBarButtonItem = saveButton;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardAppears:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDissapears:) name:UIKeyboardDidHideNotification object:nil];

}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self textViewDidChange:self.commentsTextView];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Helper method
- (void)cancelAdding
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveWord
{
    NSLog(@"Do something");
}

- (void)keyboardAppears:(NSNotification*)notification
{
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    [self.tableView setFrame:CGRectMake(0, 0,self.tableView.contentSize.width, self.tableView.frame.size.height - keyboardFrameBeginRect.size.height)];
    [self.tableView needsUpdateConstraints];
}

- (void)keyboardDissapears:(NSNotification*)notification
{
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    [self.tableView setFrame:CGRectMake(0, 0,self.tableView.contentSize.width, self.tableView.frame.size.height + keyboardFrameBeginRect.size.height)];
    [self.tableView needsUpdateConstraints];
}

#pragma mark - Table View Data Source

// Return the number of sections
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

// Return the number of rows for each section in your static table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch(section)
    {
        case 0: return 2;  // section 0 has 2 rows
        case 1: return 1;
        default: return 0;
    };
}

// Return the row for the corresponding section and row
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch(indexPath.section)
    {
        case 0:
            switch(indexPath.row)
            {
                case 0: return self.wordOneCell;  // section 0, row 0 is the first name
                case 1: return self.wordTwoCell;
            }
        case 1:
            switch (indexPath.row)
            {
                case 0: return self.commentsCell;
            }
    }
    return nil;
}

#pragma mark - Table View Delegate

// Customize the section headings for each section
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch(section)
    {
        case 0: return @"New word";
        case 1: return @"Comments";
    }
    
    return nil;
}


// Configure the row selection code for any cells that you want to customize the row selection
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Handle social cell selection to toggle checkmark
    if(indexPath.section == 1 && indexPath.row == 0) {
        
        // deselect row
        [tableView deselectRowAtIndexPath:indexPath animated:false];
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 0)
    {
        return self.commentsTextView.contentSize.height + 8.0;
    }else{
        return UITableViewAutomaticDimension;
    }
}

#pragma mark - TextView Delegate

- (void)textViewDidChange:(UITextView *)textView
{
    [self.cellsArray enumerateObjectsUsingBlock:^(UITableViewCell *obj, NSUInteger idx, BOOL *stop) {
        if (obj.tag == 3) {
            NSIndexPath *indexPath = [self.tableView indexPathForCell:obj];
            [self tableView:self.tableView heightForRowAtIndexPath:indexPath];
            [self.tableView beginUpdates];
            [self.tableView endUpdates];

        }
    }];
}

@end
