//
//  MakeListTableViewController.m
//  MakeList
//
//  Created by Felix Santiago on 10/13/13.
//  Copyright (c) 2013 Felix Santiago. All rights reserved.
//

#import "MakeListTableViewController.h"
#import "MultiLineCell.h"

@interface MakeListTableViewController ()

@property (nonatomic, strong) NSMutableArray *listItems;
@property (nonatomic, strong) NSString *listFile;

- (IBAction)dismissKeyboard:(id)sender;
- (void)addItem:sender;
- (void)toggleEdit:sender;
- (void)saveContents;

@end

@implementation MakeListTableViewController

@synthesize listItems;

# pragma mark - Custom property getters

- (NSString *)listFile {
    if (!_listFile) {
        _listFile = [[NSBundle mainBundle] pathForResource:@"ListItems" ofType:@"plist"];
    }
    return _listFile;
}

# pragma mark - ViewController Functions

- (void)viewDidLoad {
    [super viewDidLoad];

    // Add in our custom cell
    UINib *multiLineCellNib = [UINib nibWithNibName:@"MultiLineCell" bundle:nil];
    [self.tableView registerNib:multiLineCellNib forCellReuseIdentifier:@"Cell"];
    

    // Show the Add and Edit buttons
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(toggleEdit:)];
    self.navigationItem.leftBarButtonItem = editButton;
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                               target:self
                                                                               action:@selector(addItem:)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    // Add in a Tap Gesture for dismissing the keyboard
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard:)];
    tap.delegate = self;
    [self.tableView addGestureRecognizer:tap];
    
    // Load the todo list items;
    listItems = [[NSMutableArray alloc] initWithContentsOfFile:self.listFile];
}


- (IBAction)dismissKeyboard:(id)sender {
    [self.view endEditing:YES];
 
}

# pragma mark - Helper Functions

- (void)addItem:sender {
    if (self.tableView.isEditing) {
        [self toggleEdit:nil];
    }
    NSIndexPath *topRow = [NSIndexPath indexPathForRow:0 inSection:0];
    [self tableView:self.tableView commitEditingStyle:UITableViewCellEditingStyleInsert forRowAtIndexPath:topRow];
}

- (void)toggleEdit:sender {
    [self.tableView setEditing:!self.tableView.isEditing animated:YES];
    
    if (self.tableView.isEditing) {
        [self.view endEditing:YES];
        [self.navigationItem.leftBarButtonItem setTitle:@"Done"];
    } else {
        [self.navigationItem.leftBarButtonItem setTitle:@"Edit"];
    }
}

- (void)saveContents {
//    NSLog(@"%@", listItems);
    [listItems writeToFile:self.listFile atomically:NO];
}

#pragma mark - TableViewDelegate Methods

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:YES];
}

#pragma mark - TableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [listItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    MultiLineCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSString *itemName = [listItems objectAtIndex:indexPath.row];
    cell.cellTextView.delegate = self;
    cell.cellTextView.text = itemName;
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
                                            forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [listItems removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        [listItems insertObject:@"" atIndex:indexPath.row];
        [tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
        MultiLineCell *cell = (MultiLineCell *) [tableView cellForRowAtIndexPath:indexPath];
        [cell.cellTextView becomeFirstResponder];
    }
    [self saveContents];
}


// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    [listItems moveObjectAtIndex:fromIndexPath.row toIndex:toIndexPath.row];
    [self saveContents];
}

#pragma mark - TextViewDelegate Methods

- (void)textViewDidEndEditing:(UITextView *)textView {

    CGPoint hitPoint = [textView convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *index = [self.tableView indexPathForRowAtPoint:hitPoint];
    listItems[index.row] = textView.text;
//    NSLog(@"%@", textView.text);
    [self saveContents];
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [self dismissKeyboard:nil];
        return NO;
    }

    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if (self.tableView.isEditing) {
        return NO;
    }
    return YES;
}

#pragma mark - UIGestureRecognizerDelegate Methods

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // Only listen for tap events when we're not in editing mode
    if (self.tableView.isEditing) {
        return NO;
    }
    return YES;
}

@end
