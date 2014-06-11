//
//  MPGTextField.m
//
//  Created by Gaurav Wadhwani on 05/06/14.
//  Copyright (c) 2014 Mappgic. All rights reserved.
//

#import "MPGTextField.h"

@implementation MPGTextField

//Private declaration of UITableViewController that will present the results in a popover depending on the search query typed by the user.
UITableViewController *results;
UITableViewController *tableViewController;

//Private declaration of NSArray that will hold the data supplied by the user for showing results in search popover.
NSArray *data;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.text.length > 0 && self.isFirstResponder) {
        //User entered some text in the textfield. Check if the delegate has implemented the required method of the protocol. Create a popover and show it around the MPGTextField.
        
        if ([self.delegate respondsToSelector:@selector(dataForPopoverInTextField:)]) {
            data = [[self delegate] dataForPopoverInTextField:self];
            [self provideSuggestions];
        }
        else{
            NSLog(@"<MPGTextField> WARNING: You have not implemented the requred methods of the MPGTextField protocol.");
        }
    }
    else{
        //No text entered in the textfield. If -textFieldShouldSelect is YES, select the first row from results using -handleExit method.tableView and set the displayText on the text field. Check if suggestions view is visible and dismiss it.
        if ([tableViewController.tableView superview] != nil) {
            [tableViewController.tableView removeFromSuperview];
        }
    }
}

//Override UITextField -resignFirstResponder method to ensure the 'exit' is handled properly.
- (BOOL)resignFirstResponder
{
    [UIView animateWithDuration:0.3
                     animations:^{
                         [tableViewController.tableView setAlpha:0.0];
                     }
                     completion:^(BOOL finished){
                         [tableViewController.tableView removeFromSuperview];
                         tableViewController = nil;
                     }];
    [self handleExit];
    return [super resignFirstResponder];
}

//This method checks if a selection needs to be made from the suggestions box using the delegate method -textFieldShouldSelect. If a user doesn't tap any search suggestion, the textfield automatically selects the top result. If there is no result available and the delegate method is set to return YES, the textfield will wrap the entered the text in a NSDictionary and send it back to the delegate with 'CustomObject' key set to 'NEW'
- (void)handleExit
{
    [tableViewController.tableView removeFromSuperview];
    if ([[self delegate] respondsToSelector:@selector(textFieldShouldSelect:)]) {
        if ([[self delegate] textFieldShouldSelect:self]) {
            if ([self applyFilterWithSearchQuery:self.text].count > 0) {
                self.text = [[[self applyFilterWithSearchQuery:self.text] objectAtIndex:0] objectForKey:@"DisplayText"];
                if ([[self delegate] respondsToSelector:@selector(textField:didEndEditingWithSelection:)]) {
                    [[self delegate] textField:self didEndEditingWithSelection:[[self applyFilterWithSearchQuery:self.text] objectAtIndex:0]];
                }
                else{
                    NSLog(@"<MPGTextField> WARNING: You have not implemented a method from MPGTextFieldDelegate that is called back when the user selects a search suggestion.");
                }
            }
            else if (self.text.length > 0){
                //Make sure that delegate method is not called if no text is present in the text field.
                if ([[self delegate] respondsToSelector:@selector(textField:didEndEditingWithSelection:)]) {
                    [[self delegate] textField:self didEndEditingWithSelection:[NSDictionary dictionaryWithObjectsAndKeys:self.text,@"DisplayText",@"NEW",@"CustomObject", nil]];
                }
                else{
                    NSLog(@"<MPGTextField> WARNING: You have not implemented a method from MPGTextFieldDelegate that is called back when the user selects a search suggestion.");
                }
            }
        }
    }
}


#pragma mark UITableView DataSource & Delegate Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = [[self applyFilterWithSearchQuery:self.text] count];
    if (count == 0) {
        [UIView animateWithDuration:0.3
                         animations:^{
                             [tableViewController.tableView setAlpha:0.0];
                         }
                         completion:^(BOOL finished){
                             [tableViewController.tableView removeFromSuperview];
                             tableViewController = nil;
                         }];
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MPGResultsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *dataForRowAtIndexPath = [[self applyFilterWithSearchQuery:self.text] objectAtIndex:indexPath.row];
    [cell setBackgroundColor:[UIColor clearColor]];
    [[cell textLabel] setText:[dataForRowAtIndexPath objectForKey:@"DisplayText"]];
    if ([dataForRowAtIndexPath objectForKey:@"DisplaySubText"] != nil) {
        [[cell detailTextLabel] setText:[dataForRowAtIndexPath objectForKey:@"DisplaySubText"]];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.text = [[[self applyFilterWithSearchQuery:self.text] objectAtIndex:indexPath.row] objectForKey:@"DisplayText"];
    [self resignFirstResponder];
}

#pragma mark Filter Method

- (NSArray *)applyFilterWithSearchQuery:(NSString *)filter
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"DisplayText BEGINSWITH[cd] %@", filter];
    NSArray *filteredGoods = [NSArray arrayWithArray:[data filteredArrayUsingPredicate:predicate]];
    return filteredGoods;
}

#pragma mark Popover Method(s)

- (void)provideSuggestions
{
    //Providing suggestions
    if (tableViewController.tableView.superview == nil && [[self applyFilterWithSearchQuery:self.text] count] > 0) {
        //Add a tap gesture recogniser to dismiss the suggestions view when the user taps outside the suggestions view
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        [tapRecognizer setNumberOfTapsRequired:1];
        [tapRecognizer setCancelsTouchesInView:NO];
        [tapRecognizer setDelegate:self];
        [self.superview addGestureRecognizer:tapRecognizer];
        
        tableViewController = [[UITableViewController alloc] init];
        [tableViewController.tableView setDelegate:self];
        [tableViewController.tableView setDataSource:self];
        if (self.backgroundColor == nil) {
            //Background color has not been set by the user. Use default color instead.
            [tableViewController.tableView setBackgroundColor:[UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0]];
        }
        else{
            [tableViewController.tableView setBackgroundColor:self.backgroundColor];
        }
        
        [tableViewController.tableView setSeparatorColor:self.seperatorColor];
        if (self.popoverSize.size.height == 0.0) {
            //PopoverSize frame has not been set. Use default parameters instead.
            CGRect frameForPresentation = [self frame];
            frameForPresentation.origin.y += self.frame.size.height;
            frameForPresentation.size.height = 200;
            [tableViewController.tableView setFrame:frameForPresentation];
        }
        else{
            [tableViewController.tableView setFrame:self.popoverSize];
        }
        [[self superview] addSubview:tableViewController.tableView];
        tableViewController.tableView.alpha = 0.0;
        [UIView animateWithDuration:0.3
                         animations:^{
                             [tableViewController.tableView setAlpha:1.0];
                         }
                         completion:^(BOOL finished){
                             
                         }];
        
        
    }
    else{
        [tableViewController.tableView reloadData];
    }
}

- (void)tapped:(UIGestureRecognizer *)gesture
{
    
}


@end
