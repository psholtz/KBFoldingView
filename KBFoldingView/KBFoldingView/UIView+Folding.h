//
//  UIView+Folding.h
//  KBFoldingView
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without restriction,
//  including without limitation the rights to use, copy, modify, merge,
//  publish, distribute, sublicense, and/or sell copies of the Software,
//  and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//  CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//  TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
// 
//  Created by Paul Sholtz on 5/5/13.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef double (^KeyframeParametrizedBlock)(NSTimeInterval);

//
// The following constants can be used in case you think its
// useful to exclude nonsense values from being supplied to the
// category. If you want to use the boundary checking, set the
// kbFoldingViewUseBoundsChecking flag to 1, and configure the
// boundary value as you wish. Otherwise, set it to 0.
//
#define kbFoldingViewUseBoundsChecking  1
#define kbFoldingViewMinFolds           1
#define kbFoldingViewMaxFolds           20
#define kbFoldingViewMinDuration        0.2f
#define kbFoldingViewMaxDuration        10.0f

//
// Default values for constructing a folding view
//
#define kbDefaultDirection  1
#define kbDefaultFolds      3
#define kbDefaultDuration   1.0

#pragma mark -
#pragma mark CAKeyframeAnimation Category
//
// CAKeyframeAnimation Category
//
@interface CAKeyframeAnimation (Parametrized)

+ (id)parametrizedAnimationWithKeyPath:(NSString*)path
                              function:(KeyframeParametrizedBlock)function
                             fromValue:(CGFloat)fromValue
                               toValue:(CGFloat)toValue;

@end

//
// Animation Constants
//
typedef enum {
    KBFoldingViewDirectionFromRight     = 0,
    KBFoldingViewDirectionFromLeft      = 1,
    KBFoldingViewDirectionFromTop       = 2,
    KBFoldingViewDirectionFromBottom    = 3,
} KBFoldingViewDirection;

typedef enum {
    KBFoldingTransitionStateIdle    = 0,
    KBFoldingTransitionStateUpdate  = 1,
    KBFoldingTransitionStateShowing = 2,
} KBFoldingTransitionState;

#pragma mark -
#pragma mark UIView Category
//
// UIView Category
// 
@interface UIView (Folding)

@property (nonatomic, readonly) NSUInteger state;

#pragma mark -
#pragma mark Show Methods
// Fold the view using defaults
- (void)showFoldingView:(UIView*)view;

// Fold the view using specified values
- (void)showFoldingView:(UIView*)view
                  folds:(NSUInteger)folds
              direction:(NSUInteger)direction
               duration:(NSTimeInterval)duration
           onCompletion:(void (^)(BOOL finished))onCompletion;

#pragma mark -
#pragma mark Hide Methods 
// Hide the folds using defaults
- (void)hideFoldingView:(UIView*)view;

// Hide the folds using specified values
- (void)hideFoldingView:(UIView*)view
                  folds:(NSUInteger)folds
              direction:(NSUInteger)direction
               duration:(NSTimeInterval)duration
           onCompletion:(void (^)(BOOL finished))onCompletion;

@end
