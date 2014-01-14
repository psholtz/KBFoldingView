//
//  ViewController.h
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

#import "SimpleHeaders.h"

@interface ViewController : UIViewController

// Control Views
@property (nonatomic, KB_WEAK) IBOutlet UISegmentedControl * directionControl;
@property (nonatomic, KB_WEAK) IBOutlet UISlider * foldControl;
@property (nonatomic, KB_WEAK) IBOutlet UISlider * durationControl;
@property (nonatomic, KB_WEAK) IBOutlet UIStepper * foldStepper;
@property (nonatomic, KB_WEAK) IBOutlet UIStepper * durationStepper;
@property (nonatomic, KB_WEAK) IBOutlet UILabel * transitionLabel;
@property (nonatomic, KB_WEAK) IBOutlet UILabel * foldLabel;
@property (nonatomic, KB_WEAK) IBOutlet UILabel * durationLabel;
@property (nonatomic, KB_WEAK) IBOutlet UILabel * resetLabel;
@property (nonatomic, KB_WEAK) IBOutlet UILabel * endLabel;
@property (nonatomic, KB_WEAK) IBOutlet UIButton * transitionButton;
@property (nonatomic, KB_WEAK) IBOutlet UIButton * resetButton;
@property (nonatomic, KB_WEAK) IBOutlet UIButton * endButton;

// Folding Views 
@property (nonatomic, KB_WEAK) IBOutlet UIView *startView;
@property (nonatomic, strong) IBOutlet UIView *endView; 

// Data Properties
@property (nonatomic, readonly) NSUInteger direction;
@property (nonatomic, readonly) NSUInteger folds;
@property (nonatomic, readonly) CGFloat duration;

#pragma mark -
#pragma mark IBAction Methods
- (IBAction)pressStartButton:(id)sender;
- (IBAction)pressEndButton:(id)sender;
- (IBAction)pressReset:(id)sender;

- (IBAction)updateDirectionControl:(id)sender;
- (IBAction)updateFoldControl:(id)sender;
- (IBAction)updateFoldStepper:(id)sender;
- (IBAction)updateDurationControl:(id)sender;
- (IBAction)updateDurationStepper:(id)sender;

@end
