//
//  MPGTextField.h
//
//  Created by Gaurav Wadhwani on 05/06/14.
//  Copyright (c) 2014 Mappgic. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MPGTextFieldDelegate;

@interface MPGTextField : UITextField <UITableViewDelegate, UITableViewDataSource, UIPopoverControllerDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, weak) id <MPGTextFieldDelegate, UITextFieldDelegate> delegate;

//Set this to override the default color of suggestions popover. The default color is [UIColor colorWithWhite:0.8 alpha:0.9]
@property (nonatomic) UIColor *backgroundColor;

//Set this to override the default frame of the suggestions popover that will contain the suggestions pertaining to the search query. The default frame will be of the same width as textfield, of height 200px and be just below the textfield.
@property (nonatomic) CGRect popoverSize;

//Set this to override the default seperator color for tableView in search results. The default color is light gray.
@property (nonatomic) UIColor *seperatorColor;

@end

@protocol MPGTextFieldDelegate <NSObject>

@required

//A mandatory method that must be conformed by the using class. It expects an NSArray of NSDictionary objects where the dictionary should contain the key 'DisplayText' and optionally contain the keys - 'DisplaySubText' and 'CustomObject'

- (NSArray *)dataForPopoverInTextField:(MPGTextField *)textField;

@optional

//If mandatory selection needs to be made (asked via delegate), this method. It can have the following return values:
//1. If user taps on a row in the search results, it will return the selected NSDictionary object
//2. If the user doesn't tap a row, it will return the first NSDictionary object from the results
//3. If the user doesn't tap a row and there is no search result, it will return a NEW NSDictionary object containing the text entered by the user and the value of 'Custom object' will be set to 'NEW'

- (void)textField:(MPGTextField *)textField didEndEditingWithSelection:(NSDictionary *)result;

//This delegate method is used to specify if a mandatory selection needs to be made. Set this property to YES if you want a selection to be made from the accompanying popover. In case the user does not select anything from the popover and this property is set to YES, the first item from the search results will be selected automatically. If this property is set to NO and the user doesn't select anything from the popover, the text will remain as-is in the textfield. Default Value is NO.
- (BOOL)textFieldShouldSelect:(MPGTextField *)textField;

@end
