//
//  MXRMessageExplosiveNode.m
//  MXRMessenger
//
//  Created by Kiddo Labs on 21/03/18.
//

#import "MXRMessageExplosiveNode.h"

#import "UIImage+MXRMessenger.h"
#import "UIColor+MXRMessenger.h"

#import <Accelerate/Accelerate.h>
#import <QuartzCore/QuartzCore.h>

@implementation MXRMessageExplosiveNode {
    CGSize _maxSize;
    CGFloat _maxCornerRadius;
    CGFloat _minCornerRadius;
    UIRectCorner _cornersHavingMaxRadius;
    UIColor* _borderColor;
    CGFloat _borderWidth;
    UIImage* _image;
}

-(instancetype)initWithExplosiveConfiguration:(MXRMessageExplosiveConfiguration *)configuration cornersToApplyMaxRadius:(UIRectCorner)cornersHavingRadius image:(UIImage *)image {
    self = [super initWithConfiguration:configuration];
    if (self) {
        self.automaticallyManagesSubnodes = YES;
        _maxSize = configuration.maximumImageSize;
        _maxCornerRadius = configuration.maxCornerRadius;
        _minCornerRadius = configuration.minCornerRadius;
        _cornersHavingMaxRadius = cornersHavingRadius;
        _borderColor = configuration.borderColor;
        _borderWidth = configuration.borderWidth;
        _image = image;
        
        [self setImageModificationBlockForSize:configuration.maximumImageSize];
        
        _imageNode.image = [self imageWithBlur: image];
        
        _imageNode.style.preferredSize = configuration.maximumImageSize;
        self.style.preferredSize = _imageNode.style.preferredSize;
        _imageNode.contentMode = UIViewContentModeScaleAspectFill;
    }
    
    return self;
}

- (instancetype)initWithConfiguration:(MXRMessageNodeConfiguration *)configuration {
    ASDISPLAYNODE_NOT_DESIGNATED_INITIALIZER();
    return [self initWithExplosiveConfiguration:nil cornersToApplyMaxRadius:UIRectCornerAllCorners image:[UIImage new]];
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
    ASInsetLayoutSpec* imageInset = [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsZero child:_imageNode];

    _blurNode.style.preferredSize = CGSizeMake(100.0f, 100.0f);
    return [ASOverlayLayoutSpec overlayLayoutSpecWithChild:imageInset overlay:[ASCenterLayoutSpec centerLayoutSpecWithCenteringOptions:ASCenterLayoutSpecCenteringXY sizingOptions:ASCenterLayoutSpecSizingOptionMinimumXY child:_blurNode]];
    
    return imageInset;
}

- (void)setImageModificationBlockForSize:(CGSize)size {
    if (_minCornerRadius > 0.0f || _borderWidth > 0.0f) {
        _imageNode.imageModificationBlock = [UIImage mxr_imageModificationBlockToScaleToSize:size maximumCornerRadius:_maxCornerRadius minimumCornerRadius:_minCornerRadius borderColor:_borderColor borderWidth:_borderWidth cornersToApplyMaxRadius:_cornersHavingMaxRadius];
    }
}

- (void)redrawBubbleWithCorners:(UIRectCorner)cornersHavingRadius {
    _cornersHavingMaxRadius = cornersHavingRadius;
    [self setImageModificationBlockForSize:_imageNode.frame.size];
    [_imageNode setNeedsDisplay];
}

-(UIImage *)imageWithBlur:(UIImage *)originalImage {
    
    UIImage *image = originalImage;
    [image drawInRect:CGRectMake(0, 0, 100.0f, 100.0f)];
    
    CGFloat blurAmount = 1.0f;
    
        if (blurAmount < 0.0 || blurAmount > 1.0) {
            blurAmount = 0.5;
        }
    
        int boxSize = (int)(blurAmount * 40);
        boxSize = boxSize - (boxSize % 2) + 1;
    
        CGImageRef img = image.CGImage;
        
        vImage_Buffer inBuffer, outBuffer;
        vImage_Error error;
    
        void *pixelBuffer;
    
        CGDataProviderRef inProvider = CGImageGetDataProvider(img);
        CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
        inBuffer.width = CGImageGetWidth(img);
        inBuffer.height = CGImageGetHeight(img);
        inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
        inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
        pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    
        outBuffer.data = pixelBuffer;
        outBuffer.width = CGImageGetWidth(img);
        outBuffer.height = CGImageGetHeight(img);
        outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
        error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    
        if (!error) {
            error = vImageBoxConvolve_ARGB8888(&outBuffer, &inBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
        }
    
        if (error) {
#ifdef DEBUG
            NSLog(@"%s error: %zd", __PRETTY_FUNCTION__, error);
#endif
            
            return image;
        }
    
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
        CGContextRef ctx = CGBitmapContextCreate(outBuffer.data,
                                                 outBuffer.width,
                                                 outBuffer.height,
                                                 8,
                                                 outBuffer.rowBytes,
                                                 colorSpace,
                                                 (CGBitmapInfo)kCGImageAlphaNoneSkipLast);
    
        CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    
        UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
        CGContextRelease(ctx);
        CGColorSpaceRelease(colorSpace);
    
        free(pixelBuffer);
        CFRelease(inBitmapData);
    
        CGImageRelease(imageRef);
    
        return returnImage;
}
@end

@implementation MXRMessageExplosiveConfiguration

- (instancetype)init {
    self = [super init];
    if (self) {
        self.borderColor = [UIColor colorWithRed:0.592f green:0.592f blue:0.592f alpha:1];
        self.borderWidth = 0.5f;
        _maximumImageSize = CGSizeMake(100.0f, 100.0f);
    }
    return self;
}

+ (CGSize)suggestedMaxImageSizeForScreenSize:(CGSize)screenSize {
    int maximumImageWidth = (int)(screenSize.width * 0.50f);
    while ((maximumImageWidth % 3 != 1) && (maximumImageWidth % 2 != 0)) {
        // for the media collection it helps with spacing if its 1 mod 3 and 0 mod 2
        maximumImageWidth--;
    }
    return CGSizeMake(maximumImageWidth, 1.77f*maximumImageWidth);
}

@end
