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
@property (strong, nonatomic) MXRMessengerPlayButtonNode *playButton;
@property (strong, nonatomic) MXRMessengerPauseButtonNode *pauseButton;
@property (strong, nonatomic) UIImage *playImage;
@property (strong, nonatomic) UIImage *pauseImage;

@end

@implementation MXRMessageAudioNode {
    MXRMessageAudioConfiguration* _configuration;
    UIRectCorner _cornersHavingRadius;
}

-(instancetype)initWithAudioURL:(NSURL *)audioURL duration:(NSUInteger)duration configuration:(MXRMessageAudioConfiguration *)configuration cornersToApplyMaxRadius:(UIRectCorner)cornerHavingRadius {
    if (self = [super initWithConfiguration:configuration]) {
        self.automaticallyManagesSubnodes = YES;
        _configuration = configuration;
        self.userInteractionEnabled = YES;
        
        _audioURL = audioURL;
        _playImage = configuration.playButtonNode;
        _pauseImage = configuration.pauseButtonNode;
        _duration = CMTimeMake(duration, 10000);
        
        [self createDurationTextField];
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
    return [self initWithAudioURL:nil duration:0 configuration:nil cornersToApplyMaxRadius:UIRectCornerAllCorners];
}

-(instancetype)initWithConfiguration:(MXRMessageNodeConfiguration *)configuration {
    ASDISPLAYNODE_NOT_DESIGNATED_INITIALIZER();
    return [self initWithAudioURL:nil duration:0 configuration:nil cornersToApplyMaxRadius:UIRectCornerAllCorners];
}

-(AVPlayerItem *)item {
    if (!_item)
        _item = [AVPlayerItem playerItemWithURL:self.audioURL];
    return _item;
}

-(void)createDurationTextField {
    if (_durationTextNode == nil) {
        _durationTextNode = [ASTextNode new];
        
        NSDictionary *options = @{
                                  NSFontAttributeName : [UIFont systemFontOfSize:12.0],
                                  NSForegroundColorAttributeName: [UIColor blackColor]
                                  };
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:[self timeStringForCMTime:self.duration] attributes:options];
        
        _durationTextNode.attributedText = attributedString;
        _durationTextNode.truncationMode = NSLineBreakByClipping;
    }
//        [self addSubnode:_durationTextNode];
}

-(void)createPlayButtonNode {
    if (_playButton == nil) {
        _playButton = [[MXRMessengerPlayButtonNode alloc] init];
        [_playButton setImage:_playImage forState:UIControlStateNormal];
        _playButton.style.preferredSize = CGSizeMake(39.0f, 39.0f);
        
        
    }
    [_playButton addTarget:self action:@selector(didTapPlayButton) forControlEvents:ASControlNodeEventTouchUpInside];
    //    [self addSubnode:_playButton];
}

-(void)createPauseButtonNode {
    if (_pauseButton == nil) {
        _pauseButton = [[MXRMessengerPauseButtonNode alloc] init];
        _pauseButton.style.preferredSize = CGSizeMake(39.0f, 39.0f);
        [_pauseButton setImage:_pauseImage forState:UIControlStateNormal];
    }
    [_pauseButton addTarget:self action:@selector(didTapPlayButton) forControlEvents:ASControlNodeEventTouchUpInside];
    //    [self addSubnode:_pauseButton];
}

-(void)didTapPlayButton {
    self.isPlaying = !self.isPlaying;
    [self transitionLayoutWithAnimation:YES shouldMeasureAsync:NO measurementCompletion:nil];
    
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
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
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
    
    if (!_isSeeking) {
        [self transitionLayoutWithAnimation:YES shouldMeasureAsync:NO measurementCompletion:nil];
    }
}

-(void)togglePlayPause {
    [self didTapPlayButton];
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
    MXRMessengerAudioIconNode *node = self.isPlaying ? self.pauseButton : self.playButton;
    
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
    
    return [self initWithBackgroundColor:[UIColor mxr_bubbleBlueGrey] playButton:nil pauseButton:nil];
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
@end

@implementation MXRMessengerPauseButtonNode
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

