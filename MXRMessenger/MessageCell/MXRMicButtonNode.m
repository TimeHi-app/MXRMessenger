//
//  MXRMicButtonNode.m
//  MXRMessenger
//
//  Created by Kiddo Labs on 11/01/18.
//

#import "MXRMicButtonNode.h"

@interface MXRMicButtonNode () <UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIPanGestureRecognizer *panRecognizer;

@property (assign, nonatomic) CGPoint touchLocation;
@property (assign, nonatomic) CGPoint lastVelocity;
@property (assign, nonatomic) BOOL processCurrentTouch;
@property (assign, nonatomic) CFAbsoluteTime lastTouchTime;
@property (assign, nonatomic) CGFloat targetTranslation;

@end

@implementation MXRMicButtonNode
+ (void)drawRect:(CGRect)bounds withParameters:(id<NSObject>)parameters isCancelled:(asdisplaynode_iscancelled_block_t)isCancelledBlock isRasterizing:(BOOL)isRasterizing {
    UIColor* color2 = [UIColor colorWithRed: 0.5 green: 0.5 blue: 0.5 alpha: 1];
    
    {
        {
            UIBezierPath* pathPath = UIBezierPath.bezierPath;
            [pathPath moveToPoint: CGPointMake(7.08, 17.92)];
            [pathPath addLineToPoint: CGPointMake(7.15, 17.92)];
            [pathPath addCurveToPoint: CGPointMake(11.57, 13.47) controlPoint1: CGPointMake(9.59, 17.92) controlPoint2: CGPointMake(11.57, 15.92)];
            [pathPath addLineToPoint: CGPointMake(11.57, 4.93)];
            [pathPath addCurveToPoint: CGPointMake(7.15, 0.48) controlPoint1: CGPointMake(11.57, 2.48) controlPoint2: CGPointMake(9.59, 0.48)];
            [pathPath addLineToPoint: CGPointMake(7.08, 0.48)];
            [pathPath addCurveToPoint: CGPointMake(2.66, 4.93) controlPoint1: CGPointMake(4.64, 0.48) controlPoint2: CGPointMake(2.66, 2.48)];
            [pathPath addCurveToPoint: CGPointMake(3.34, 5.62) controlPoint1: CGPointMake(2.66, 5.31) controlPoint2: CGPointMake(2.96, 5.62)];
            [pathPath addCurveToPoint: CGPointMake(4.01, 4.93) controlPoint1: CGPointMake(3.71, 5.62) controlPoint2: CGPointMake(4.01, 5.31)];
            [pathPath addCurveToPoint: CGPointMake(7.08, 1.85) controlPoint1: CGPointMake(4.01, 3.23) controlPoint2: CGPointMake(5.39, 1.85)];
            [pathPath addLineToPoint: CGPointMake(7.15, 1.85)];
            [pathPath addCurveToPoint: CGPointMake(10.22, 4.93) controlPoint1: CGPointMake(8.84, 1.85) controlPoint2: CGPointMake(10.22, 3.23)];
            [pathPath addLineToPoint: CGPointMake(10.22, 13.47)];
            [pathPath addCurveToPoint: CGPointMake(7.15, 16.55) controlPoint1: CGPointMake(10.22, 15.17) controlPoint2: CGPointMake(8.84, 16.55)];
            [pathPath addLineToPoint: CGPointMake(7.08, 16.55)];
            [pathPath addCurveToPoint: CGPointMake(4.01, 13.47) controlPoint1: CGPointMake(5.39, 16.55) controlPoint2: CGPointMake(4.01, 15.17)];
            [pathPath addLineToPoint: CGPointMake(4.01, 8.61)];
            [pathPath addCurveToPoint: CGPointMake(3.34, 7.93) controlPoint1: CGPointMake(4.01, 8.24) controlPoint2: CGPointMake(3.71, 7.93)];
            [pathPath addCurveToPoint: CGPointMake(2.66, 8.61) controlPoint1: CGPointMake(2.96, 7.93) controlPoint2: CGPointMake(2.66, 8.24)];
            [pathPath addLineToPoint: CGPointMake(2.66, 13.47)];
            [pathPath addCurveToPoint: CGPointMake(7.08, 17.92) controlPoint1: CGPointMake(2.66, 15.92) controlPoint2: CGPointMake(4.64, 17.92)];
            [pathPath closePath];
            pathPath.miterLimit = 4;
            
            pathPath.usesEvenOddFillRule = YES;
            
            [color2 setFill];
            [pathPath fill];
            
            UIBezierPath* path2Path = UIBezierPath.bezierPath;
            [path2Path moveToPoint: CGPointMake(13.72, 13.51)];
            [path2Path addCurveToPoint: CGPointMake(13.04, 14.2) controlPoint1: CGPointMake(13.35, 13.51) controlPoint2: CGPointMake(13.04, 13.82)];
            [path2Path addCurveToPoint: CGPointMake(7.18, 20.1) controlPoint1: CGPointMake(13.04, 17.45) controlPoint2: CGPointMake(10.41, 20.1)];
            [path2Path addLineToPoint: CGPointMake(7.05, 20.1)];
            [path2Path addCurveToPoint: CGPointMake(1.19, 14.2) controlPoint1: CGPointMake(3.82, 20.1) controlPoint2: CGPointMake(1.19, 17.45)];
            [path2Path addCurveToPoint: CGPointMake(0.51, 13.51) controlPoint1: CGPointMake(1.19, 13.82) controlPoint2: CGPointMake(0.88, 13.51)];
            [path2Path addCurveToPoint: CGPointMake(-0.17, 14.2) controlPoint1: CGPointMake(0.14, 13.51) controlPoint2: CGPointMake(-0.17, 13.82)];
            [path2Path addCurveToPoint: CGPointMake(7.05, 21.47) controlPoint1: CGPointMake(-0.17, 18.2) controlPoint2: CGPointMake(3.07, 21.47)];
            [path2Path addLineToPoint: CGPointMake(7.18, 21.47)];
            [path2Path addCurveToPoint: CGPointMake(14.4, 14.2) controlPoint1: CGPointMake(11.16, 21.47) controlPoint2: CGPointMake(14.4, 18.2)];
            [path2Path addCurveToPoint: CGPointMake(13.72, 13.51) controlPoint1: CGPointMake(14.4, 13.82) controlPoint2: CGPointMake(14.09, 13.51)];
            [path2Path closePath];
            path2Path.miterLimit = 4;
            
            path2Path.usesEvenOddFillRule = YES;
            
            [color2 setFill];
            [path2Path fill];
            
            UIBezierPath* path4Path = UIBezierPath.bezierPath;
            [path4Path moveToPoint: CGPointMake(6.37, 23.27)];
            [path4Path addLineToPoint: CGPointMake(6.37, 25.83)];
            [path4Path addCurveToPoint: CGPointMake(7.05, 26.52) controlPoint1: CGPointMake(6.37, 26.21) controlPoint2: CGPointMake(6.67, 26.52)];
            [path4Path addCurveToPoint: CGPointMake(7.72, 25.83) controlPoint1: CGPointMake(7.42, 26.52) controlPoint2: CGPointMake(7.72, 26.21)];
            [path4Path addLineToPoint: CGPointMake(7.72, 23.27)];
            [path4Path addCurveToPoint: CGPointMake(7.05, 22.59) controlPoint1: CGPointMake(7.72, 22.9) controlPoint2: CGPointMake(7.42, 22.59)];
            [path4Path addCurveToPoint: CGPointMake(6.37, 23.27) controlPoint1: CGPointMake(6.67, 22.59) controlPoint2: CGPointMake(6.37, 22.9)];
            [path4Path closePath];
            path4Path.miterLimit = 4;
            
            path4Path.usesEvenOddFillRule = YES;
            
            [color2 setFill];
            [path4Path fill];
        }
    }
}


@end
