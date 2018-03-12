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


@interface MXRMessageAudioNode () <AVAudioPlayerDelegate>

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) AVPlayer *player;
@property (assign, nonatomic) CMTime duration;
@property (assign, nonatomic) BOOL isPlaying;
@property (strong, nonatomic) MXRMessengerPlayButtonNode *playButton;
@property (strong, nonatomic) MXRMessengerPauseButtonNode *pauseButton;
@property (strong, nonatomic) UIImage *playImage;
@property (strong, nonatomic) UIImage *pauseImage;
@property (strong, nonatomic) NSTimer *scrubberTime;

@end

@implementation MXRMessageAudioNode {
    MXRMessageAudioConfiguration* _configuration;
    UIRectCorner _cornersHavingRadius;
}

-(instancetype)initWithAudioURL:(NSURL *)audioURL duration:(NSUInteger)duration configuration:(MXRMessageAudioConfiguration *)configuration cornersToApplyMaxRadius:(UIRectCorner)cornerHavingRadius {
    if (self = [super initWithConfiguration:configuration]) {
        ASDisplayNodeAssert(duration > 0, @"Audio must have duration");
        
        self.automaticallyManagesSubnodes = YES;
        _configuration = configuration;
        self.userInteractionEnabled = YES;
        
        _audioURL = audioURL;
        _playImage = configuration.playButtonNode;
        _pauseImage = configuration.pauseButtonNode;
        _duration = CMTimeMake(duration, 1);
        
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

-(void)createDurationTextField {
    if (_durationTextNode == nil) {
        _durationTextNode = [ASTextNode new];
        
        _durationTextNode.attributedText = [self setAttributedString:self.duration];
        _durationTextNode.truncationMode = NSLineBreakByClipping;
    }
}

-(void)createPlayButtonNode {
    if (!_playButton) {
        _playButton = [[MXRMessengerPlayButtonNode alloc] init];
        [_playButton setImage:_playImage forState:UIControlStateNormal];
        _playButton.style.preferredSize = CGSizeMake(39.0f, 39.0f);
        
    }
    [_playButton addTarget:self action:@selector(didTapPlayButton:) forControlEvents:ASControlNodeEventTouchUpInside];
}

-(void)createPauseButtonNode {
    if (!_pauseButton) {
        _pauseButton = [[MXRMessengerPauseButtonNode alloc] init];
        _pauseButton.style.preferredSize = CGSizeMake(39.0f, 39.0f);
        [_pauseButton setImage:_pauseImage forState:UIControlStateNormal];
    }
    [_pauseButton addTarget:self action:@selector(didTapPlayButton:) forControlEvents:ASControlNodeEventTouchUpInside];
}

-(void)didTapPlayButton:(NSNotification *)notification {
    
    if (CMTimeGetSeconds(self.duration) == 0)
        return;
    
    NSError *error;
    self.isPlaying = !self.isPlaying;
    [self transitionLayoutWithAnimation:NO shouldMeasureAsync:NO measurementCompletion:nil];
    
//    if (!self.audioPlayer) {
//
//        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:self.audioURL error:&error];
//        self.audioPlayer.volume = 1;
//        NSLog(@"%@", error);
//        self.audioPlayer.delegate = self;
//        [self.audioPlayer prepareToPlay];
//    }
    
    if (!self.player) {
        
        AVAsset *asset = [AVAsset assetWithURL:self.audioURL];
        AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
        
        self.player = [AVPlayer playerWithPlayerItem:item];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:item];
        
    }
    
    if (self.player.status == AVPlayerTimeControlStatusPlaying) {
        [self.scrubberTime invalidate];
        [self.player pause];
    } else {
        self.scrubberTime = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateSlider:) userInfo:nil repeats:YES];
        [self.player play];
    }
    
//    if (self.audioPlayer.isPlaying) {
//        [self.scrubberTime invalidate];
//        [self.audioPlayer stop];
//    } else {
//        self.scrubberTime = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateSlider:) userInfo:nil repeats:YES];
//        [self.audioPlayer play];
//    }
}

