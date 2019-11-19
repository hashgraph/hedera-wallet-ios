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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIView (NSLayoutConstraintsUtility)

// Add view to receiver's child view and add necessory constraints to make horizontal, vertical, top and bottom space = 0
-(void)addContentView:(UIView *)view;

-(void)addContentView:(UIView *)view inset:(UIEdgeInsets)inset;

// set constraint and force layout
-(void)setConstraintEquivalentToFrame:(CGRect)frame;

// for animations use forceLayout = NO and layout manually in animation block
-(void)setConstraintEquivalentToFrame:(CGRect)frame forceLayout:(BOOL)forceLayout;

-(NSLayoutConstraint *)widthConstraint;
-(NSLayoutConstraint *)heightConstraint;

@end
