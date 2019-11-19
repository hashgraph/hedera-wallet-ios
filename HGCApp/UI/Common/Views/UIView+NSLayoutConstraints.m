//
//  Copyright 2019 Hedera Hashgraph LLC
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "UIView+NSLayoutConstraints.h"

@implementation UIView (NSLayoutConstraintsUtility)

-(void)addContentView:(UIView *)view{
    [self addContentView:view inset:UIEdgeInsetsMake(0, 0, 0, 0)];
}

-(void)addContentView:(UIView *)view inset:(UIEdgeInsets)inset{
    
    [self addSubview:view];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-(%.2f)-[view]-(%.2f)-|",inset.left,inset.right]
                          options:0
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(view)]];
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-(%.2f)-[view]-(%.2f)-|",inset.top,inset.bottom]
                          options:0
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(view)]];
}

-(void)setConstraintEquivalentToFrame:(CGRect)frame forceLayout:(BOOL)forceLayout{
    if (!self.superview) return;
    
    if (isnan(frame.origin.x) || frame.origin.x == INFINITY)
        frame.origin.x = 0;
    if (isnan(frame.origin.y) || frame.origin.y == INFINITY)
        frame.origin.y = 0;
    if (isnan(frame.size.width) || frame.size.width == INFINITY)
        frame.size.width = 0;
    if (isnan(frame.size.height) || frame.size.height == INFINITY)
        frame.size.height = 0;
    
    UIView *superView = self.superview;
    NSMutableArray *superConstraints = [NSMutableArray array];
    for (NSLayoutConstraint *constraint in superView.constraints) {
        if (constraint.firstItem == self || constraint.secondItem == self) {
            [superConstraints addObject:constraint];
        }
    }
    
    [superView removeConstraints:superConstraints];
    
    NSMutableArray *selfConstraints = [NSMutableArray array];
    for (NSLayoutConstraint *constraint in self.constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeWidth || constraint.secondAttribute == NSLayoutAttributeWidth || constraint.firstAttribute == NSLayoutAttributeHeight || constraint.secondAttribute == NSLayoutAttributeHeight) {
            [selfConstraints addObject:constraint];
        }
    }
    
    [superView removeConstraints:superConstraints];
    [self removeConstraints:selfConstraints];
    
    UIView *view = self;
    [superView addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-(%.2f)-[view]",frame.origin.x]
                               options:0
                               metrics:nil
                               views:NSDictionaryOfVariableBindings(view)]];
    [superView addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-(%.2f)-[view]",frame.origin.y]
                               options:0
                               metrics:nil
                               views:NSDictionaryOfVariableBindings(view)]];
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:[NSString stringWithFormat:@"V:[view(==%.2f)]",frame.size.height]
                          options:0
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(view)]];
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:[NSString stringWithFormat:@"H:[view(==%.2f)]",frame.size.width]
                          options:0
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(view)]];
    if (forceLayout) {
        [superView setNeedsLayout];
        [superView layoutIfNeeded];
    }
}

-(void)setConstraintEquivalentToFrame:(CGRect)frame{
    [self setConstraintEquivalentToFrame:frame forceLayout:YES];
}

-(NSLayoutConstraint *)widthConstraint{
    for (NSLayoutConstraint *constraint in self.constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeWidth || constraint.secondAttribute == NSLayoutAttributeWidth) {
            return constraint;
        }
    }
    return nil;
}

-(NSLayoutConstraint *)heightConstraint{
    for (NSLayoutConstraint *constraint in self.constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeHeight || constraint.secondAttribute == NSLayoutAttributeHeight) {
            return constraint;
        }
    }
    return nil;
}

@end
