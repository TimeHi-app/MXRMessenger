//
//  MXRMessageAudioNode.m
//  MXRMessenger
//
//  Created by Kiddo Labs on 09/01/18.
//

#import "MXRMessageAudioNode.h"

#import "UIImage+MXRMessenger.h"
#import "UIColor+MXRMessenger.h"
#import "MXRMessageContentNode+Subclasses.h"
#import <AudioToolbox/AudioToolbox.h>


@interface MXRMessageAudioNode ()

@property (strong, nonatomic) AVPlayer *audioPlayer;
@property (strong, nonatomic) AVPlayerItem *item;
@property (assign, nonatomic) CMTime duration;
@property (assign, nonatomic) BOOL isSeeking;
@property (assign, nonatomic) BOOL isPlaying;
@property (strong, nonatomic, readonly) MXRMessengerPlayButtonNode *playButton;
@property (strong, nonatomic, readonly) MXRMessengerPauseButtonNode *pauseButton;

@end

@implementation MXRMessageAudioNode {
    MXRMessageAudioConfiguration* _configuration;
    UIRectCorner _cornersHavingRadius;
}

-(instancetype)initWithAudioURL:(NSURL *)audioURL configuration:(MXRMessageAudioConfiguration *)configuration cornersToApplyMaxRadius:(UIRectCorner)cornerHavingRadius {
    if (self = [super initWithConfiguration:configuration]) {
        self.automaticallyManagesSubnodes = YES;
        _configuration = configuration;
        self.userInteractionEnabled = YES;
        
        _audioURL = audioURL;
        _playButton = (MXRMessengerPlayButtonNode *)configuration.playButtonNode;
        _pauseButton = (MXRMessengerPauseButtonNode *)configuration.pauseButtonNode;
        
        
        self.item = [AVPlayerItem playerItemWithURL:self.audioURL];
        
        [self createDurationTextField];
        [self createContainerNode];
        [self createPlayButtonNode];
        [self createPauseButtonNode];
        [self createScrubber];
        
        _backgroundImageNode = [[ASImageNode alloc] init];
        _backgroundImageNode.layerBacked = YES;
        [self redrawBubble];
    }
    return self;
}

-(instancetype)init {
    ASDISPLAYNODE_NOT_DESIGNATED_INITIALIZER();
    return [self initWithAudioURL:nil configuration:nil cornersToApplyMaxRadius:UIRectCornerAllCorners];
}

-(instancetype)initWithConfiguration:(MXRMessageNodeConfiguration *)configuration {
    ASDISPLAYNODE_NOT_DESIGNATED_INITIALIZER();
    return [self initWithAudioURL:nil configuration:nil cornersToApplyMaxRadius:UIRectCornerAllCorners];
}

-(void)createDurationTextField {
    if (_durationTextNode == nil) {
        _durationTextNode = [[ASTextNode alloc] init];
        self.duration = self.item.asset.duration;
        
        NSDictionary *options = @{
                    NSFontAttributeName : [UIFont systemFontOfSize:12.0],
                    NSForegroundColorAttributeName: [UIColor blackColor]
                    };
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:[self timeStringForCMTime:self.duration] attributes:options];

        
        _durationTextNode.attributedText = attributedString;
        _durationTextNode.truncationMode = NSLineBreakByClipping;
    }
//    [self addSubnode:_durationTextNode];
}

-(void)createContainerNode {
    if (_containerNode == nil) {
        _containerNode = [[MXRMessengerButtonContainerNode alloc] init];
        _containerNode.style.preferredSize = CGSizeMake(39.0f, 39.0f);
    }
//    [self addSubnode:_containerNode];
}

-(void)createPlayButtonNode {
    if (_playButton == nil) {
        _playButton = [[MXRMessengerPlayButtonNode alloc] init];
        _playButton.style.preferredSize = CGSizeMake(39.0f, 39.0f);
    }
    [_playButton addTarget:self action:@selector(didTapPlayButton) forControlEvents:ASControlNodeEventTouchUpInside];
//    [self addSubnode:_playButton];
}

