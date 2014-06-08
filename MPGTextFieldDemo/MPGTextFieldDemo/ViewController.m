//
//  ViewController.m
//  MPGTextFieldDemo
//
//  Created by Gaurav Wadhwani on 08/06/14.
//  Copyright (c) 2014 Mappgic. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self generateData];
    [self.name setDelegate:self];
    [self.companyName setDelegate:self];
    [self.companyName setBackgroundColor:[UIColor colorWithRed:210.0/255.0 green:213.0/255.0 blue:219.0/255.0 alpha:1.0]];
    [self.companyName setPopoverSize:CGRectMake(0, self.name.frame.origin.y + 220, 320.0, 50.0)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)generateData
{
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Add code here to do background processing
        //
        //
        NSError* err = nil;
        data = [[NSMutableArray alloc] init];
        companyData = [[NSMutableArray alloc] init];
        NSString* dataPath = [[NSBundle mainBundle] pathForResource:@"sample_data" ofType:@"json"];
        NSArray* contents = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:dataPath] options:kNilOptions error:&err];
        dispatch_async( dispatch_get_main_queue(), ^{
            // Add code here to update the UI/send notifications based on the
            // results of the background processing
            [contents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [data addObject:[NSDictionary dictionaryWithObjectsAndKeys:[[obj objectForKey:@"first_name"] stringByAppendingString:[NSString stringWithFormat:@" %@", [obj objectForKey:@"last_name"]]], @"DisplayText", [obj objectForKey:@"email"], @"DisplaySubText",obj,@"CustomObject", nil]];
                [companyData addObject:[NSDictionary dictionaryWithObjectsAndKeys:[obj objectForKey:@"company_name"], @"DisplayText", [obj objectForKey:@"address"], @"DisplaySubText",obj,@"CustomObject", nil]];
            }];
        });
    });
}

#pragma mark MPGTextField Delegate Methods

- (NSArray *)dataForPopoverInTextField:(MPGTextField *)textField
{
    if ([textField isEqual:self.name]) {
        return data;
    }
    else if ([textField isEqual:self.companyName]){
        return companyData;
    }
    else{
        return nil;
    }
}

- (BOOL)textFieldShouldSelect:(MPGTextField *)textField
{
    return YES;
}

- (void)textField:(MPGTextField *)textField didEndEditingWithSelection:(NSDictionary *)result
{
    //A selection was made - either by the user or by the textfield. Check if its a selection from the data provided or a NEW entry.
    if ([[result objectForKey:@"CustomObject"] isKindOfClass:[NSString class]] && [[result objectForKey:@"CustomObject"] isEqualToString:@"NEW"]) {
        //New Entry
        [self.nameStatus setHidden:NO];
    }
    else{
        //Selection from provided data
        if ([textField isEqual:self.name]) {
            [self.nameStatus setHidden:YES];
            [self.web setText:[[result objectForKey:@"CustomObject"] objectForKey:@"web"]];
            [self.email setText:[[result objectForKey:@"CustomObject"] objectForKey:@"email"]];
            [self.phone1 setText:[[result objectForKey:@"CustomObject"] objectForKey:@"phone1"]];
            [self.phone2 setText:[[result objectForKey:@"CustomObject"] objectForKey:@"phone2"]];
        }
        [self.address setText:[[result objectForKey:@"CustomObject"] objectForKey:@"address"]];
        [self.state setText:[[result objectForKey:@"CustomObject"] objectForKey:@"state"]];
        [self.zip setText:[[result objectForKey:@"CustomObject"] objectForKey:@"zip"]];
        [self.companyName setText:[[result objectForKey:@"CustomObject"] objectForKey:@"company_name"]];
    }
}

@end
