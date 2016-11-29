//
//  UIActivityIndicatorView+Additions.m
//  BankIFSCDetails
//
//  Created by Mansi Barodia on 11/12/16.
//  Copyright © 2016 Mansi Barodia. All rights reserved.
//

#import "UIActivityIndicatorView+Additions.h"
#import <objc/runtime.h>

static void *OverlayViewKey = &OverlayViewKey;

@implementation UIActivityIndicatorView(Additions)

- (UIView *)overlayView {
    return objc_getAssociatedObject(self, OverlayViewKey);
}

- (void)setOverlayView:(UIView *)overlayView {
    objc_setAssociatedObject(self, OverlayViewKey, overlayView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)showActivityIndicatorForView:(UIView *)view {
    self.overlayView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.overlayView.frame = view.bounds;
    self.overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleHeight;
    self.center = self.overlayView.center;
    [self startAnimating];
    [self.overlayView addSubview:self];
    [view addSubview:self.overlayView];
    [view bringSubviewToFront:self.overlayView];
    self.hidesWhenStopped = YES;
    self.hidden = NO;
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [self.overlayView setUserInteractionEnabled:NO];
}

- (void)hideActivityIndicatorForView:(UIView *)view {
    [self stopAnimating];
    [self.overlayView setUserInteractionEnabled:YES];
    [self.overlayView removeFromSuperview];
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
}
@end
