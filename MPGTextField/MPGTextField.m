//
//  MPGTextField.m
//  Racks
//
//  Created by Gaurav Wadhwani on 05/06/14.
//  Copyright (c) 2014 Mappgic. All rights reserved.
//

#import "MPGTextField.h"

@implementation MPGTextField

//Private declaration of UITableViewController that will present the results in a popover depending on the search query typed by the user.
UITableViewController *results;
UITableViewController *tableViewController;

//Private declaration of an internal user boolean variable - 'cleanup'. This is used to make sure that -layoutSubviews does not enter into an infinite loop.
BOOL cleanup;

//Private declaration of NSArray that will hold the data supplied by the user for showing results in search popover.
NSArray *data;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        cleanup = NO;
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
    if (cleanup) {
        cleanup = NO;
        [self resignFirstResponder];
        return;
    }
    
    if (self.text.length > 0 && self.isFirstResponder) {
        //User entered some text in the textfield. Check if the delegate has implemented the required method of the protocol. Create a popover and show it around the MPGTextField.
        
        if ([self.delegate respondsToSelector:@selector(dataForPopoverInTextField:)]) {

            if (![self.popover isPopoverVisible]) {
                //Popover is not visible. Create an instance of the popover and present it to the user
                results = [[UITableViewController alloc] init];
                [results.tableView setDelegate:self];
                [results.tableView setDataSource:self];
                if(self.popoverSize.height == 0.0){
                    //Popover size is not set. Default it to 300x500.
                    [results setPreferredContentSize:CGSizeMake(300.0, 400.0)];
                }
                else{
                    [results setPreferredContentSize:self.popoverSize];
                }
                [results.tableView setSeparatorColor:self.seperatorColor];
                self.popover = [[UIPopoverController alloc] initWithContentViewController:results];
                [self.popover setDelegate:self];
                [self.popover presentPopoverFromRect:[self frame] inView:[self superview] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
                data = [[self delegate] dataForPopoverInTextField:self];
            }
            //Filter the result set w/the text entered by the user and reload the table view.
            [results.tableView reloadData];
        }
        else{
            NSLog(@"<MPGTextField> WARNING: You have not implemented the requred methods of the MPGTextField protocol.");
        }
    }
    else{
        //No text entered in the textfield. Check if popover is visible. If so, dismiss it. If mandatorySelection is enabled, select the first row from results.tableView and set the displayText on the text field..
        if ([self.popover isPopoverVisible]) {
            [self.popover dismissPopoverAnimated:YES];
        }
        if (!self.isFirstResponder) {
            //Textfield is no longer in focus. -handleExit method checks for mandatory selection variable and handles the resignation of first responder accordingly.
            [self handleExit];
        }
    }
}

- (void)handleExit
{
    if ([[self delegate] respondsToSelector:@selector(textFieldShouldSelect:)]) {
        if ([[self delegate] textFieldShouldSelect:self]) {
            if ([self applyFilterWithSearchQuery:self.text].count > 0) {
                cleanup = YES;
                self.text = [[[self applyFilterWithSearchQuery:self.text] objectAtIndex:0] objectForKey:@"DisplayText"];
                [[self delegate] textField:self didEndEditingWithSelection:[[self applyFilterWithSearchQuery:self.text] objectAtIndex:0]];
            }
            else if (self.text.length > 0){
                //Make sure that delegate method is not called if no text is present in the text field.
                cleanup = YES;
                [[self delegate] textField:self didEndEditingWithSelection:[NSDictionary dictionaryWithObjectsAndKeys:self.text,@"DisplayText",@"NEW",@"CustomObject", nil]];
                [self resignFirstResponder];
            }
        }
    }
}


#pragma mark UITableView DataSource & Delegate Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self applyFilterWithSearchQuery:self.text] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MPGResultsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    [[cell textLabel] setText:[[[self applyFilterWithSearchQuery:self.text] objectAtIndex:indexPath.row] objectForKey:@"DisplayText"]];
    if ([[[self applyFilterWithSearchQuery:self.text] objectAtIndex:indexPath.row] objectForKey:@"DisplaySubText"] != nil) {
        [[cell detailTextLabel] setText:[[[self applyFilterWithSearchQuery:self.text] objectAtIndex:indexPath.row] objectForKey:@"DisplaySubText"]];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.text = [[[self applyFilterWithSearchQuery:self.text] objectAtIndex:indexPath.row] objectForKey:@"DisplayText"];
    [self.popover dismissPopoverAnimated:YES];
    cleanup = YES;
    [self layoutSubviews];
}

#pragma mark Filter Method

- (NSArray *)applyFilterWithSearchQuery:(NSString *)filter
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"DisplayText BEGINSWITH[cd] %@", filter];
    NSArray *filteredGoods = [NSArray arrayWithArray:[data filteredArrayUsingPredicate:predicate]];
    return filteredGoods;
}

#pragma mark Popover Delegate Method

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    cleanup = YES;
    [self layoutSubviews];
}


@end
