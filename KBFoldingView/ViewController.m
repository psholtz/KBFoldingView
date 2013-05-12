//
//  ViewController.m
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

#import "ViewController.h"

#import "UIView+Folding.h"

static const NSString *kbFoldLabel      = @"Folds: %d";
static const NSString *kbDurationLabel  = @"Duration: %@";

@interface ViewController ()

@property (nonatomic, strong) NSNumberFormatter *fmt;

// Update the Data Model
- (void)updateDirectionValue:(NSUInteger)value;
- (void)updateFoldValue:(CGFloat)value;
- (void)updateDurationValue:(CGFloat)value;

// Helper Methods for UI
- (void)foldValueChanged:(id)sender;
- (void)durationValueChanged:(id)sender;

@end

@implementation ViewController
#pragma mark -
#pragma mark View Lifecycle
//
// View Lifecycle
//
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.fmt = [[NSNumberFormatter alloc] init];
    [self.fmt setNumberStyle:NSNumberFormatterDecimalStyle];
    [self.fmt setMaximumFractionDigits:1];
    [self.fmt setMinimumFractionDigits:1];
    
    [self.foldControl sendActionsForControlEvents:UIControlEventValueChanged];
    [self.durationControl sendActionsForControlEvents:UIControlEventTouchDragInside];
    
    [self.foldControl addTarget:self action:@selector(foldValueChanged:) forControlEvents:UIControlEventTouchDragInside];
    [self.durationControl addTarget:self action:@selector(durationValueChanged:) forControlEvents:UIControlEventTouchDragInside];
    
    self.endLabel.alpha = 0.0f;
    self.endButton.alpha = 0.0f;
    
    _direction = self.directionControl.selectedSegmentIndex;
    _folds = (int)self.foldControl.value;
    _duration = self.durationControl.value;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.startView = nil;
    self.endView = nil;
}

- (void)didReceiveMemoryWarning {
    self.endView = nil;
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark IBAction Methods
//
// IBAction Methods
//
- (IBAction)pressStartButton:(id)sender {
    // Optional completion block
    void (^completion)(BOOL) = ^(BOOL finished){
        if ( finished ) {
            [UIView animateWithDuration:0.3f
                             animations:^(void) {
                                 self.endLabel.alpha = 1.0f;
                                 self.endButton.alpha = 1.0f;
                             }];
        }
    };
    
    // Run the animation
    [self.startView showFoldingView:self.endView
                              folds:self.folds
                          direction:self.direction
                           duration:self.duration 
                       onCompletion:completion];
}

- (IBAction)pressEndButton:(id)sender {
    // Optional completion block
    void (^completion)(BOOL) = ^(BOOL finished) {
        self.endLabel.alpha = 0.0f;
        self.endButton.alpha = 0.0f;
    };
    
    // Run the animation
    [self.startView hideFoldingView:self.endView
                              folds:self.folds
                          direction:self.direction
                           duration:self.duration
                       onCompletion:completion];
}

- (IBAction)pressReset:(id)sender {
    [self updateDirectionValue:kbDefaultDirection];
    [self updateFoldValue:kbDefaultFolds];
    [self updateDurationValue:kbDefaultDuration];
}

- (IBAction)updateDirectionControl:(id)sender {
    _direction = self.directionControl.selectedSegmentIndex;
}

- (IBAction)updateFoldControl:(id)sender {
    UISlider *slider = (UISlider*)sender;
    [self updateFoldValue:slider.value];
}

- (IBAction)updateFoldStepper:(id)sender {
    UIStepper *stepper = (UIStepper*)sender;
    [self updateFoldValue:stepper.value];
}

- (IBAction)updateDurationControl:(id)sender {
    UISlider *slider = (UISlider*)sender;
    [self updateDurationValue:slider.value];
}

- (IBAction)updateDurationStepper:(id)sender {
    UIStepper *stepper = (UIStepper*)sender;
    [self updateDurationValue:stepper.value];
}

#pragma mark -
#pragma mark Data Model
//
// Data Model
//
- (void)updateDirectionValue:(NSUInteger)value {
    [self.directionControl setSelectedSegmentIndex:value];
    _direction = self.directionControl.selectedSegmentIndex;
}

- (void)updateFoldValue:(CGFloat)value {
    CGFloat fValue = round(value);
    [self.foldControl setValue:fValue animated:YES];
    [self.foldStepper setValue:fValue];
    [self.foldLabel setText:[NSString stringWithFormat:(NSString*)kbFoldLabel, (int)(fValue)]];
    
    _folds = (int)fValue;
}

- (void)updateDurationValue:(CGFloat)value {
    [self.durationControl setValue:value animated:YES];
    [self.durationStepper setValue:value];
    [self.durationLabel setText:[NSString stringWithFormat:(NSString*)kbDurationLabel, [self.fmt stringFromNumber:[NSNumber numberWithFloat:value]]]];

    _duration = value;
}

#pragma mark -
#pragma mark Helper Methods to Update Labels in Realtime
//
// Helper UI Methods
//
- (void)foldValueChanged:(id)sender {
    self.foldLabel.text = [NSString stringWithFormat:(NSString*)kbFoldLabel, (int)(round(self.foldControl.value))];
}

- (void)durationValueChanged:(id)sender {
    NSNumber * fValue = [NSNumber numberWithFloat:self.durationControl.value];
    NSString * sValue = [NSString stringWithFormat:@"%@", [self.fmt stringFromNumber:fValue]];
    self.durationLabel.text = [NSString stringWithFormat:(NSString*)kbDurationLabel, sValue];
}

@end
