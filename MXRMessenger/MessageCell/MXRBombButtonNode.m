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
    if (smallerSide >= 100.0f) return CGSizeMake(50.f, 50.0f);
    return CGSizeMake(0.50f*smallerSide, 0.50f*smallerSide);
}

+(void)drawRect:(CGRect)bounds withParameters:(id)parameters isCancelled:(asdisplaynode_iscancelled_block_t)isCancelledBlock isRasterizing:(BOOL)isRasterizing {
    
    UIColor *color1 = [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:0.4f];
    UIColor *color2 = [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0f];
    UIColor *color3 = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.3f];
    
    UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
    [bezier2Path moveToPoint: CGPointMake(25, 50)];
    [bezier2Path addCurveToPoint: CGPointMake(50, 25) controlPoint1: CGPointMake(38.81, 50) controlPoint2: CGPointMake(50, 38.81)];
    [bezier2Path addCurveToPoint: CGPointMake(25, 0) controlPoint1: CGPointMake(50, 11.19) controlPoint2: CGPointMake(38.81, 0)];
    [bezier2Path addCurveToPoint: CGPointMake(0, 25) controlPoint1: CGPointMake(11.19, 0) controlPoint2: CGPointMake(0, 11.19)];
    [bezier2Path addCurveToPoint: CGPointMake(25, 50) controlPoint1: CGPointMake(0, 38.81) controlPoint2: CGPointMake(11.19, 50)];
    [bezier2Path closePath];
    bezier2Path.usesEvenOddFillRule = YES;
    [color3 setFill];
    [bezier2Path fill];
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(25, 50)];
    [bezierPath addCurveToPoint: CGPointMake(50, 25) controlPoint1: CGPointMake(38.81, 50) controlPoint2: CGPointMake(50, 38.81)];
    [bezierPath addCurveToPoint: CGPointMake(25, 0) controlPoint1: CGPointMake(50, 11.19) controlPoint2: CGPointMake(38.81, 0)];
    [bezierPath addCurveToPoint: CGPointMake(0, 25) controlPoint1: CGPointMake(11.19, 0) controlPoint2: CGPointMake(0, 11.19)];
    [bezierPath addCurveToPoint: CGPointMake(25, 50) controlPoint1: CGPointMake(0, 38.81) controlPoint2: CGPointMake(11.19, 50)];
    [bezierPath closePath];
    bezierPath.usesEvenOddFillRule = YES;
    [color1 setFill];
    [bezierPath fill];
    
    //// Bezier 4 Drawing
    UIBezierPath* bezier4Path = [UIBezierPath bezierPath];
    [bezier4Path moveToPoint: CGPointMake(30.54, 13.95)];
    [bezier4Path addCurveToPoint: CGPointMake(32.61, 16.02) controlPoint1: CGPointMake(30.54, 15.09) controlPoint2: CGPointMake(31.47, 16.02)];
    [bezier4Path addCurveToPoint: CGPointMake(34.69, 13.95) controlPoint1: CGPointMake(33.76, 16.02) controlPoint2: CGPointMake(34.69, 15.09)];
    [bezier4Path addCurveToPoint: CGPointMake(36.76, 11.89) controlPoint1: CGPointMake(34.69, 12.81) controlPoint2: CGPointMake(35.62, 11.89)];
    [bezier4Path addCurveToPoint: CGPointMake(37.45, 12.58) controlPoint1: CGPointMake(37.14, 11.89) controlPoint2: CGPointMake(37.45, 12.2)];
    [bezier4Path addCurveToPoint: CGPointMake(36.76, 13.27) controlPoint1: CGPointMake(37.45, 12.96) controlPoint2: CGPointMake(37.14, 13.27)];
    [bezier4Path addCurveToPoint: CGPointMake(36.07, 13.95) controlPoint1: CGPointMake(36.38, 13.27) controlPoint2: CGPointMake(36.07, 13.57)];
    [bezier4Path addCurveToPoint: CGPointMake(32.61, 17.4) controlPoint1: CGPointMake(36.07, 15.85) controlPoint2: CGPointMake(34.52, 17.4)];
    [bezier4Path addCurveToPoint: CGPointMake(29.15, 13.95) controlPoint1: CGPointMake(30.7, 17.4) controlPoint2: CGPointMake(29.15, 15.85)];
    [bezier4Path addCurveToPoint: CGPointMake(26.39, 11.2) controlPoint1: CGPointMake(29.15, 12.43) controlPoint2: CGPointMake(27.91, 11.2)];
    [bezier4Path addCurveToPoint: CGPointMake(23.62, 13.95) controlPoint1: CGPointMake(24.86, 11.2) controlPoint2: CGPointMake(23.62, 12.43)];
    [bezier4Path addCurveToPoint: CGPointMake(23.62, 16.71) controlPoint1: CGPointMake(23.62, 13.95) controlPoint2: CGPointMake(23.62, 15.7)];
    [bezier4Path addLineToPoint: CGPointMake(27.08, 16.71)];
    [bezier4Path addCurveToPoint: CGPointMake(27.77, 17.4) controlPoint1: CGPointMake(27.46, 16.71) controlPoint2: CGPointMake(27.77, 17.02)];
    [bezier4Path addLineToPoint: CGPointMake(27.77, 18.9)];
    [bezier4Path addCurveToPoint: CGPointMake(34.69, 29.11) controlPoint1: CGPointMake(31.93, 20.58) controlPoint2: CGPointMake(34.69, 24.62)];
    [bezier4Path addCurveToPoint: CGPointMake(23.62, 40.13) controlPoint1: CGPointMake(34.69, 35.18) controlPoint2: CGPointMake(29.72, 40.13)];
    [bezier4Path addCurveToPoint: CGPointMake(12.56, 29.11) controlPoint1: CGPointMake(17.52, 40.13) controlPoint2: CGPointMake(12.56, 35.18)];
    [bezier4Path addCurveToPoint: CGPointMake(19.47, 18.9) controlPoint1: CGPointMake(12.56, 24.62) controlPoint2: CGPointMake(15.32, 20.58)];
    [bezier4Path addLineToPoint: CGPointMake(19.47, 17.4)];
    [bezier4Path addCurveToPoint: CGPointMake(20.16, 16.71) controlPoint1: CGPointMake(19.47, 17.02) controlPoint2: CGPointMake(19.78, 16.71)];
    [bezier4Path addLineToPoint: CGPointMake(22.24, 16.71)];
    [bezier4Path addCurveToPoint: CGPointMake(22.24, 13.95) controlPoint1: CGPointMake(22.24, 15.7) controlPoint2: CGPointMake(22.24, 13.95)];
    [bezier4Path addCurveToPoint: CGPointMake(26.39, 9.82) controlPoint1: CGPointMake(22.24, 11.68) controlPoint2: CGPointMake(24.1, 9.82)];
    [bezier4Path addCurveToPoint: CGPointMake(30.54, 13.95) controlPoint1: CGPointMake(28.68, 9.82) controlPoint2: CGPointMake(30.54, 11.68)];
    [bezier4Path closePath];
    [bezier4Path moveToPoint: CGPointMake(26.39, 18.09)];
    [bezier4Path addLineToPoint: CGPointMake(22.93, 18.09)];
    [bezier4Path addLineToPoint: CGPointMake(20.86, 18.09)];
    [bezier4Path addLineToPoint: CGPointMake(20.86, 19.38)];
    [bezier4Path addCurveToPoint: CGPointMake(20.39, 20.02) controlPoint1: CGPointMake(20.86, 19.67) controlPoint2: CGPointMake(20.67, 19.93)];
    [bezier4Path addCurveToPoint: CGPointMake(13.94, 29.11) controlPoint1: CGPointMake(16.53, 21.39) controlPoint2: CGPointMake(13.94, 25.04)];
    [bezier4Path addCurveToPoint: CGPointMake(23.62, 38.75) controlPoint1: CGPointMake(13.94, 34.42) controlPoint2: CGPointMake(18.28, 38.75)];
    [bezier4Path addCurveToPoint: CGPointMake(33.3, 29.11) controlPoint1: CGPointMake(28.96, 38.75) controlPoint2: CGPointMake(33.3, 34.42)];
    [bezier4Path addCurveToPoint: CGPointMake(26.85, 20.02) controlPoint1: CGPointMake(33.3, 25.04) controlPoint2: CGPointMake(30.71, 21.39)];
    [bezier4Path addCurveToPoint: CGPointMake(26.39, 19.38) controlPoint1: CGPointMake(26.57, 19.93) controlPoint2: CGPointMake(26.39, 19.67)];
    [bezier4Path addLineToPoint: CGPointMake(26.39, 18.09)];
    [bezier4Path closePath];
    [bezier4Path moveToPoint: CGPointMake(19.82, 22.47)];
    [bezier4Path addCurveToPoint: CGPointMake(19.67, 23.46) controlPoint1: CGPointMake(20.06, 22.81) controlPoint2: CGPointMake(19.98, 23.24)];
    [bezier4Path addCurveToPoint: CGPointMake(17.95, 33.04) controlPoint1: CGPointMake(16.54, 25.63) controlPoint2: CGPointMake(15.77, 29.93)];
    [bezier4Path addCurveToPoint: CGPointMake(17.78, 34) controlPoint1: CGPointMake(18.17, 33.36) controlPoint2: CGPointMake(18.09, 33.79)];
    [bezier4Path addCurveToPoint: CGPointMake(17.38, 34.13) controlPoint1: CGPointMake(17.66, 34.09) controlPoint2: CGPointMake(17.52, 34.13)];
    [bezier4Path addCurveToPoint: CGPointMake(16.81, 33.83) controlPoint1: CGPointMake(17.16, 34.13) controlPoint2: CGPointMake(16.95, 34.02)];
    [bezier4Path addCurveToPoint: CGPointMake(15.43, 30.44) controlPoint1: CGPointMake(16.08, 32.78) controlPoint2: CGPointMake(15.63, 31.62)];
    [bezier4Path addCurveToPoint: CGPointMake(18.88, 22.33) controlPoint1: CGPointMake(14.94, 27.4) controlPoint2: CGPointMake(16.18, 24.2)];
    [bezier4Path addCurveToPoint: CGPointMake(19.84, 22.5) controlPoint1: CGPointMake(19.19, 22.11) controlPoint2: CGPointMake(19.62, 22.19)];
    [bezier4Path addLineToPoint: CGPointMake(19.82, 22.47)];
    [bezier4Path closePath];
    [color2 setFill];
    [bezier4Path fill];
}

@end
