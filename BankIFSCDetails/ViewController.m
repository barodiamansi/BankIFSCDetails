//
//  ViewController.m
//  BankIFSCDetails
//
//  Created by Mansi Barodia on 10/23/16.
//  Copyright © 2016 Mansi Barodia. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

// Holds the options by which the bank details should be searched.
@property (strong, nonatomic) NSArray *optionsArray;

// Title to be displayed on the app.
@property (copy) NSString *appOptionsViewTitle;

@end

// Number of components in options picker.
const int NUM_PICKER_COMPONENTS = 1;

// Number of rows in each component of options picker.
const int NUM_ROWS_PICKER_COMPONENTS = 4;

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _optionsArray = @[@"Search by State", @"Search by Branch", @"Search by IFSC Code", @"Search by MICR Code"];
    
    _optionsPicker = [[UIPickerView alloc] init];
    _appTitle.text = @"Bank Details - Select an option";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return NUM_PICKER_COMPONENTS;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return NUM_ROWS_PICKER_COMPONENTS;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
   return [_optionsArray objectAtIndex:row];
}

@end
