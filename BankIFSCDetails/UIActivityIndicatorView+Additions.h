//
//  UIActivityIndicatorView+Additions.h
//  BankIFSCDetails
//
//  Created by Mansi Barodia on 11/12/16.
//  Copyright © 2016 Mansi Barodia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIActivityIndicatorView(Additions)
@property (nonatomic, strong) UIView *overlayView;

- (void)showActivityIndicatorForView:(UIView *)view;
- (void)hideActivityIndicatorForView:(UIView *)view;
@end
