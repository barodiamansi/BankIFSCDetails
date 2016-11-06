//
//  ViewController.m
//  BankIFSCDetails
//
//  Created by Mansi Barodia on 10/23/16.
//  Copyright © 2016 Mansi Barodia. All rights reserved.
//

#import "ViewController.h"
#import "BankListController.h"
#import "StateListController.h"
#import "CodeSearchViewController.h"

@interface ViewController ()

// Holds the options by which the bank details should be searched.
@property (strong, nonatomic) NSArray *optionsArray;

@end

// Number of components in options picker.
const int NUM_PICKER_COMPONENTS = 1;

// Number of rows in each component of options picker.
const int NUM_ROWS_PICKER_COMPONENTS = 4;

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.optionsArray = @[@"Search by Bank", @"Search by State", @"Search by IFSC Code", @"Search by MICR Code"];
    
    self.optionsPicker = [[UIPickerView alloc] init];
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

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    switch (row) {
        case 0:
            [self.navigationController pushViewController:[[BankListController alloc] init] animated:YES];
            break;
        case 1:
            [self.navigationController pushViewController:[[StateListController alloc] init] animated:YES];
            break;
        case 2:
            [self.navigationController pushViewController:[[CodeSearchViewController alloc] initWithCode:@"IFSC Code"] animated:YES];
            break;
        case 3:
            [self.navigationController pushViewController:[[CodeSearchViewController alloc] initWithCode:@"MICR Code"] animated:YES];
            break;
        default:
            NSLog(@"Default");
            break;
    }
    
}

@end