-(void)createPauseButtonNode {
    if (_pauseButton == nil) {
        _pauseButton = [[MXRMessengerPauseButtonNode alloc] init];
        _pauseButton.style.preferredSize = CGSizeMake(39.0f, 39.0f);
    }
    [_pauseButton addTarget:self action:@selector(didTapPlayButton) forControlEvents:ASControlNodeEventTouchUpInside];
//    [self addSubnode:_pauseButton];
}

-(void)didTapPlayButton {
    if (!self.audioPlayer) {
        self.audioPlayer = [AVPlayer playerWithPlayerItem:self.item];
        __weak __typeof(self) weakSelf = self;
        [self.audioPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 10000) queue:NULL usingBlock:^(CMTime time) {
            [weakSelf periodicTimeObserver:time];
        }];
    }

    if (@available(iOS 10.0, *)) {
        if (self.audioPlayer.timeControlStatus == AVPlayerTimeControlStatusPlaying) {

            [self.audioPlayer pause];
        } else if (self.audioPlayer.timeControlStatus == AVPlayerTimeControlStatusPaused || self.audioPlayer.timeControlStatus == 0) {

            [self.audioPlayer play];
        }
    } else {
    }
}

-(void)periodicTimeObserver:(CMTime)time {
    NSTimeInterval timeInSeconds = CMTimeGetSeconds(time);
    if (timeInSeconds <= 0)
        return;
    
    [self didPlayToTimeInterval:timeInSeconds];
}

-(void)didPlayToTimeInterval:(NSTimeInterval)seconds {
    
    if (_isSeeking)
        return;
    
    if (_scrubberNode)
        [(UISlider*)_scrubberNode.view setValue:( seconds / CMTimeGetSeconds(_duration) ) animated:NO];
}

-(UIImage *)drawPlay {
    CGRect rect = CGRectMake(0.0, 0.0, 15.0, 15.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale); //now it's here.
    //// Color Declarations
    UIColor* color0 = [UIColor colorWithRed: 0.245 green: 0.289 blue: 0.998 alpha: 1];
    
    UIBezierPath* oval5CopyPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(0, 0, 15, 15)];
    [color0 setFill];
    [oval5CopyPath fill];
    
    CGContextAddPath(context, oval5CopyPath.CGPath);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsPopContext();
    UIGraphicsEndImageContext();
    return image;
}

-(void)createScrubber {
    if (_scrubberNode == nil) {
        __weak __typeof__(self) weakSelf = self;
        _scrubberNode = [[ASDisplayNode alloc] initWithViewBlock:^UIView * _Nonnull{
            __typeof__(self) strongSelf = weakSelf;
            
            UISlider *slider = [[UISlider alloc] initWithFrame:CGRectZero];
            slider.minimumValue = 0.0;
            slider.maximumValue = 1.0;
            
            slider.tintColor = [UIColor colorWithRed:144/255.0f green:18/255.0f blue:254/255.0f alpha:1.0f];
            slider.minimumTrackTintColor = [UIColor colorWithRed:144/255.0f green:18/255.0f blue:254/255.0f alpha:1.0f];
            slider.maximumTrackTintColor = [UIColor whiteColor];

            UIImage *thumbImage = [self drawPlay];
            [slider setThumbImage:thumbImage forState:UIControlStateNormal];
            
            [slider addTarget:strongSelf action:@selector(beginSeek) forControlEvents:UIControlEventTouchDown];
            [slider addTarget:strongSelf action:@selector(endSeek) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside|UIControlEventTouchCancel];
            [slider addTarget:strongSelf action:@selector(seekTimeDidChange:) forControlEvents:UIControlEventValueChanged];
            
            return slider;
        }];
        
        _scrubberNode.style.flexShrink = 1;
    }
    [self addSubnode:_scrubberNode];
}

- (void)beginSeek
{
    _isSeeking = YES;
}

- (void)endSeek
{
    _isSeeking = NO;
}

- (void)seekTimeDidChange:(UISlider*)slider
{
    CGFloat percentage = slider.value * 100;
    [self seekToTime:percentage];
}

