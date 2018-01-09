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

@interface MXRMessageAudioNode ()

@end

@implementation MXRMessageAudioNode {
    MXRMessageAudioConfiguration* _configuration;
    UIRectCorner _cornersHavingRadius;
}

-(instancetype)initWithAudioURL:(NSURL *)audioURL configuration:(MXRMessageAudioConfiguration *)configuration cornersToApplyMaxRadius:(UIRectCorner)cornerHavingRadius {
    if (self = [super initWithConfiguration:configuration]) {
        self.automaticallyManagesSubnodes = YES;
        _configuration = configuration;
        
        [self createDurationTextField];
        [self createPlayButton];
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
        
        NSDictionary *options = @{
                    NSFontAttributeName : [UIFont systemFontOfSize:12.0],
                    NSForegroundColorAttributeName: [UIColor blackColor]
                    };
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:@"00:00" attributes:options];

        
        _durationTextNode.attributedText = attributedString;
        _durationTextNode.truncationMode = NSLineBreakByClipping;
    }
    [self addSubnode:_durationTextNode];
}

-(void)createPlayButton {
    if (_playButtonNode == nil) {
        _playButtonNode = [[ASButtonNode alloc] init];
        _playButtonNode.style.preferredSize = CGSizeMake(10.0f, 10.0f);
        _playButtonNode.backgroundColor = [UIColor redColor];
        
        [_playButtonNode addTarget:self action:@selector(didTapPlayButton:) forControlEvents:ASControlNodeEventTouchUpInside];
    }
    [self addSubnode:_playButtonNode];
}

-(void)createScrubber {
    if (_scrubberNode == nil) {
        __weak __typeof__(self) weakSelf = self;
        _scrubberNode = [[ASDisplayNode alloc] initWithViewBlock:^UIView * _Nonnull{
            __typeof__(self) strongSelf = weakSelf;
            
            UISlider *slider = [[UISlider alloc] initWithFrame:CGRectZero];
            slider.minimumValue = 0.0;
            slider.maximumValue = 1.0;
            
            slider.minimumTrackTintColor = [UIColor blueColor];
            slider.maximumTrackTintColor = [UIColor blackColor];
            
            slider.thumbTintColor = [UIColor greenColor];
            
            UIImage *thumbImage = [UIImage imageNamed:@""];
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
    
    ASStackLayoutSpec *audioSpec = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionHorizontal spacing:10.0f justifyContent:ASStackLayoutJustifyContentCenter alignItems:ASStackLayoutAlignItemsCenter children:@[_playButtonNode, layoutSpec]];
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

@end

@implementation MXRMessageAudioConfiguration

-(instancetype)init {
    return [self initWithBackgroundColor:[UIColor mxr_bubbleBlueGrey]];
}

-(instancetype)initWithBackgroundColor:(UIColor *)backgroundColor {
    if (self = [super init]) {
        self.backgroundColor = backgroundColor;
    }
    return self;
}

@end

