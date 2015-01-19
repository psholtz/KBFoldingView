//
//  UIView+Folding.m
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

#import "UIView+Folding.h"

static NSUInteger _KBTransitionState = KBFoldingTransitionStateIdle;

KeyframeParametrizedBlock kbOpenFunction = ^double(NSTimeInterval time) {
    return sin(time * M_PI_2);
};

KeyframeParametrizedBlock kbCloseFunction = ^double(NSTimeInterval time) {
    return -cos(time * M_PI_2) + 1.0f;
};

#pragma mark -
#pragma mark Implementation (Parametrized Keyframe Animation)
@implementation CAKeyframeAnimation (Parametrized)
//
// Private Interface
//
+ (id)parametrizedAnimationWithKeyPath:(NSString*)path
                              function:(KeyframeParametrizedBlock)function
                             fromValue:(CGFloat)fromValue
                               toValue:(CGFloat)toValue
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:path];
    NSUInteger steps = 100;
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:steps];
    double time = 0.0f;
    double timeStep = 1.0 / (double)(steps - 1);
    for ( NSUInteger i = 0; i < steps; ++i ) {
        double value = fromValue + (function(time) * (toValue - fromValue));
        [values addObject:[NSNumber numberWithDouble:value]];
        time += timeStep;
    }
    animation.calculationMode = kCAAnimationLinear;
    [animation setValues:values];
    return animation;
}

@end

#pragma mark -
#pragma mark Private Interface (UIView)
@interface UIView (FoldingPrivate)

- (BOOL)validateDuration:(NSTimeInterval)duration direction:(NSUInteger)direction folds:(NSUInteger)folds;

@end

#pragma mark -
#pragma mark Implementation (Folding Category on UIView)
@implementation UIView (Folding)
- (NSUInteger)state {
    return _KBTransitionState;
}