-(void)seekToTime:(CGFloat)percentComplete {
    CGFloat seconds = ( CMTimeGetSeconds(_duration) * percentComplete ) / 100;
    [self.audioPlayer seekToTime:CMTimeMakeWithSeconds(seconds, 10000)];
    
    [self togglePlayPause];
}

-(void)togglePlayPause {
    
}

-(ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
    
    CGSize maxSize = constrainedSize.max;
    maxSize = CGSizeMake(150.0f, 50.0f);
    
    // Prevent crashes through if infinite width or height
    if (isinf(maxSize.width) || isinf(maxSize.height)) {
        ASDisplayNodeAssert(NO, @"Infinite width or height in ASVideoPlayerNode");
        maxSize = CGSizeZero;
    }
    
    _backgroundImageNode.style.preferredSize = maxSize;
    
    
    ASLayoutSpec *layoutSpec = [self defaultLayoutSpecThatFits:maxSize];
    ASLayoutSpec *containerSpec = [self containerLayoutSpectThatFits:CGSizeMake(39.0f, 39.0f)];
    
    ASStackLayoutSpec *audioSpec = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionHorizontal spacing:10.0f justifyContent:ASStackLayoutJustifyContentCenter alignItems:ASStackLayoutAlignItemsCenter children:@[containerSpec, layoutSpec]];
    audioSpec.style.preferredSize = maxSize;
    
    ASInsetLayoutSpec *insetLayout = [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsMake(10, 10, 10, 10) child:audioSpec];
    
    return [ASBackgroundLayoutSpec backgroundLayoutSpecWithChild:insetLayout background:_backgroundImageNode];
}

-(ASLayoutSpec *)defaultLayoutSpecThatFits:(CGSize)maxSize {
    
    _scrubberNode.style.preferredSize = CGSizeMake(100.0f, 20.0f);
    
    ASStackLayoutSpec *progressSpec = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionVertical
                                                                              spacing:5.0f
                                                                       justifyContent:ASStackLayoutJustifyContentEnd alignItems:ASStackLayoutAlignItemsStart
                                                                             children:@[_scrubberNode, _durationTextNode]];
    
    progressSpec.style.alignSelf = ASStackLayoutAlignSelfStretch;
    
    return progressSpec;
}

-(ASLayoutSpec *)containerLayoutSpectThatFits:(CGSize)buttonSize {
    MXRMessengerAudioIconNode *node = self.isPlaying ? (MXRMessengerPauseButtonNode *)_configuration.pauseButtonNode : (MXRMessengerPlayButtonNode *)_configuration.playButtonNode;
    
    return [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsMake(0, 0, 0, 0 ) child:node];
}

- (void)redrawBubble {
    [self redrawBubbleImageWithColor:_configuration.backgroundColor];
}

- (void)redrawBubbleImageWithColor:(UIColor*)color {
    _backgroundImageNode.image = [UIImage mxr_bubbleImageWithMaximumCornerRadius:_configuration.maxCornerRadius minimumCornerRadius:_configuration.minCornerRadius color:color cornersToApplyMaxRadius:_cornersHavingRadius];
}

- (void)redrawBubbleWithCorners:(UIRectCorner)cornersHavingRadius {
    _cornersHavingRadius = cornersHavingRadius;
    [self redrawBubble];
}

- (NSString *)timeStringForCMTime:(CMTime)time {
    if (!CMTIME_IS_VALID(time)) {
        return @"00:00";
    }
    
    NSUInteger dTotalSeconds = CMTimeGetSeconds(time);
    
    NSUInteger dHours = floor(dTotalSeconds / 3600);
    NSUInteger dMinutes = floor(dTotalSeconds % 3600 / 60);
    NSUInteger dSeconds = floor(dTotalSeconds % 3600 % 60);
    
    NSString *videoDurationText;
    if (dHours > 0) {
        videoDurationText = [NSString stringWithFormat:@"%i:%02i:%02i", (int)dHours, (int)dMinutes, (int)dSeconds];
    } else {
        videoDurationText = [NSString stringWithFormat:@"%02i:%02i", (int)dMinutes, (int)dSeconds];
    }
    return videoDurationText;
}

@end

