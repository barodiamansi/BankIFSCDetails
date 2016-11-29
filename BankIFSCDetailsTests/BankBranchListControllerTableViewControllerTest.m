//
//  BankBranchListControllerTableViewControllerTest.m
//  BankIFSCDetails
//
//  Created by Mansi Barodia on 11/29/16.
//  Copyright © 2016 Mansi Barodia. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BankBranchListControllerTableViewController.h"
#import "BranchDetailsTableViewCell.h"
#import "BranchDetails.h"
#import <OCMock/OCMock.h>

@interface BankBranchListControllerTableViewController(Test)
- (void)setUpBranchName:(BranchDetailsTableViewCell *)cell onRow:(NSInteger)row;
- (void)setUpBranchDetails:(BranchDetailsTableViewCell *)cell onRow:(NSInteger) row;
@property (nonatomic) NSMutableArray *branchDetails;

@property (nonatomic, copy) NSString *bankName;
@property (nonatomic) NSArray *branchList;
@property (nonatomic) NSArray *districtBanksList;
@property (nonatomic) NSMutableArray *expandedCells;
@property (nonatomic) UIActivityIndicatorView *activityIndicator;
@end

@interface BankBranchListControllerTableViewControllerTest : XCTestCase
@property (nonatomic) BankBranchListControllerTableViewController *vcToTest;
@property (nonatomic) BranchDetailsTableViewCell *testCell;
@property (nonatomic) NSArray *bankArray;
@end

@implementation BankBranchListControllerTableViewControllerTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.bankArray = @[@"Test Bank", @"Super Bank", @"World Bank"];
    NSString *testCellId = @"testCell";
    self.vcToTest = [[BankBranchListControllerTableViewController alloc] initWithBank:@"Test Bank" andBanksList:self.bankArray];
    
    self.vcToTest.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 150, 50) style:UITableViewStylePlain];
    
    [self.vcToTest.tableView registerNib:[UINib nibWithNibName:@"BranchDetailsTableViewCell" bundle:nil] forCellReuseIdentifier:testCellId];
    self.testCell = [self.vcToTest.tableView dequeueReusableCellWithIdentifier:testCellId];
    
    BranchDetails *branchDetails1 = [[BranchDetails alloc] init];
    branchDetails1.branchName = @"Branch Name 1";
    branchDetails1.addressDetails = @"Address Details 1";
    branchDetails1.contactDetails = @"Contact Details 1";
    branchDetails1.IFSCCode = @"IFSC Code 1";
    branchDetails1.MICRCode = @"MICR Code 1";
    
    BranchDetails *branchDetails2 = [[BranchDetails alloc] init];
    branchDetails2.branchName = @"Branch Name 2";
    branchDetails2.addressDetails = @"Address Details 2";
    branchDetails2.contactDetails = @"Contact Details 2";
    branchDetails2.IFSCCode = @"IFSC Code 2";
    branchDetails2.MICRCode = @"MICR Code 2";
    
    self.vcToTest.branchDetails = [@[branchDetails1, branchDetails2] mutableCopy];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInit {
    XCTAssertEqualObjects(@"Test Bank", self.vcToTest.bankName, @"The bank name did not match the expected bank name");
    XCTAssertEqual(self.bankArray, self.vcToTest.districtBanksList, @"The district banks list did not match the expected banks list");
    XCTAssertNotNil(self.vcToTest.expandedCells);
    XCTAssertNotNil(self.vcToTest.branchDetails);
    XCTAssertNotNil(self.vcToTest.activityIndicator);
}

- (void)testNumberOfSectionsInTableView {
    NSInteger numberOfSections = [self.vcToTest numberOfSectionsInTableView:self.vcToTest.tableView];
    XCTAssertEqual(1, numberOfSections, @"The number of sections should match");
}

- (void)testNumberOfRowsInSection {
    self.vcToTest.branchList = @[@"BranchA", @"BranchB", @"BranchC"];
    NSInteger numberOfRows = [self.vcToTest tableView:self.vcToTest.tableView numberOfRowsInSection:0];
    XCTAssertEqual(3, numberOfRows, @"The number of rows should match");
}

- (void)testTableViewWillDisplayCell {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    
    id mockController = [OCMockObject partialMockForObject:self.vcToTest];
    [[mockController expect] setUpBranchName:self.testCell onRow:[indexPath row]];
    [[mockController expect] setUpBranchDetails:self.testCell onRow:[indexPath row]];
    
    [self.vcToTest tableView:self.vcToTest.tableView willDisplayCell:self.testCell forRowAtIndexPath:indexPath];
    
    [mockController verify];
}

- (void)testSetUpBranchName {
    
    id mockCellBranchName = [OCMockObject partialMockForObject:self.testCell.branchName];
    [[mockCellBranchName expect] sizeToFit];
    
    [self.vcToTest setUpBranchName:self.testCell onRow:1];
    XCTAssert(self.testCell.branchName.lineBreakMode == NSLineBreakByWordWrapping);
    XCTAssert(self.testCell.branchName.numberOfLines == 0);
    XCTAssertEqualObjects(@"Branch Name 2", self.testCell.branchName.text, @"The branch name did not match the expected branch name");
    
    [mockCellBranchName verify];
}

- (void)testSetUpBranchDetails {
    
    id mockCellAddressDetails = [OCMockObject partialMockForObject:self.testCell.addressDetails];
    [[mockCellAddressDetails expect] sizeToFit];
    
    id mockCellContactDetails = [OCMockObject partialMockForObject:self.testCell.contactDetails];
    [[mockCellContactDetails expect] sizeToFit];
    
    [self.vcToTest setUpBranchDetails:self.testCell onRow:0];
    XCTAssert(self.testCell.addressDetails.lineBreakMode == NSLineBreakByWordWrapping);
    XCTAssert(self.testCell.addressDetails.numberOfLines == 0);
    XCTAssertEqualObjects(@"Address Details 1", self.testCell.addressDetails.text, @"The address details did not match the expected address details");
    
    [mockCellAddressDetails verify];
    
    XCTAssert(self.testCell.contactDetails.lineBreakMode == NSLineBreakByWordWrapping);
    XCTAssert(self.testCell.contactDetails.numberOfLines == 0);
    XCTAssertEqualObjects(@"Contact Details 1", self.testCell.contactDetails.text, @"The contact details did not match the expected contact details");
    
    [mockCellContactDetails verify];
    
    XCTAssertEqualObjects(@"IFSC Code 1", self.testCell.IFSCCode.text, @"The IFSC code did not match the expected IFSC code");
    
    XCTAssertEqualObjects(@"MICR Code 1", self.testCell.MICRCode.text, @"The MICR code did not match the expected MICR code");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}



@end
