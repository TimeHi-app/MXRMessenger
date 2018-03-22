//
//  MXRBombButtonNode.m
//  MXRMessenger
//
//  Created by Kiddo Labs on 22/03/18.
//

#import "MXRBombButtonNode.h"

#import <AsyncDisplayKit/ASDisplayNode+Subclasses.h>

@implementation MXRBombButtonNode

- (instancetype)init {
    self = [super init];
    if (self) {
        self.opaque = NO;
    }
    return self;
}

+ (CGSize)suggestedSizeWhenRenderedOverImageWithSizeInPoints:(CGSize)imageSize {
    CGFloat smallerSide = MIN(imageSize.width, imageSize.height);
    if (smallerSide >= 112.0f) return CGSizeMake(56.0f, 56.0f);
    return CGSizeMake(0.50f*smallerSide, 0.50f*smallerSide);
}

+(void)drawRect:(CGRect)bounds withParameters:(id)parameters isCancelled:(asdisplaynode_iscancelled_block_t)isCancelledBlock isRasterizing:(BOOL)isRasterizing {
    
    UIColor *color1 = [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:0.4f];
    UIColor *color2 = [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0f];
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(28, 56)];
    [bezierPath addCurveToPoint: CGPointMake(56, 28) controlPoint1: CGPointMake(43.46, 56) controlPoint2: CGPointMake(56, 43.46)];
    [bezierPath addCurveToPoint: CGPointMake(28, 0) controlPoint1: CGPointMake(56, 12.54) controlPoint2: CGPointMake(43.46, 0)];
    [bezierPath addCurveToPoint: CGPointMake(0, 28) controlPoint1: CGPointMake(12.54, 0) controlPoint2: CGPointMake(0, 12.54)];
    [bezierPath addCurveToPoint: CGPointMake(28, 56) controlPoint1: CGPointMake(0, 43.46) controlPoint2: CGPointMake(12.54, 56)];
    [bezierPath closePath];
    bezierPath.usesEvenOddFillRule = YES;
    [color1 setFill];
    [bezierPath fill];
    
    
    //// Bezier 4 Drawing
    UIBezierPath* bezier4Path = [UIBezierPath bezierPath];
    [bezier4Path moveToPoint: CGPointMake(34.2, 15.63)];
    [bezier4Path addCurveToPoint: CGPointMake(36.53, 17.94) controlPoint1: CGPointMake(34.2, 16.9) controlPoint2: CGPointMake(35.24, 17.94)];
    [bezier4Path addCurveToPoint: CGPointMake(38.85, 15.63) controlPoint1: CGPointMake(37.81, 17.94) controlPoint2: CGPointMake(38.85, 16.9)];
    [bezier4Path addCurveToPoint: CGPointMake(41.17, 13.31) controlPoint1: CGPointMake(38.85, 14.35) controlPoint2: CGPointMake(39.89, 13.31)];
    [bezier4Path addCurveToPoint: CGPointMake(41.95, 14.09) controlPoint1: CGPointMake(41.6, 13.31) controlPoint2: CGPointMake(41.95, 13.66)];
    [bezier4Path addCurveToPoint: CGPointMake(41.17, 14.86) controlPoint1: CGPointMake(41.95, 14.51) controlPoint2: CGPointMake(41.6, 14.86)];
    [bezier4Path addCurveToPoint: CGPointMake(40.4, 15.63) controlPoint1: CGPointMake(40.75, 14.86) controlPoint2: CGPointMake(40.4, 15.2)];
    [bezier4Path addCurveToPoint: CGPointMake(36.53, 19.49) controlPoint1: CGPointMake(40.4, 17.76) controlPoint2: CGPointMake(38.66, 19.49)];
    [bezier4Path addCurveToPoint: CGPointMake(32.65, 15.63) controlPoint1: CGPointMake(34.39, 19.49) controlPoint2: CGPointMake(32.65, 17.76)];
    [bezier4Path addCurveToPoint: CGPointMake(29.55, 12.54) controlPoint1: CGPointMake(32.65, 13.93) controlPoint2: CGPointMake(31.26, 12.54)];
    [bezier4Path addCurveToPoint: CGPointMake(26.46, 15.63) controlPoint1: CGPointMake(27.85, 12.54) controlPoint2: CGPointMake(26.46, 13.93)];
    [bezier4Path addLineToPoint: CGPointMake(26.46, 19.49)];
    [bezier4Path addCurveToPoint: CGPointMake(25.68, 20.26) controlPoint1: CGPointMake(26.46, 19.91) controlPoint2: CGPointMake(26.11, 20.26)];
    [bezier4Path addCurveToPoint: CGPointMake(24.91, 19.49) controlPoint1: CGPointMake(25.25, 20.26) controlPoint2: CGPointMake(24.91, 19.91)];
    [bezier4Path addLineToPoint: CGPointMake(24.91, 15.63)];
    [bezier4Path addCurveToPoint: CGPointMake(29.55, 11) controlPoint1: CGPointMake(24.91, 13.08) controlPoint2: CGPointMake(26.99, 11)];
    [bezier4Path addCurveToPoint: CGPointMake(34.2, 15.63) controlPoint1: CGPointMake(32.12, 11) controlPoint2: CGPointMake(34.2, 13.08)];
    [bezier4Path closePath];
    [bezier4Path moveToPoint: CGPointMake(29.55, 22.26)];
    [bezier4Path addLineToPoint: CGPointMake(23.36, 22.26)];
    [bezier4Path addLineToPoint: CGPointMake(23.36, 23.7)];
    [bezier4Path addCurveToPoint: CGPointMake(22.84, 24.43) controlPoint1: CGPointMake(23.36, 24.03) controlPoint2: CGPointMake(23.15, 24.32)];
    [bezier4Path addCurveToPoint: CGPointMake(21.74, 24.88) controlPoint1: CGPointMake(22.46, 24.56) controlPoint2: CGPointMake(22.1, 24.71)];
    [bezier4Path addCurveToPoint: CGPointMake(22.22, 25.2) controlPoint1: CGPointMake(21.93, 24.92) controlPoint2: CGPointMake(22.1, 25.03)];
    [bezier4Path addCurveToPoint: CGPointMake(22.03, 26.27) controlPoint1: CGPointMake(22.46, 25.55) controlPoint2: CGPointMake(22.38, 26.03)];
    [bezier4Path addCurveToPoint: CGPointMake(20.1, 37.01) controlPoint1: CGPointMake(18.52, 28.7) controlPoint2: CGPointMake(17.66, 33.52)];
    [bezier4Path addCurveToPoint: CGPointMake(19.91, 38.08) controlPoint1: CGPointMake(20.35, 37.36) controlPoint2: CGPointMake(20.26, 37.84)];
    [bezier4Path addCurveToPoint: CGPointMake(19.47, 38.22) controlPoint1: CGPointMake(19.77, 38.18) controlPoint2: CGPointMake(19.62, 38.22)];
    [bezier4Path addCurveToPoint: CGPointMake(18.83, 37.89) controlPoint1: CGPointMake(19.22, 38.22) controlPoint2: CGPointMake(18.98, 38.11)];
    [bezier4Path addCurveToPoint: CGPointMake(17.28, 34.09) controlPoint1: CGPointMake(18.01, 36.72) controlPoint2: CGPointMake(17.5, 35.42)];
    [bezier4Path addCurveToPoint: CGPointMake(20.02, 25.92) controlPoint1: CGPointMake(16.81, 31.14) controlPoint2: CGPointMake(17.78, 28.06)];
    [bezier4Path addCurveToPoint: CGPointMake(15.61, 34.6) controlPoint1: CGPointMake(17.3, 27.92) controlPoint2: CGPointMake(15.61, 31.12)];
    [bezier4Path addCurveToPoint: CGPointMake(26.46, 45.4) controlPoint1: CGPointMake(15.61, 40.55) controlPoint2: CGPointMake(20.48, 45.4)];
    [bezier4Path addCurveToPoint: CGPointMake(37.3, 34.6) controlPoint1: CGPointMake(32.43, 45.4) controlPoint2: CGPointMake(37.3, 40.55)];
    [bezier4Path addCurveToPoint: CGPointMake(30.07, 24.43) controlPoint1: CGPointMake(37.3, 30.04) controlPoint2: CGPointMake(34.4, 25.95)];
    [bezier4Path addCurveToPoint: CGPointMake(29.55, 23.7) controlPoint1: CGPointMake(29.76, 24.32) controlPoint2: CGPointMake(29.55, 24.03)];
    [bezier4Path addLineToPoint: CGPointMake(29.55, 22.26)];
    [bezier4Path closePath];
    [bezier4Path moveToPoint: CGPointMake(30.37, 20.72)];
    [bezier4Path addCurveToPoint: CGPointMake(31.1, 21.49) controlPoint1: CGPointMake(30.76, 20.71) controlPoint2: CGPointMake(31.1, 21.06)];
    [bezier4Path addLineToPoint: CGPointMake(31.1, 23.17)];
    [bezier4Path addCurveToPoint: CGPointMake(38.85, 34.6) controlPoint1: CGPointMake(35.76, 25.05) controlPoint2: CGPointMake(38.85, 29.57)];
    [bezier4Path addCurveToPoint: CGPointMake(26.46, 46.94) controlPoint1: CGPointMake(38.85, 41.4) controlPoint2: CGPointMake(33.29, 46.94)];
    [bezier4Path addCurveToPoint: CGPointMake(14.06, 34.6) controlPoint1: CGPointMake(19.62, 46.94) controlPoint2: CGPointMake(14.06, 41.4)];
    [bezier4Path addCurveToPoint: CGPointMake(21.81, 23.17) controlPoint1: CGPointMake(14.06, 29.57) controlPoint2: CGPointMake(17.15, 25.05)];
    [bezier4Path addLineToPoint: CGPointMake(21.81, 21.49)];
    [bezier4Path addCurveToPoint: CGPointMake(22.58, 20.71) controlPoint1: CGPointMake(21.81, 21.06) controlPoint2: CGPointMake(22.16, 20.71)];
    [bezier4Path addLineToPoint: CGPointMake(30.33, 20.71)];
    [bezier4Path addLineToPoint: CGPointMake(30.37, 20.72)];
    [bezier4Path closePath];
    [color2 setFill];
    [bezier4Path fill];

}

@end