@implementation MXRMessageAudioConfiguration

-(instancetype)init {
    
    return [self initWithBackgroundColor:[UIColor mxr_bubbleBlueGrey] playButton:[[MXRMessengerPlayButtonNode alloc] init] pauseButton:[[MXRMessengerPauseButtonNode alloc] init]];
}

-(instancetype)initWithBackgroundColor:(UIColor *)backgroundColor playButton:(UIImage *)playButton pauseButton:(UIImage *)pauseButton {
    if (self = [super init]) {
        self.backgroundColor = backgroundColor;
        self.playButtonNode = playButton;
        self.pauseButtonNode = pauseButton;
    }
    return self;
}

@end

@implementation MXRMessengerAudioIconNode

- (instancetype)init {
    self = [super init];
    if (self) {
        self.opaque = NO;
        self.clipsToBounds = NO;
    }
    return self;
}

- (UIColor *)color { return _color ? : (_color = [UIColor blackColor]); }

- (id<NSObject>)drawParametersForAsyncLayer:(_ASDisplayLayer *)layer {
    return [self color];
}

@end

@implementation MXRMessengerPlayButtonNode
+ (void)drawRect:(CGRect)bounds withParameters:(id<NSObject>)parameters isCancelled:(asdisplaynode_iscancelled_block_t)isCancelledBlock isRasterizing:(BOOL)isRasterizing {
    //// Color Declarations
    UIColor* color0 = [UIColor colorWithRed: 0.245 green: 0.289 blue: 0.998 alpha: 1];
    UIColor* color2 = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    
    //// Group 01---Audio
    {
        //// Group-5
        {
            //// Oval-2 Drawing
            UIBezierPath* oval2Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(0.18, 0.3, 39, 39)];
            [color2 setFill];
            [oval2Path fill];
            //// Group 109720
            {
                //// Capa_1
                {
                    //// Shape Drawing
                    UIBezierPath* shapePath = UIBezierPath.bezierPath;
                    [shapePath moveToPoint: CGPointMake(28.43, 16.89)];
                    [shapePath addCurveToPoint: CGPointMake(27.59, 17.08) controlPoint1: CGPointMake(28.14, 16.72) controlPoint2: CGPointMake(27.77, 16.8)];
                    [shapePath addCurveToPoint: CGPointMake(27.79, 17.9) controlPoint1: CGPointMake(27.42, 17.36) controlPoint2: CGPointMake(27.5, 17.73)];
                    [shapePath addCurveToPoint: CGPointMake(28.84, 19.76) controlPoint1: CGPointMake(28.45, 18.3) controlPoint2: CGPointMake(28.84, 19)];
                    [shapePath addCurveToPoint: CGPointMake(27.79, 21.63) controlPoint1: CGPointMake(28.84, 20.53) controlPoint2: CGPointMake(28.45, 21.22)];
                    [shapePath addLineToPoint: CGPointMake(17.83, 27.7)];
                    [shapePath addCurveToPoint: CGPointMake(15.55, 27.76) controlPoint1: CGPointMake(17.13, 28.13) controlPoint2: CGPointMake(16.27, 28.15)];
                    [shapePath addCurveToPoint: CGPointMake(14.39, 25.84) controlPoint1: CGPointMake(14.83, 27.36) controlPoint2: CGPointMake(14.39, 26.65)];
                    [shapePath addLineToPoint: CGPointMake(14.39, 13.69)];
                    [shapePath addCurveToPoint: CGPointMake(15.55, 11.77) controlPoint1: CGPointMake(14.39, 12.88) controlPoint2: CGPointMake(14.83, 12.16)];
                    [shapePath addCurveToPoint: CGPointMake(17.83, 11.83) controlPoint1: CGPointMake(16.27, 11.38) controlPoint2: CGPointMake(17.13, 11.4)];
                    [shapePath addLineToPoint: CGPointMake(23.63, 15.36)];
                    [shapePath addCurveToPoint: CGPointMake(24.46, 15.17) controlPoint1: CGPointMake(23.91, 15.54) controlPoint2: CGPointMake(24.28, 15.45)];
                    [shapePath addCurveToPoint: CGPointMake(24.27, 14.36) controlPoint1: CGPointMake(24.64, 14.89) controlPoint2: CGPointMake(24.55, 14.53)];
                    [shapePath addLineToPoint: CGPointMake(18.47, 10.82)];
                    [shapePath addCurveToPoint: CGPointMake(14.96, 10.73) controlPoint1: CGPointMake(17.39, 10.16) controlPoint2: CGPointMake(16.08, 10.13)];
                    [shapePath addCurveToPoint: CGPointMake(13.18, 13.69) controlPoint1: CGPointMake(13.85, 11.34) controlPoint2: CGPointMake(13.18, 12.44)];
                    [shapePath addLineToPoint: CGPointMake(13.18, 25.84)];
                    [shapePath addCurveToPoint: CGPointMake(14.96, 28.8) controlPoint1: CGPointMake(13.18, 27.08) controlPoint2: CGPointMake(13.85, 28.19)];
                    [shapePath addCurveToPoint: CGPointMake(16.64, 29.23) controlPoint1: CGPointMake(15.49, 29.08) controlPoint2: CGPointMake(16.07, 29.23)];
                    [shapePath addCurveToPoint: CGPointMake(18.47, 28.71) controlPoint1: CGPointMake(17.27, 29.23) controlPoint2: CGPointMake(17.9, 29.05)];
                    [shapePath addLineToPoint: CGPointMake(28.43, 22.64)];
                    [shapePath addCurveToPoint: CGPointMake(30.06, 19.76) controlPoint1: CGPointMake(29.45, 22.01) controlPoint2: CGPointMake(30.06, 20.94)];
                    [shapePath addCurveToPoint: CGPointMake(28.43, 16.89) controlPoint1: CGPointMake(30.06, 18.59) controlPoint2: CGPointMake(29.45, 17.51)];
                    [shapePath addLineToPoint: CGPointMake(28.43, 16.89)];
                    [shapePath closePath];
                    shapePath.miterLimit = 4;
                    
                    shapePath.usesEvenOddFillRule = YES;
                    
                    [color0 setFill];
                    [shapePath fill];
                    [color0 setStroke];
                    shapePath.lineWidth = 0.5;
                    [shapePath stroke];
                }
            }
        }
    }
}
@end

