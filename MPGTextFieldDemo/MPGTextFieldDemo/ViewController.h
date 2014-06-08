//
//  ViewController.h
//  MPGTextFieldDemo
//
//  Created by Gaurav Wadhwani on 08/06/14.
//  Copyright (c) 2014 Mappgic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPGTextField.h"

@interface ViewController : UIViewController <UITextFieldDelegate, MPGTextFieldDelegate>
{
    NSMutableArray *data;
    NSMutableArray *companyData;
}

@property (weak, nonatomic) IBOutlet MPGTextField *name;
@property (weak, nonatomic) IBOutlet MPGTextField *companyName;
@property (weak, nonatomic) IBOutlet UITextField *address;
@property (weak, nonatomic) IBOutlet UITextField *zip;
@property (weak, nonatomic) IBOutlet UITextField *state;
@property (weak, nonatomic) IBOutlet UITextField *phone2;
@property (weak, nonatomic) IBOutlet UITextField *phone1;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *web;

@property (weak, nonatomic) IBOutlet UIButton *nameStatus;


@end