+ (CATransformLayer*)transformLayerfromImage:(UIImage*)image
                                       frame:(CGRect)frame
                                    duration:(NSTimeInterval)duration
                                 anchorPoint:(CGPoint)anchorPoint
                                  startAngle:(CGFloat)startAngle
                                    endAngle:(CGFloat)endAngle   
{
    CATransformLayer *jointLayer = [CATransformLayer layer];
    jointLayer.anchorPoint = anchorPoint;
    CALayer *imageLayer = [CALayer layer];
    CAGradientLayer *shadowLayer = [CAGradientLayer layer];
    double shadowAniOpacity = 0.0f;
    
    if ( anchorPoint.y == 0.5f )
    {
        CGFloat layerWidth = 0.0f;
        if ( anchorPoint.x == 0.0f ) {
            layerWidth = image.size.width - frame.origin.x;
            jointLayer.frame = CGRectMake(0.0f, 0.0f, layerWidth, frame.size.height);
            if ( frame.origin.x ) {
                jointLayer.position = CGPointMake(frame.size.width, frame.size.height/2.0f);
            } else {
                jointLayer.position = CGPointMake(0.0f, frame.size.height/2.0f);
            }
        } else {
            layerWidth = frame.origin.x + frame.size.width;
            jointLayer.frame = CGRectMake(0.0f, 0.0f, layerWidth, frame.size.height);
            jointLayer.position = CGPointMake(layerWidth, frame.size.height/2.0f);
        }
        
        // Map the image onto the transform layer
        imageLayer.frame = CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height);
        imageLayer.anchorPoint = anchorPoint;
        imageLayer.position = CGPointMake(layerWidth * anchorPoint.x, frame.size.height/2.0f);
        [jointLayer addSublayer:imageLayer];
        
        CGImageRef imageCrop = CGImageCreateWithImageInRect(image.CGImage, frame);
        imageLayer.contents = (__bridge id)imageCrop;
        imageLayer.backgroundColor = [UIColor clearColor].CGColor;
        
        // Add drop shadow
        NSInteger index = frame.origin.x / frame.size.width;
        shadowLayer.frame = imageLayer.bounds;
        shadowLayer.backgroundColor = [UIColor darkGrayColor].CGColor;
        shadowLayer.opacity = 0.0f;
        shadowLayer.colors = [NSArray arrayWithObjects:
                                (id)[UIColor blackColor].CGColor,
                                (id)[UIColor clearColor].CGColor,
                               nil];
        if ( index % 2 != 0.0f )  {
            shadowLayer.startPoint = CGPointMake(0.0f, 0.5f);
            shadowLayer.endPoint = CGPointMake(1.0f, 0.5f);
            shadowAniOpacity = (anchorPoint.x != 0.0f) ? 0.24f : 0.32f;
        } else {
            shadowLayer.startPoint = CGPointMake(1.0f, 0.5f);
            shadowLayer.endPoint = CGPointMake(0.0f, 0.5f);
            shadowAniOpacity = (anchorPoint.x != 0.0f) ? 0.32f : 0.24f;
        }
        [imageLayer addSublayer:shadowLayer];
        
        // Release the image reference
        CGImageRelease(imageCrop);
    }
    else
    {
        CGFloat layerHeight;
        if ( anchorPoint.y == 0.0f ) {
            layerHeight = image.size.height - frame.origin.y;
            jointLayer.frame = CGRectMake(0.0f, 0.0f, frame.size.width, layerHeight);
            if ( frame.origin.y ) {
                jointLayer.position = CGPointMake(frame.size.width/2.0f, frame.size.height);
            } else {
                jointLayer.position = CGPointMake(frame.size.width/2.0f, 0.0f);
            }
        } else {
            layerHeight = frame.origin.y + frame.size.height;
            jointLayer.frame = CGRectMake(0.0f, 0.0f, frame.size.width, layerHeight);
            jointLayer.position = CGPointMake(frame.size.width/2.0f, layerHeight);
        }
        
        // Map the image onto the transform layer
        imageLayer.frame = CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height);
        imageLayer.anchorPoint = anchorPoint;
        imageLayer.position = CGPointMake(frame.size.width/2.0f, layerHeight * anchorPoint.y);
        [jointLayer addSublayer:imageLayer];
        
        CGImageRef imageCrop = CGImageCreateWithImageInRect(image.CGImage, frame);
        imageLayer.contents = (__bridge id)imageCrop;
        imageLayer.backgroundColor = [UIColor clearColor].CGColor;
        
        // Add a drop-shadow layer
        NSInteger index = frame.origin.y / frame.size.height;
        shadowLayer.frame = imageLayer.bounds;
        shadowLayer.backgroundColor = [UIColor darkGrayColor].CGColor;
        shadowLayer.opacity = 0.0f;
        shadowLayer.colors = [NSArray arrayWithObjects:
                              (id)[UIColor blackColor].CGColor,
                              (id)[UIColor clearColor].CGColor,
                              nil];
        if ( index % 2 != 0.0f ) {
            shadowLayer.startPoint = CGPointMake(0.05f, 0.0f);
            shadowLayer.endPoint = CGPointMake(0.5f, 1.0f);
            shadowAniOpacity = (anchorPoint.x != 0.0f) ? 0.24f : 0.32f;
        } else {
            shadowLayer.startPoint = CGPointMake(0.5f, 1.0f);
            shadowLayer.endPoint = CGPointMake(0.5f, 0.0f);
            shadowAniOpacity = (anchorPoint.x != 0.0f) ? 0.32f : 0.24f;
         }
        
        [imageLayer addSublayer:shadowLayer];
        
        // Release the image reference
        CGImageRelease(imageCrop);
    }

    // Configure the open/close animation
    CABasicAnimation *animation = (anchorPoint.y == 0.5) ?
                                    [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"] :
                                    [CABasicAnimation animationWithKeyPath:@"transform.rotation.x"];
    [animation setDuration:duration];
    [animation setFromValue:[NSNumber numberWithDouble:startAngle]];
    [animation setToValue:[NSNumber numberWithDouble:endAngle]];
    [animation setRemovedOnCompletion:NO];
    [jointLayer addAnimation:animation forKey:@"jointAnimation"];
    
    // Configure the shadow opacity
    animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [animation setDuration:duration];
    [animation setFromValue:[NSNumber numberWithDouble:(startAngle != 0.0f) ? shadowAniOpacity : 0.0f]];
    [animation setToValue:[NSNumber numberWithDouble:(startAngle != 0.0f) ? 0.0f : shadowAniOpacity]];
    [shadowLayer addAnimation:animation forKey:nil];
    
    return jointLayer;
}

#pragma mark -
#pragma mark Show Methods
//
// SHOW METHODS
//
- (void)showFoldingView:(UIView*)view {
    [self showFoldingView:view
                    folds:kbDefaultFolds
                direction:kbDefaultDuration
                 duration:kbDefaultDirection
             onCompletion:NULL];
}