-(void)updateSlider:(UISlider *)sender {

    NSLog(@"CURRENT TIME: %f", self.audioPlayer.currentTime);
    [(UISlider *)self.scrubberNode.view setValue:self.audioPlayer.currentTime];

    self.durationTextNode.attributedText = [self setAttributedString:CMTimeMake(self.audioPlayer.currentTime, 1)];
}

-(UIImage *)drawThumbImage {
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

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    NSLog(@"FINISHED PLAYING");
    self.isPlaying = !self.isPlaying;
    [(UISlider *)self.scrubberNode.view setValue:0];
    _durationTextNode.attributedText = [self setAttributedString:self.duration];
    [self transitionLayoutWithAnimation:YES shouldMeasureAsync:NO measurementCompletion:nil];
    self.audioPlayer = nil;
    [self.scrubberTime invalidate];
}

-(void)playerDidFinishPlaying:(NSNotification *)notification {
    NSLog(@"FINISHED PLAYING");
    self.isPlaying = !self.isPlaying;
    [(UISlider *)self.scrubberNode.view setValue:0];
    _durationTextNode.attributedText = [self setAttributedString:self.duration];
    [self transitionLayoutWithAnimation:YES shouldMeasureAsync:NO measurementCompletion:nil];
    self.player = nil;
    [self.scrubberTime invalidate];
}

-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    NSLog(@"DECODE");
}

-(NSAttributedString *)setAttributedString:(CMTime)time {
    NSDictionary *options = @{
                              NSFontAttributeName : [UIFont systemFontOfSize:12.0],
                              NSForegroundColorAttributeName: [UIColor blackColor]
                              };
    
    
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:[self timeStringForCMTime:time] attributes:options];
    
    return attributedString;
}

-(void)createScrubber {
    if (_scrubberNode == nil) {
        _scrubberNode = [[ASDisplayNode alloc] initWithViewBlock:^UIView * _Nonnull{
            
            UISlider *slider = [[UISlider alloc] initWithFrame:CGRectZero];
            slider.minimumValue = 0.0;
            slider.maximumValue = CMTimeGetSeconds(_duration);
            
            slider.tintColor = [UIColor colorWithRed:144/255.0f green:18/255.0f blue:254/255.0f alpha:1.0f];
            slider.minimumTrackTintColor = [UIColor colorWithRed:144/255.0f green:18/255.0f blue:254/255.0f alpha:1.0f];
            slider.maximumTrackTintColor = [UIColor whiteColor];
            
            UIImage *thumbImage = [self drawThumbImage];
            
            [slider setThumbImage:thumbImage forState:UIControlStateNormal];

            return slider;
        }];
        
        _scrubberNode.style.flexShrink = 1;
    }
    [self addSubnode:_scrubberNode];
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
                                                                       justifyContent:ASStackLayoutJustifyContentEnd
                                                                           alignItems:ASStackLayoutAlignItemsStart
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
    _backgroundImageNode.image = [UIImage mxr_bubbleImageWithMaximumCornerRadius:_configuration.maxCornerRadius
                                                             minimumCornerRadius:_configuration.minCornerRadius
                                                                           color:color
                                                         cornersToApplyMaxRadius:_cornersHavingRadius];
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
    return [ASCenterLayoutSpec centerLayoutSpecWithCenteringOptions:ASCenterLayoutSpecCenteringXY
                                                      sizingOptions:ASCenterLayoutSpecSizingOptionMinimumXY
                                                              child:_icon];
}

+ (instancetype)buttonWithIcon:(MXRMessengerAudioIconNode*)icon matchingAudioNode:(MXRMessageAudioNode*)audioNode {
    MXRMessengerAudioIconButtonNode* button = [[MXRMessengerAudioIconButtonNode alloc] init];
    button.icon = icon;
    icon.displaysAsynchronously = NO; // otherwise it doesnt appear until viewDidAppear
    button.displaysAsynchronously = NO;
    icon.color = audioNode.tintColor;
    button.hitTestSlop = UIEdgeInsetsMake(-4.0f, 0, -10.0f, 0.0f);
    
    return button;
}

@end