@implementation MXRMessengerPauseButtonNode
-(instancetype)init {
    if (self = [super init]) {
        [self setNeedsDisplay];
    }
    return self;
}

+ (void)drawRect:(CGRect)bounds withParameters:(id<NSObject>)parameters isCancelled:(asdisplaynode_iscancelled_block_t)isCancelledBlock {
    //// PAUSE
    UIColor* color0 = [UIColor colorWithRed: 0.245 green: 0.289 blue: 0.998 alpha: 1];
    UIColor* color2 = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    
    //// Group 01---Audio
    {
        //// Group-6
        {
            //// Oval-2-Copy Drawing
            UIBezierPath* oval2CopyPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(0.02, -0.15, 39, 39)];
            [color0 setFill];
            [oval2CopyPath fill];
            
            //// Group 149659
            {
                //// Capa_1
                {
                    //// Group 7
                    {
                        //// Shape Drawing
                        UIBezierPath* shapePath = UIBezierPath.bezierPath;
                        [shapePath moveToPoint: CGPointMake(22.74, 13.43)];
                        [shapePath addLineToPoint: CGPointMake(22.74, 25.53)];
                        [shapePath addCurveToPoint: CGPointMake(24.32, 27.12) controlPoint1: CGPointMake(22.74, 26.41) controlPoint2: CGPointMake(23.45, 27.12)];
                        [shapePath addCurveToPoint: CGPointMake(25.89, 25.53) controlPoint1: CGPointMake(25.19, 27.12) controlPoint2: CGPointMake(25.89, 26.41)];
                        [shapePath addLineToPoint: CGPointMake(25.89, 13.43)];
                        [shapePath addCurveToPoint: CGPointMake(24.32, 11.85) controlPoint1: CGPointMake(25.89, 12.56) controlPoint2: CGPointMake(25.19, 11.85)];
                        [shapePath addCurveToPoint: CGPointMake(22.74, 13.43) controlPoint1: CGPointMake(23.45, 11.85) controlPoint2: CGPointMake(22.74, 12.56)];
                        [shapePath closePath];
                        shapePath.miterLimit = 4;
                        
                        shapePath.usesEvenOddFillRule = YES;
                        
                        [color2 setFill];
                        [shapePath fill];
                        
                        //// Shape-Copy-7 Drawing
                        UIBezierPath* shapeCopy7Path = UIBezierPath.bezierPath;
                        [shapeCopy7Path moveToPoint: CGPointMake(14.02, 13.43)];
                        [shapeCopy7Path addLineToPoint: CGPointMake(14.02, 25.53)];
                        [shapeCopy7Path addCurveToPoint: CGPointMake(15.59, 27.12) controlPoint1: CGPointMake(14.02, 26.41) controlPoint2: CGPointMake(14.72, 27.12)];
                        [shapeCopy7Path addCurveToPoint: CGPointMake(17.17, 25.53) controlPoint1: CGPointMake(16.46, 27.12) controlPoint2: CGPointMake(17.17, 26.41)];
                        [shapeCopy7Path addLineToPoint: CGPointMake(17.17, 13.43)];
                        [shapeCopy7Path addCurveToPoint: CGPointMake(15.59, 11.85) controlPoint1: CGPointMake(17.17, 12.56) controlPoint2: CGPointMake(16.46, 11.85)];
                        [shapeCopy7Path addCurveToPoint: CGPointMake(14.02, 13.43) controlPoint1: CGPointMake(14.72, 11.85) controlPoint2: CGPointMake(14.02, 12.56)];
                        [shapeCopy7Path closePath];
                        shapeCopy7Path.miterLimit = 4;
                        
                        shapeCopy7Path.usesEvenOddFillRule = YES;
                        
                        [color2 setFill];
                        [shapeCopy7Path fill];
                    }
                }
            }
        }
    }
}
@end