- (void)showFoldingView:(UIView*)view
                  folds:(NSUInteger)folds
              direction:(NSUInteger)direction
               duration:(NSTimeInterval)duration
           onCompletion:(void (^)(BOOL finished))onCompletion
{
    //
    // Guard the Method Invocation
    //
#ifdef kbFoldingViewUseBoundsChecking
    if ( ![self validateDuration:duration direction:direction folds:folds] ) {
        return;
    }
#endif
    
    if ( self.state != KBFoldingTransitionStateIdle ) {
        return;
    }
    _KBTransitionState = KBFoldingTransitionStateUpdate;
    
    //
    // Configure the target subview
    //
    if ( [view superview] != nil ) {
        [view removeFromSuperview];
    }
    [[self superview] insertSubview:view belowSubview:self];
    
    //
    // Configure the target frame
    //
    CGRect finalFrame = self.frame;
    CGPoint anchorPoint = CGPointZero;
    switch ( direction ) {
        case KBFoldingViewDirectionFromRight:
            finalFrame.origin.x = self.frame.origin.x - view.bounds.size.width;
            view.frame = CGRectMake(self.frame.origin.x + self.frame.size.width - view.frame.size.width, self.frame.origin.y, view.frame.size.width, view.frame.size.height);
            anchorPoint = CGPointMake(1.0f, 0.5f);
            break;
            
        case KBFoldingViewDirectionFromLeft:
            finalFrame.origin.x = self.frame.origin.x + view.bounds.size.width;
            view.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, view.frame.size.width, view.frame.size.height);
            anchorPoint = CGPointMake(0.0f, 0.5f);
            break;
            
        case KBFoldingViewDirectionFromTop:
            finalFrame.origin.y = self.frame.origin.y + view.bounds.size.height;
            view.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, view.frame.size.width, view.frame.size.height);
            anchorPoint = CGPointMake(0.5f, 0.0f);
            break;
            
        case KBFoldingViewDirectionFromBottom:
            finalFrame.origin.y = self.frame.origin.y - view.bounds.size.height;
            view.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.frame.size.height - view.frame.size.height, view.frame.size.width, view.frame.size.height);
            anchorPoint = CGPointMake(0.5f, 1.0f);
            break;
    }
    
    //
    // Grab the snapshot of the image
    //
    UIGraphicsBeginImageContext(view.frame.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewSnapShot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsGetCurrentContext();

    //
    // Set 3D Depth
    //
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -1.0f/800.0f;
    CALayer *foldingLayer = [CALayer layer];
    foldingLayer.frame = view.bounds;
    foldingLayer.backgroundColor = [UIColor colorWithWhite:0.2f alpha:1.0f].CGColor;
    foldingLayer.sublayerTransform = transform;
    [view.layer addSublayer:foldingLayer];
    
    //
    // Set up rotating angle
    //
    double startAngle = 0.0f;
    CALayer * prevLayer = foldingLayer;
    CGFloat frameWidth = view.bounds.size.width;
    CGFloat frameHeight = view.bounds.size.height;
    CGFloat foldWidth = 0.0f;
    CGRect imageFrame = CGRectZero;
    switch ( direction ) {
        case KBFoldingViewDirectionFromRight:
            foldWidth = frameWidth/(folds * 2.0f);
            for ( int b=0; b < 2 * folds; ++b ) {
                if ( b == 0 )       { startAngle = -M_PI_2; }
                else if ( b%2 )     { startAngle = M_PI; }
                else                { startAngle = -M_PI; }
                imageFrame = CGRectMake(frameWidth - (b+1) * foldWidth, 0, foldWidth, frameHeight);
                
                CATransformLayer *transLayer = [UIView transformLayerfromImage:viewSnapShot
                                                                         frame:imageFrame
                                                                      duration:duration
                                                                   anchorPoint:anchorPoint
                                                                    startAngle:startAngle
                                                                      endAngle:0];
                [prevLayer addSublayer:transLayer];
                prevLayer = transLayer;
            }
            break;
            
        case KBFoldingViewDirectionFromLeft:
            foldWidth = frameWidth/(folds * 2.0f);
            for ( int b=0; b < 2 * folds; ++b ) {
                if ( b == 0 )       { startAngle = M_PI_2; }
                else if ( b%2 )     { startAngle = -M_PI; }
                else                { startAngle = M_PI; }
                imageFrame = CGRectMake(b * foldWidth, 0, foldWidth, frameHeight);
                
                CATransformLayer *transLayer = [UIView transformLayerfromImage:viewSnapShot
                                                                         frame:imageFrame
                                                                      duration:duration
                                                                   anchorPoint:anchorPoint
                                                                    startAngle:startAngle
                                                                      endAngle:0];
                [prevLayer addSublayer:transLayer];
                prevLayer = transLayer;
            }
            break;
            
        case KBFoldingViewDirectionFromTop:
            foldWidth = frameHeight/(folds * 2.0f);
            for ( int b=0; b < 2 * folds; ++b ) {
                if ( b == 0 )       { startAngle = -M_PI_2; }
                else if ( b%2 )     { startAngle = M_PI; }
                else                { startAngle = -M_PI; }
                imageFrame = CGRectMake(0, b * foldWidth, frameWidth, foldWidth);
                
                CATransformLayer *transLayer = [UIView transformLayerfromImage:viewSnapShot
                                                                         frame:imageFrame
                                                                      duration:duration
                                                                   anchorPoint:anchorPoint
                                                                    startAngle:startAngle
                                                                      endAngle:0];
                [prevLayer addSublayer:transLayer];
                prevLayer = transLayer;
            }
            break;
            
        case KBFoldingViewDirectionFromBottom:
            foldWidth = frameHeight/(folds * 2.0f);
            for ( int b=0; b < 2 * folds; ++b ) {
                if ( b == 0 )       { startAngle = M_PI_2; }
                else if ( b%2 )     { startAngle = -M_PI; }
                else                { startAngle = M_PI; }
                imageFrame = CGRectMake(0, frameHeight - (b+1) * foldWidth, frameWidth, foldWidth);
                
                CATransformLayer *transLayer = [UIView transformLayerfromImage:viewSnapShot
                                                                         frame:imageFrame
                                                                      duration:duration
                                                                   anchorPoint:anchorPoint
                                                                    startAngle:startAngle
                                                                      endAngle:0];
                [prevLayer addSublayer:transLayer];
                prevLayer = transLayer;
            }
            break;
    }
    
    //
    // Construct and Commit the Open Animation
    //
    __weak typeof(self) _weakSelf = self;
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        __strong typeof(self) _strongSelf = _weakSelf;
        if ( _strongSelf ) {
            _strongSelf.frame = finalFrame;
            [foldingLayer removeFromSuperlayer];
        
            // Reset the transition state
            _KBTransitionState = KBFoldingTransitionStateShowing;
            if ( onCompletion ) {
                onCompletion(YES);
            }
        }
    }];
    
    [CATransaction setValue:[NSNumber numberWithFloat:duration] forKey:kCATransactionAnimationDuration];
    
    CAAnimation *openAnimation = nil;
    switch ( direction ) {
        case KBFoldingViewDirectionFromRight:
        case KBFoldingViewDirectionFromLeft:
            openAnimation = [CAKeyframeAnimation parametrizedAnimationWithKeyPath:@"position.x"
                                                                         function:kbOpenFunction
                                                                        fromValue:(self.frame.origin.x + self.frame.size.width/2.0f)
                                                                          toValue:(finalFrame.origin.x + self.frame.size.width/2.0f)];
            break;
            
        case KBFoldingViewDirectionFromTop:
        case KBFoldingViewDirectionFromBottom:
            openAnimation = [CAKeyframeAnimation parametrizedAnimationWithKeyPath:@"position.y"
                                                                         function:kbOpenFunction
                                                                        fromValue:(self.frame.origin.y + self.frame.size.height/2.0f)
                                                                          toValue:(finalFrame.origin.y + self.frame.size.height/2.0f)];
            break;
    }
    openAnimation.fillMode = kCAFillModeForwards;
    openAnimation.removedOnCompletion = NO;
    [self.layer addAnimation:openAnimation forKey:@"position"];
    
    [CATransaction commit];
}

#pragma mark -
#pragma mark Hide Methods
//
// HIDE METHODS
//
- (void)hideFoldingView:(UIView*)view {
    [self hideFoldingView:view
                    folds:kbDefaultFolds
                direction:kbDefaultDuration
                 duration:kbDefaultDirection
             onCompletion:NULL];
}

- (void)hideFoldingView:(UIView*)view
                  folds:(NSUInteger)folds
              direction:(NSUInteger)direction
               duration:(NSTimeInterval)duration
           onCompletion:(void (^)(BOOL finished))onCompletion
{
    //
    // Guard the Method Invocation
    //
#ifdef kbFoldingViewUseBoundsChecking
    if ( ![self validateDuration:duration direction:direction folds:folds] ) {
        return;
    }
#endif
    
    if ( self.state != KBFoldingTransitionStateShowing ) {
        return;
    }
    _KBTransitionState = KBFoldingTransitionStateUpdate;
    
    //
    // Configure the Target Frame
    //
    CGRect finalFrame = self.frame;
    CGPoint anchorPoint = CGPointZero;
    switch ( direction ) {
        case KBFoldingViewDirectionFromRight:
            finalFrame.origin.x = self.frame.origin.x + view.bounds.size.width;
            anchorPoint = CGPointMake(1.0f, 0.5f);
            break;
            
        case KBFoldingViewDirectionFromLeft:
            finalFrame.origin.x = self.frame.origin.x - view.bounds.size.width;
            anchorPoint = CGPointMake(0.0f, 0.5f);
            break;
            
        case KBFoldingViewDirectionFromTop:
            finalFrame.origin.y = self.frame.origin.y - view.bounds.size.height;
            anchorPoint = CGPointMake(0.5f, 0.0f);
            break;
            
        case KBFoldingViewDirectionFromBottom:
            finalFrame.origin.y = self.frame.origin.y + view.bounds.size.height;
            anchorPoint = CGPointMake(0.5f, 1.0f);
            break;
    }
    
    //
    // Capture a snapshot of the image
    //
    UIGraphicsBeginImageContext(view.frame.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewSnapShot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //
    // Configure 3D Path
    //
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -1.0/800.0f;
    CALayer *foldingLayer = [CALayer layer];
    foldingLayer.frame = view.bounds;
    foldingLayer.backgroundColor = [UIColor colorWithWhite:0.2f alpha:1.0f].CGColor;
    foldingLayer.sublayerTransform = transform;
    [view.layer addSublayer:foldingLayer];
    
    //
    // Setup rotation angle
    //
    double endAngle = 0.0f;
    CGFloat foldWidth = 0.0f;
    CGFloat frameWidth = view.bounds.size.width;
    CGFloat frameHeight = view.bounds.size.height;
    CALayer *prevLayer = foldingLayer;
    CGRect imageFrame;
    switch ( direction ) {
        case KBFoldingViewDirectionFromRight:
            foldWidth = frameWidth / (folds * 2.0f);
            for ( int b=0; b < 2 * folds; ++b ) {
                if ( b == 0 )   { endAngle = -M_PI_2; }
                else if ( b%2 ) { endAngle = M_PI; }
                else            { endAngle = -M_PI; }
                imageFrame = CGRectMake(frameWidth - (b+1) * foldWidth, 0.0f, foldWidth, frameHeight);
                
                CATransformLayer *transLayer = [UIView transformLayerfromImage:viewSnapShot
                                                                         frame:imageFrame
                                                                      duration:duration
                                                                   anchorPoint:anchorPoint
                                                                    startAngle:0.0f
                                                                      endAngle:endAngle];
                [prevLayer addSublayer:transLayer];
                prevLayer = transLayer;
            }
            break;
            
        case KBFoldingViewDirectionFromLeft:
            foldWidth = frameWidth / (folds * 2.0f);
            for ( int b=0; b < 2 * folds; ++b ) {
                if ( b == 0 )   { endAngle = M_PI_2; }
                else if ( b%2 ) { endAngle = -M_PI; }
                else            { endAngle = M_PI; }
                imageFrame = CGRectMake(b * foldWidth, 0.0f, foldWidth, frameHeight);
                
                CATransformLayer *transLayer = [UIView transformLayerfromImage:viewSnapShot
                                                                         frame:imageFrame
                                                                      duration:duration
                                                                   anchorPoint:anchorPoint
                                                                    startAngle:0.0f
                                                                      endAngle:endAngle];
                [prevLayer addSublayer:transLayer];
                prevLayer = transLayer;
            }
            break;
            
        case KBFoldingViewDirectionFromTop:
            foldWidth = frameHeight / (folds * 2.0f);
            for ( int b=0; b < 2 * folds; ++b ) {
                if ( b == 0 )   { endAngle = -M_PI_2; }
                else if ( b%2 ) { endAngle = M_PI; }
                else            { endAngle = -M_PI; }
                imageFrame = CGRectMake(0.0f, b * foldWidth, frameWidth, foldWidth);
                
                CATransformLayer *transLayer = [UIView transformLayerfromImage:viewSnapShot
                                                                         frame:imageFrame
                                                                      duration:duration
                                                                   anchorPoint:anchorPoint
                                                                    startAngle:0.0f
                                                                      endAngle:endAngle];
                [prevLayer addSublayer:transLayer];
                prevLayer = transLayer;
            }
            break;
            
        case KBFoldingViewDirectionFromBottom:
            foldWidth = frameHeight / (folds * 2.0f);
            for ( int b=0; b < 2 * folds; ++b ) {
                if ( b == 0 )   { endAngle = M_PI_2; }
                else if ( b%2 ) { endAngle = -M_PI; }
                else            { endAngle = M_PI; }
                imageFrame = CGRectMake(0.0f, frameHeight - (b+1) * foldWidth, frameWidth, foldWidth);
                
                CATransformLayer *transLayer = [UIView transformLayerfromImage:viewSnapShot
                                                                         frame:imageFrame
                                                                      duration:duration
                                                                   anchorPoint:anchorPoint
                                                                    startAngle:0.0f
                                                                      endAngle:endAngle];
                [prevLayer addSublayer:transLayer];
                prevLayer = transLayer;
            }
            break;
    }
    
    //
    // Construct and Commit the Close Animation
    //
    __weak typeof(self) _weakSelf = self;
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        __strong typeof(self) _strongSelf = _weakSelf;
        if ( _strongSelf ) {
            _strongSelf.frame = finalFrame;
            [foldingLayer removeFromSuperlayer];
        
            // Reset the transition state
            _KBTransitionState = KBFoldingTransitionStateIdle;
            if ( onCompletion ) {
                onCompletion(YES);
            }
        }
    }];
    
    [CATransaction setValue:[NSNumber numberWithFloat:duration] forKey:kCATransactionAnimationDuration];
    
    CAAnimation *closeAnimation = nil;
    switch ( direction ) {
        case KBFoldingViewDirectionFromRight:
        case KBFoldingViewDirectionFromLeft:
            closeAnimation = [CAKeyframeAnimation parametrizedAnimationWithKeyPath:@"position.x"
                                                                          function:kbCloseFunction
                                                                         fromValue:(self.frame.origin.x + self.frame.size.width/2.0f)
                                                                           toValue:(finalFrame.origin.x + self.frame.size.width/2.0f)];
            break;
            
        case KBFoldingViewDirectionFromTop:
        case KBFoldingViewDirectionFromBottom:
            closeAnimation = [CAKeyframeAnimation parametrizedAnimationWithKeyPath:@"position.y"
                                                                          function:kbCloseFunction
                                                                         fromValue:(self.frame.origin.y + self.frame.size.height/2.0f)
                                                                           toValue:(finalFrame.origin.y + self.frame.size.height/2.0f)];
            break;
    }
    closeAnimation.fillMode = kCAFillModeForwards;
    closeAnimation.removedOnCompletion = NO;
    [self.layer addAnimation:closeAnimation forKey:@"position"];
    [CATransaction commit];
}

#pragma mark -
#pragma mark Validation Method
- (BOOL)validateDuration:(NSTimeInterval)duration direction:(NSUInteger)direction folds:(NSUInteger)folds; {
    if ( !(direction == KBFoldingViewDirectionFromRight ||
           direction == KBFoldingViewDirectionFromLeft ||
           direction == KBFoldingViewDirectionFromTop ||
           direction == KBFoldingViewDirectionFromBottom) )
    {
        NSLog(@"[KBFoldingView] -- Error -- Invalid direction: %ld", direction);
        return NO;
    }
    
    if ( folds < kbFoldingViewMinFolds || folds > kbFoldingViewMaxFolds ) {
        NSLog(@"[KBFoldingView] -- Error -- Number of folds must be between %d and %d", kbFoldingViewMinFolds, kbFoldingViewMaxFolds);
        return NO;
    }
    
    if ( duration < kbFoldingViewMinDuration || duration > kbFoldingViewMaxDuration ) {
        NSLog(@"[KBFoldingView] -- Error -- Duration must be between %f and %f", kbFoldingViewMinDuration, kbFoldingViewMaxDuration);
        return NO;
    }
    
    return YES;
}

@end