@implementation MXRMessengerButtonContainerNode

-(instancetype)init {
    if (self = [super init]) {
        self.automaticallyManagesSubnodes = YES;
        self.defaultLayoutTransitionDuration = 0.0;
        
        _isPlaying = NO;
    }
    return self;
}

//
//
//-(void)didTapPlayButton {
//    self.isPlaying = !self.isPlaying;
//    [self transitionLayoutWithAnimation:YES shouldMeasureAsync:NO measurementCompletion:nil];
//}
//
//-(ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
//    MXRMessengerAudioIconNode *node = self.isPlaying ? self.pauseButtonNode : self.playButtonNode;
//
//    return [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsMake(0, 0, 0, 0 ) child:node];
//}

@end

@implementation MXRMessengerAudioIconButtonNode

- (instancetype)init {
    self = [super init];
    if (self) {
        self.automaticallyManagesSubnodes = YES;
    }
    return self;
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
    return [ASCenterLayoutSpec centerLayoutSpecWithCenteringOptions:ASCenterLayoutSpecCenteringXY sizingOptions:ASCenterLayoutSpecSizingOptionMinimumXY child:_icon];
}

+ (instancetype)buttonWithIcon:(MXRMessengerAudioIconNode*)icon matchingAudioNode:(MXRMessageAudioNode*)audioNode {
    MXRMessengerAudioIconButtonNode* button = [[MXRMessengerAudioIconButtonNode alloc] init];
    button.icon = icon;
    icon.displaysAsynchronously = NO; // otherwise it doesnt appear until viewDidAppear
    button.displaysAsynchronously = NO;
    icon.color = audioNode.tintColor;
//    CGFloat iconWidth = ceilf(audioNode.font.lineHeight) + 2.0f;
//    icon.style.preferredSize = CGSizeMake(iconWidth, iconWidth + 5);
//    button.style.preferredSize = CGSizeMake(iconWidth + 22.0f, audioNode.heightOfTextNodeWithOneLineOfText);
    button.hitTestSlop = UIEdgeInsetsMake(-4.0f, 0, -10.0f, 0.0f);
    return button;
}

@end

