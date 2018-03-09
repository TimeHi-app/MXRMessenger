//
//  MXRMessengerInputToolbar.m
//  Mixer
//
//  Created by Scott Kensell on 3/3/17.
//  Copyright © 2017 Two To Tango. All rights reserved.
//

#import <MXRMessenger/MXRMessengerInputToolbar.h>

#import <MXRMessenger/UIColor+MXRMessenger.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MXRmessenger/ExtAudioConverter.h>

@import lame;

@interface MXRMessengerInputToolbar () <MXRMessengerIconButtonDelegate, AVAudioPlayerDelegate, MXRMessengerInputToolBarDelegate>

@property (strong, nonatomic) NSString *inputPath;

@end

@implementation MXRMessengerInputToolbar {
    ASImageNode* _textInputBackgroundNode;
    UIEdgeInsets _textInputInsets;
    UIEdgeInsets _finalInsets;
    
    CGPoint pointAudioStart;
    AVAudioRecorder* _audioRecorder;
    NSTimer *timerAudio;
    NSDate *dateAudioStart;
    
    BOOL isTyping;
    BOOL isRecording;
    
}

- (instancetype)init {
    return [self initWithFont:[UIFont systemFontOfSize:16.0f] placeholder:@"Type a message" tintColor:[UIColor mxr_fbMessengerBlue]];
}

- (instancetype)initWithFont:(UIFont *)font placeholder:(NSString *)placeholder tintColor:(UIColor*)tintColor {
    self = [super init];
    if (self) {
        NSAssert(font, @"You forgot to provide a font to init %@", NSStringFromClass(self.class));
        self.automaticallyManagesSubnodes = YES;
        self.defaultLayoutTransitionDuration = 0.05;
        self.backgroundColor = [UIColor whiteColor];
        _font = font;
        _tintColor = tintColor;
        
        // #8899a6 alpha 0.85
        UIColor* placeholderGray = [UIColor colorWithRed:0.53 green:0.60 blue:0.65 alpha:0.85];
        // #f5f8fa
        UIColor* veryLightGray = [UIColor colorWithRed:0.96 green:0.97 blue:0.98 alpha:1.0];;
        
        CGFloat topPadding = ceilf(0.33f * font.lineHeight);
        CGFloat bottomPadding = topPadding;
        CGFloat heightOfTextNode = ceilf(topPadding + bottomPadding + font.lineHeight);
        _heightOfTextNodeWithOneLineOfText = heightOfTextNode;
        CGFloat cornerRadius = floorf(heightOfTextNode / 2.0f);
        
//        isRecording = YES;
        
        [self setupAudioRecorder];
        [self createCancelSliderNode];
        [self createDurationTextNode];
        [self createRecordingImageNode];
        
        _textInputInsets = UIEdgeInsetsMake(topPadding, 0.7f*cornerRadius, bottomPadding, 0.7f*cornerRadius);
        
        _textInputBackgroundNode = [[ASImageNode alloc] init];
        _textInputBackgroundNode.image = [UIImage as_resizableRoundedImageWithCornerRadius:cornerRadius cornerColor:[UIColor whiteColor] fillColor:veryLightGray borderColor:placeholderGray borderWidth:0.5f];
        _textInputBackgroundNode.displaysAsynchronously = NO; // otherwise it doesnt appear until viewDidAppear
        
        _textInputNode = [[MXRGrowingEditableTextNode alloc] init];
        _textInputNode.delegate = self;
        _textInputNode.enablesReturnKeyAutomatically = YES;
        
        _textInputNode.tintColor = tintColor;
        _textInputNode.maximumLinesToDisplay = 6;
        _textInputNode.typingAttributes = @{NSFontAttributeName: font, NSForegroundColorAttributeName: [UIColor blackColor]};
        NSDictionary* placeholderAttributes = @{NSFontAttributeName: font, NSForegroundColorAttributeName: placeholderGray};
        _textInputNode.attributedPlaceholderText = [[NSAttributedString alloc] initWithString:(placeholder ? : @"") attributes:placeholderAttributes];
        _textInputNode.style.flexGrow = 1.0f;
        _textInputNode.style.flexShrink = 1.0f;
        _textInputNode.clipsToBounds = YES;
        self.toolBarDelegate = self;
        
        _defaultSendButton = [MXRMessengerIconButtonNode buttonWithIcon:[[MXRMessengerSendIconNode alloc] init] matchingToolbar:self];
        _defaultSendButton.delegate = self;
        
        _audioInputButton = [MXRMessengerIconButtonNode buttonWithIcon:[[MXRMessengerMicIconNode alloc] init] matchingToolbar:self];
        _audioInputButton.delegate = self;
        
        _rightButtonsNode = _audioInputButton;
        
        _finalInsets = UIEdgeInsetsMake(8, 0, 10, 0);
    }
    return self;
}

-(void)touchDidBegin:(UITouch *)touch {
    if (isTyping) {
        if ([self.toolBarDelegate respondsToSelector:@selector(didTapSendButton)]) {
            isTyping = NO;
            [self transitionLayoutWithAnimation:YES shouldMeasureAsync:NO measurementCompletion:nil];
            [self.toolBarDelegate didTapSendButton];
        }
    } else {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        
        pointAudioStart = [touch locationInView:self.view];
        [self audioRecorderInit];
    }
}

-(void)touchDidMove:(UITouch *)touch {
    if (!isTyping) {
        
    }
}

-(void)touchDidEnd:(UITouch *)touch {
    if (!isTyping) {
        CGPoint pointAudioStop = [touch locationInView:self.view];
        CGFloat distanceAudio = sqrtf(powf(pointAudioStop.x - pointAudioStart.x, 2) + pow(pointAudioStop.y - pointAudioStart.y, 2));
        [self audioRecorderStop:(distanceAudio < 50)];
    }
}

-(void)setDelegate:(id<ASEditableTextNodeDelegate>)delegate {
    _textInputNode.delegate = delegate;
}

-(void)setRightButtonsNode:(ASDisplayNode *)rightButtonsNode {
    _rightButtonsNode = rightButtonsNode;
    
    [self invalidateCalculatedLayout];
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
    ASStackLayoutSpec* inputBar = [ASStackLayoutSpec horizontalStackLayoutSpec];
    inputBar.alignItems = ASStackLayoutAlignItemsEnd;
//    inputBar.justifyContent = ASStackLayoutJustifyContentCenter;
    NSMutableArray* inputBarChildren = [[NSMutableArray alloc] init];
    
    if (isRecording) {
        
        ASLayoutSpec *layoutSpec = [self defaultLayoutSpec];
        _rightButtonsNode = _audioInputButton;
        
        [inputBarChildren addObject:layoutSpec];
        
        ASInsetLayoutSpec *slideInset = [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsMake(_textInputInsets.top, 0, _textInputInsets.bottom, 0) child:_sliderNode];

        
        slideInset.style.flexGrow = 1.0f;
        slideInset.style.flexShrink = 1.0f;
        
//        slideInset.style.spacingBefore = [UIScreen mainScreen].bounds.size.width / 2 - 102;
//        slideInset.style.spacingAfter =  [UIScreen mainScreen].bounds.size.width / 2;
        
        [inputBarChildren addObject:slideInset];
        [inputBarChildren addObject:_rightButtonsNode];
        
        inputBar.children = inputBarChildren;
        
    } else {
        
        if (_leftButtonsNode) [inputBarChildren addObject:_leftButtonsNode];
        
        _rightButtonsNode = isTyping ? _defaultSendButton : _audioInputButton;
        
        ASInsetLayoutSpec* textInputInset = [ASInsetLayoutSpec insetLayoutSpecWithInsets:_textInputInsets child:_textInputNode];
        ASBackgroundLayoutSpec* textInputWithBackground = [ASBackgroundLayoutSpec backgroundLayoutSpecWithChild:textInputInset background:_textInputBackgroundNode];
        textInputWithBackground.style.flexGrow = 1.0f;
        textInputWithBackground.style.flexShrink = 1.0f;
        if (!_leftButtonsNode) textInputWithBackground.style.spacingBefore = 8.0f;
        if (!_rightButtonsNode) textInputWithBackground.style.spacingAfter = 8.0f;
        [inputBarChildren addObject:textInputWithBackground];
        
        if (_rightButtonsNode) [inputBarChildren addObject:_rightButtonsNode];
        inputBar.children = inputBarChildren;
    }
    
    ASInsetLayoutSpec* inputBarInset = [ASInsetLayoutSpec insetLayoutSpecWithInsets:_finalInsets child:inputBar];
    return inputBarInset;
}

-(void)editableTextNodeDidUpdateText:(ASEditableTextNode *)editableTextNode {
    if  (_textInputNode.textView.text.length == 0) {
        isTyping = NO;
        [self transitionLayoutWithAnimation:YES shouldMeasureAsync:NO measurementCompletion:nil];
    }
}

-(BOOL)editableTextNode:(ASEditableTextNode *)editableTextNode shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if (text.length > 0) {
        isTyping = YES;
        [self transitionLayoutWithAnimation:YES shouldMeasureAsync:NO measurementCompletion:nil];
    }
    
    return YES;
}

- (NSString*)clearText {
    NSString* text = [_textInputNode.attributedText.string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    _textInputNode.attributedText = [[NSAttributedString alloc] initWithString:@"" attributes:_textInputNode.typingAttributes];
    return text;
}

-(NSString *)pathForAudio:(NSString *)extension{
    int r = arc4random_uniform(5000);
    NSString *fileName = [NSString stringWithFormat:@"audioRecorder%d.%@", r, extension];
    
    return [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
}

-(void)setupAudioRecorder {
    NSError *error;
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    
    NSDictionary *settings = @{
                               AVFormatIDKey : @(kAudioFormatMPEG4AAC),
                               AVSampleRateKey : @(44100),
                               AVNumberOfChannelsKey : @(2)
                               };
    
    self.inputPath = [self pathForAudio:@"m4a"];
    _audioRecorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:self.inputPath] settings:settings error:&error];
    NSLog(@"ERROR: %@", [error description]);
    _audioRecorder.meteringEnabled = YES;
    
    [_audioRecorder prepareToRecord];
}

-(void)audioRecorderInit {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    NSError *error;
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:&error];
    
    isRecording = YES;
    [self transitionLayoutWithAnimation:NO shouldMeasureAsync:NO measurementCompletion:nil];
    
    [self audioRecorderStart];
}

-(void)audioRecorderStart {
    [_audioRecorder record];
    
    dateAudioStart = [NSDate date];
    
        timerAudio = [NSTimer scheduledTimerWithTimeInterval:0.07 target:self selector:@selector(audioRecorderUpdate) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:timerAudio forMode:NSRunLoopCommonModes];
}

-(void)audioRecorderUpdate {
    self.recDurationNode.attributedText = [self durationTimerText:[self timeStringForCMTime:[[NSDate date] timeIntervalSinceDate:dateAudioStart]]];
}

-(void)audioRecorderStop:(BOOL)sending {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    isRecording = NO;
    
    [self transitionLayoutWithAnimation:NO shouldMeasureAsync:NO measurementCompletion:nil];
    
    if ((sending) && ([[NSDate date] timeIntervalSinceDate:dateAudioStart] >= 1)) {
        NSLog(@"%f", [[NSDate date] timeIntervalSinceDate:dateAudioStart]);
        
        NSLog(@"END RECORDING");
        [_audioRecorder stop];
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setActive:NO error:nil];
        
        if ([self.toolBarDelegate respondsToSelector:@selector(didRecordMP3Audio:)])
            [self.toolBarDelegate didRecordMP3Audio:[NSURL URLWithString:self.inputPath]];
        
        [timerAudio invalidate];
        timerAudio = nil;
        self.recDurationNode.attributedText = [self durationTimerText:@"00:00"];
    } else {
        NSLog(@"DELETE RECORDING");
        
        [_audioRecorder stop];
        [timerAudio invalidate];
        timerAudio = nil;
        self.recDurationNode.attributedText = [self durationTimerText:@"00:00"];
        [_audioRecorder deleteRecording];
    }
}

- (NSString *)timeStringForCMTime:(double)time {
    if (!time) {
        return @"00:00";
    }
    
    NSUInteger dTotalSeconds = time;
    
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

#pragma mark - RecordingButtonAndTimeSetup
-(void)createRecordingImageNode {
    if (!_recordingNode) {
        _recordingNode = [[ASImageNode alloc] init];
        _recordingNode.image = [self drawRecNode];
        _recordingNode.style.preferredSize = CGSizeMake(44.0f, 30.0f);
        _recordingNode.displaysAsynchronously = NO;
        _recordingNode.contentMode = UIViewContentModeScaleAspectFit;
//        _recordingNode.backgroundColor = [UIColor greenColor];
    }
}

-(void)createDurationTextNode {
    if (!_recDurationNode) {
        _recDurationNode = [ASTextNode new];
        _recDurationNode.attributedText = [self durationTimerText:@"00:00"];
        _recDurationNode.displaysAsynchronously = NO;
//        _recDurationNode.backgroundColor = [UIColor blueColor];
    }
}

-(void)createCancelSliderNode {
    if (!_sliderNode) {
        _sliderNode = [ASTextNode new];
        _sliderNode.attributedText = [self textForSliderNode];
        _sliderNode.displaysAsynchronously = NO;
//        _sliderNode.backgroundColor = [UIColor redColor];
    }
}

-(ASLayoutSpec *)defaultLayoutSpec {
    
    ASStackLayoutSpec *recordingInset = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionHorizontal spacing:0.0f justifyContent:ASStackLayoutJustifyContentEnd alignItems:ASStackLayoutAlignItemsCenter children:@[_recordingNode ,_recDurationNode]];
    
    return recordingInset;
}

//-(ASLayoutSpec *)cancelLayoutSpec:(ASSizeRange)constrainedSize {
//
//    ASLayoutSpec *layoutSpec = [self defaultLayoutSpec];
//
//    ASStackLayoutSpec *cancelInset = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionHorizontal spacing:5.0f justifyContent:ASStackLayoutJustifyContentStart alignItems:ASStackLayoutAlignItemsCenter children:@[layoutSpec, _sliderNode]];
//    _sliderNode.style.spacingAfter = 40.0f;
//    _sliderNode.style.spacingBefore = 20.0f;
//
//    ASInsetLayoutSpec *insetLayout = [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsMake(0, 0, 0, 0) child:cancelInset];
//
//    return insetLayout;
//}

-(NSAttributedString *)textForSliderNode {
    NSAttributedString *string;
    
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.alignment = NSTextAlignmentCenter;
    
    
    if (@available(iOS 8.2, *)) {
        NSDictionary *options = @{
                                  NSForegroundColorAttributeName : [UIColor colorWithRed:146/255.0f green:146/255.0f blue:146/255.0f alpha:1.0f],
                                  NSFontAttributeName : [UIFont systemFontOfSize:13.0f weight:UIFontWeightLight],
                                  NSParagraphStyleAttributeName : paragraph
                                  };
        
        string = [[NSAttributedString alloc] initWithString:@"Slide to cancel <" attributes:options];
    } else {
        // Fallback on earlier versions
    }
    
    return string;
}

-(NSAttributedString *)durationTimerText:(NSString *)currentTime {
    NSAttributedString *string;
    
    NSDictionary *options = @{
                              NSForegroundColorAttributeName : [UIColor colorWithRed:41/255.0f green:28/255.0f blue:42/255.0f alpha:1.0f],
                              NSFontAttributeName : [UIFont systemFontOfSize:18.0f]
                              };
    
    string = [[NSAttributedString alloc] initWithString:currentTime attributes:options];
    
    return string;
}

-(UIImage *)drawRecNode {
    CGRect rect = CGRectMake(0.0, 0.0, 44.0, 34.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    //// Color Declarations
    UIColor* fillColor = [UIColor colorWithRed: 0.882 green: 0.114 blue: 0.114 alpha: 1];
    UIColor* fillColor2 = [UIColor colorWithRed: 251/255.0f green: 135/255.0f blue: 135/255.0f alpha: 1];
    
    //// Bezier Drawing
    UIBezierPath* bezierPath2 = [UIBezierPath bezierPath];
    [bezierPath2 moveToPoint: CGPointMake(21.25, 15.53)];
    [bezierPath2 addCurveToPoint: CGPointMake(15.28, 7.76) controlPoint1: CGPointMake(17.95, 15.53) controlPoint2: CGPointMake(15.28, 12.05)];
    [bezierPath2 addCurveToPoint: CGPointMake(21.25, 0) controlPoint1: CGPointMake(15.28, 3.48) controlPoint2: CGPointMake(17.95, 0)];
    [bezierPath2 addCurveToPoint: CGPointMake(27.23, 7.76) controlPoint1: CGPointMake(24.55, 0) controlPoint2: CGPointMake(27.23, 3.48)];
    [bezierPath2 addCurveToPoint: CGPointMake(21.25, 15.53) controlPoint1: CGPointMake(27.23, 12.05) controlPoint2: CGPointMake(24.55, 15.53)];
    [bezierPath2 closePath];
    bezierPath2.usesEvenOddFillRule = YES;
    [fillColor setFill];
    [bezierPath2 fill];
    
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(23.33, 32.04)];
    [bezierPath addLineToPoint: CGPointMake(24.04, 32.04)];
    [bezierPath addCurveToPoint: CGPointMake(21.68, 34) controlPoint1: CGPointMake(23.75, 33.25) controlPoint2: CGPointMake(22.87, 34)];
    [bezierPath addCurveToPoint: CGPointMake(19.12, 30.17) controlPoint1: CGPointMake(20.11, 34) controlPoint2: CGPointMake(19.12, 32.51)];
    [bezierPath addCurveToPoint: CGPointMake(21.67, 26.33) controlPoint1: CGPointMake(19.12, 27.84) controlPoint2: CGPointMake(20.12, 26.33)];
    [bezierPath addCurveToPoint: CGPointMake(24.13, 30) controlPoint1: CGPointMake(23.19, 26.33) controlPoint2: CGPointMake(24.13, 27.74)];
    [bezierPath addLineToPoint: CGPointMake(24.13, 30.4)];
    [bezierPath addLineToPoint: CGPointMake(19.83, 30.4)];
    [bezierPath addLineToPoint: CGPointMake(19.83, 30.44)];
    [bezierPath addCurveToPoint: CGPointMake(21.69, 33.19) controlPoint1: CGPointMake(19.87, 32.12) controlPoint2: CGPointMake(20.59, 33.19)];
    [bezierPath addCurveToPoint: CGPointMake(23.33, 32.04) controlPoint1: CGPointMake(22.5, 33.19) controlPoint2: CGPointMake(23.09, 32.77)];
    [bezierPath closePath];
    [bezierPath moveToPoint: CGPointMake(21.66, 27.13)];
    [bezierPath addCurveToPoint: CGPointMake(19.84, 29.66) controlPoint1: CGPointMake(20.62, 27.13) controlPoint2: CGPointMake(19.9, 28.13)];
    [bezierPath addLineToPoint: CGPointMake(23.4, 29.66)];
    [bezierPath addCurveToPoint: CGPointMake(21.66, 27.13) controlPoint1: CGPointMake(23.38, 28.13) controlPoint2: CGPointMake(22.7, 27.13)];
    [bezierPath closePath];
    [bezierPath moveToPoint: CGPointMake(13.73, 29.8)];
    [bezierPath addLineToPoint: CGPointMake(13.73, 33.88)];
    [bezierPath addLineToPoint: CGPointMake(13, 33.88)];
    [bezierPath addLineToPoint: CGPointMake(13, 23.93)];
    [bezierPath addLineToPoint: CGPointMake(15.74, 23.93)];
    [bezierPath addCurveToPoint: CGPointMake(18.19, 26.84) controlPoint1: CGPointMake(17.23, 23.93) controlPoint2: CGPointMake(18.19, 25.07)];
    [bezierPath addCurveToPoint: CGPointMake(16.55, 29.65) controlPoint1: CGPointMake(18.19, 28.25) controlPoint2: CGPointMake(17.57, 29.3)];
    [bezierPath addLineToPoint: CGPointMake(18.4, 33.88)];
    [bezierPath addLineToPoint: CGPointMake(17.56, 33.88)];
    [bezierPath addLineToPoint: CGPointMake(15.8, 29.8)];
    [bezierPath addLineToPoint: CGPointMake(13.73, 29.8)];
    [bezierPath closePath];
    [bezierPath moveToPoint: CGPointMake(13.73, 24.77)];
    [bezierPath addLineToPoint: CGPointMake(13.73, 28.96)];
    [bezierPath addLineToPoint: CGPointMake(15.68, 28.96)];
    [bezierPath addCurveToPoint: CGPointMake(17.44, 26.87) controlPoint1: CGPointMake(16.79, 28.96) controlPoint2: CGPointMake(17.44, 28.2)];
    [bezierPath addCurveToPoint: CGPointMake(15.65, 24.77) controlPoint1: CGPointMake(17.44, 25.56) controlPoint2: CGPointMake(16.77, 24.77)];
    [bezierPath addLineToPoint: CGPointMake(13.73, 24.77)];
    [bezierPath closePath];
    [bezierPath moveToPoint: CGPointMake(30, 28.64)];
    [bezierPath addLineToPoint: CGPointMake(29.29, 28.64)];
    [bezierPath addCurveToPoint: CGPointMake(27.66, 27.14) controlPoint1: CGPointMake(29.12, 27.78) controlPoint2: CGPointMake(28.53, 27.14)];
    [bezierPath addCurveToPoint: CGPointMake(25.8, 30.14) controlPoint1: CGPointMake(26.52, 27.14) controlPoint2: CGPointMake(25.8, 28.31)];
    [bezierPath addCurveToPoint: CGPointMake(27.66, 33.18) controlPoint1: CGPointMake(25.8, 31.99) controlPoint2: CGPointMake(26.53, 33.18)];
    [bezierPath addCurveToPoint: CGPointMake(29.29, 31.74) controlPoint1: CGPointMake(28.5, 33.18) controlPoint2: CGPointMake(29.11, 32.65)];
    [bezierPath addLineToPoint: CGPointMake(29.99, 31.74)];
    [bezierPath addCurveToPoint: CGPointMake(27.66, 34) controlPoint1: CGPointMake(29.82, 33.07) controlPoint2: CGPointMake(28.97, 34)];
    [bezierPath addCurveToPoint: CGPointMake(25.08, 30.14) controlPoint1: CGPointMake(26.09, 34) controlPoint2: CGPointMake(25.08, 32.5)];
    [bezierPath addCurveToPoint: CGPointMake(27.66, 26.33) controlPoint1: CGPointMake(25.08, 27.82) controlPoint2: CGPointMake(26.08, 26.33)];
    [bezierPath addCurveToPoint: CGPointMake(30, 28.64) controlPoint1: CGPointMake(28.97, 26.33) controlPoint2: CGPointMake(29.83, 27.34)];
    [bezierPath closePath];
    bezierPath.usesEvenOddFillRule = YES;
    [fillColor2 setFill];
    [bezierPath fill];

    CGContextAddPath(context, bezierPath.CGPath);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsPopContext();
    UIGraphicsEndImageContext();
    return image;
}
@end

@implementation MXRMessengerIconNode

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

@implementation MXRMessengerSendIconNode
+ (void)drawRect:(CGRect)bounds withParameters:(id<NSObject>)parameters isCancelled:(asdisplaynode_iscancelled_block_t)isCancelledBlock isRasterizing:(BOOL)isRasterizing {
    UIColor* color = [UIColor colorWithRed: 0.242 green: 0.289 blue: 0.998 alpha: 1];
    
    {
        {
            UIBezierPath* pathPath = UIBezierPath.bezierPath;
            [pathPath moveToPoint: CGPointMake(2.12, 22.49)];
            [pathPath addLineToPoint: CGPointMake(23.25, 12.3)];
            [pathPath addCurveToPoint: CGPointMake(23.72, 10.97) controlPoint1: CGPointMake(23.75, 12.06) controlPoint2: CGPointMake(23.96, 11.47)];
            [pathPath addCurveToPoint: CGPointMake(23.25, 10.5) controlPoint1: CGPointMake(23.62, 10.77) controlPoint2: CGPointMake(23.45, 10.6)];
            [pathPath addLineToPoint: CGPointMake(2.12, 0.31)];
            [pathPath addCurveToPoint: CGPointMake(0.78, 0.78) controlPoint1: CGPointMake(1.62, 0.07) controlPoint2: CGPointMake(1.02, 0.28)];
            [pathPath addCurveToPoint: CGPointMake(0.71, 1.44) controlPoint1: CGPointMake(0.68, 0.99) controlPoint2: CGPointMake(0.66, 1.22)];
            [pathPath addLineToPoint: CGPointMake(2.73, 10.02)];
            [pathPath addCurveToPoint: CGPointMake(3.63, 10.79) controlPoint1: CGPointMake(2.83, 10.45) controlPoint2: CGPointMake(3.2, 10.76)];
            [pathPath addLineToPoint: CGPointMake(12.67, 11.4)];
            [pathPath addLineToPoint: CGPointMake(3.63, 12.02)];
            [pathPath addCurveToPoint: CGPointMake(2.73, 12.79) controlPoint1: CGPointMake(3.2, 12.05) controlPoint2: CGPointMake(2.83, 12.36)];
            [pathPath addLineToPoint: CGPointMake(0.71, 21.36)];
            [pathPath addCurveToPoint: CGPointMake(1.45, 22.57) controlPoint1: CGPointMake(0.58, 21.9) controlPoint2: CGPointMake(0.92, 22.44)];
            [pathPath addCurveToPoint: CGPointMake(2.12, 22.49) controlPoint1: CGPointMake(1.68, 22.62) controlPoint2: CGPointMake(1.91, 22.59)];
            [pathPath closePath];
            pathPath.miterLimit = 4;
            
            pathPath.usesEvenOddFillRule = YES;
            
            [color setFill];
            [pathPath fill];
        }
    }
}

@end

@implementation MXRMessengerPlusIconNode 
+ (void)drawRect:(CGRect)bounds withParameters:(id<NSObject>)parameters isCancelled:(asdisplaynode_iscancelled_block_t)isCancelledBlock isRasterizing:(BOOL)isRasterizing {
    UIColor* color2 = [UIColor colorWithRed: 0.5 green: 0.5 blue: 0.5 alpha: 1];
    
    {
        {
            UIBezierPath* pathPath = UIBezierPath.bezierPath;
            [pathPath moveToPoint: CGPointMake(4, 17.88)];
            [pathPath addCurveToPoint: CGPointMake(7.19, 21.07) controlPoint1: CGPointMake(5.76, 17.88) controlPoint2: CGPointMake(7.19, 19.31)];
            [pathPath addCurveToPoint: CGPointMake(4, 24.26) controlPoint1: CGPointMake(7.19, 22.83) controlPoint2: CGPointMake(5.76, 24.26)];
            [pathPath addCurveToPoint: CGPointMake(0.81, 21.07) controlPoint1: CGPointMake(2.24, 24.26) controlPoint2: CGPointMake(0.81, 22.83)];
            [pathPath addCurveToPoint: CGPointMake(4, 17.88) controlPoint1: CGPointMake(0.81, 19.31) controlPoint2: CGPointMake(2.24, 17.88)];
            [pathPath closePath];
            [pathPath moveToPoint: CGPointMake(4, 22.6)];
            [pathPath addCurveToPoint: CGPointMake(5.53, 21.07) controlPoint1: CGPointMake(4.84, 22.6) controlPoint2: CGPointMake(5.53, 21.91)];
            [pathPath addCurveToPoint: CGPointMake(4, 19.55) controlPoint1: CGPointMake(5.53, 20.23) controlPoint2: CGPointMake(4.84, 19.55)];
            [pathPath addCurveToPoint: CGPointMake(2.47, 21.07) controlPoint1: CGPointMake(3.16, 19.55) controlPoint2: CGPointMake(2.47, 20.23)];
            [pathPath addCurveToPoint: CGPointMake(4, 22.6) controlPoint1: CGPointMake(2.47, 21.91) controlPoint2: CGPointMake(3.16, 22.6)];
            [pathPath closePath];
            pathPath.miterLimit = 4;
            
            pathPath.usesEvenOddFillRule = YES;
            
            [color2 setFill];
            [pathPath fill];
            
            UIBezierPath* path2Path = UIBezierPath.bezierPath;
            [path2Path moveToPoint: CGPointMake(23.74, 19.88)];
            [path2Path addLineToPoint: CGPointMake(9.42, 19.88)];
            [path2Path addCurveToPoint: CGPointMake(8.81, 20.71) controlPoint1: CGPointMake(9.08, 19.88) controlPoint2: CGPointMake(8.81, 20.25)];
            [path2Path addCurveToPoint: CGPointMake(9.42, 21.55) controlPoint1: CGPointMake(8.81, 21.17) controlPoint2: CGPointMake(9.08, 21.55)];
            [path2Path addLineToPoint: CGPointMake(23.74, 21.55)];
            [path2Path addCurveToPoint: CGPointMake(24.35, 20.71) controlPoint1: CGPointMake(24.08, 21.55) controlPoint2: CGPointMake(24.35, 21.17)];
            [path2Path addCurveToPoint: CGPointMake(23.74, 19.88) controlPoint1: CGPointMake(24.35, 20.25) controlPoint2: CGPointMake(24.08, 19.88)];
            [path2Path closePath];
            path2Path.miterLimit = 4;
            
            path2Path.usesEvenOddFillRule = YES;
            
            [color2 setFill];
            [path2Path fill];
            
            UIBezierPath* path4Path = UIBezierPath.bezierPath;
            [path4Path moveToPoint: CGPointMake(4, 9.38)];
            [path4Path addCurveToPoint: CGPointMake(3.17, 10.21) controlPoint1: CGPointMake(3.54, 9.38) controlPoint2: CGPointMake(3.17, 9.75)];
            [path4Path addCurveToPoint: CGPointMake(4, 11.05) controlPoint1: CGPointMake(3.17, 10.67) controlPoint2: CGPointMake(3.54, 11.05)];
            [path4Path addCurveToPoint: CGPointMake(5.53, 12.57) controlPoint1: CGPointMake(4.84, 11.05) controlPoint2: CGPointMake(5.53, 11.73)];
            [path4Path addCurveToPoint: CGPointMake(4, 14.1) controlPoint1: CGPointMake(5.53, 13.41) controlPoint2: CGPointMake(4.84, 14.1)];
            [path4Path addCurveToPoint: CGPointMake(2.47, 12.57) controlPoint1: CGPointMake(3.16, 14.1) controlPoint2: CGPointMake(2.47, 13.41)];
            [path4Path addCurveToPoint: CGPointMake(1.64, 11.74) controlPoint1: CGPointMake(2.47, 12.11) controlPoint2: CGPointMake(2.1, 11.74)];
            [path4Path addCurveToPoint: CGPointMake(0.81, 12.57) controlPoint1: CGPointMake(1.18, 11.74) controlPoint2: CGPointMake(0.81, 12.11)];
            [path4Path addCurveToPoint: CGPointMake(4, 15.76) controlPoint1: CGPointMake(0.81, 14.33) controlPoint2: CGPointMake(2.24, 15.76)];
            [path4Path addCurveToPoint: CGPointMake(7.19, 12.57) controlPoint1: CGPointMake(5.76, 15.76) controlPoint2: CGPointMake(7.19, 14.33)];
            [path4Path addCurveToPoint: CGPointMake(4, 9.38) controlPoint1: CGPointMake(7.19, 10.81) controlPoint2: CGPointMake(5.76, 9.38)];
            [path4Path closePath];
            path4Path.miterLimit = 4;
            
            path4Path.usesEvenOddFillRule = YES;
            
            [color2 setFill];
            [path4Path fill];
            
            UIBezierPath* path6Path = UIBezierPath.bezierPath;
            [path6Path moveToPoint: CGPointMake(23.74, 11.38)];
            [path6Path addLineToPoint: CGPointMake(9.42, 11.38)];
            [path6Path addCurveToPoint: CGPointMake(8.81, 12.21) controlPoint1: CGPointMake(9.08, 11.38) controlPoint2: CGPointMake(8.81, 11.75)];
            [path6Path addCurveToPoint: CGPointMake(9.42, 13.05) controlPoint1: CGPointMake(8.81, 12.67) controlPoint2: CGPointMake(9.08, 13.05)];
            [path6Path addLineToPoint: CGPointMake(23.74, 13.05)];
            [path6Path addCurveToPoint: CGPointMake(24.35, 12.21) controlPoint1: CGPointMake(24.08, 13.05) controlPoint2: CGPointMake(24.35, 12.67)];
            [path6Path addCurveToPoint: CGPointMake(23.74, 11.38) controlPoint1: CGPointMake(24.35, 11.75) controlPoint2: CGPointMake(24.08, 11.38)];
            [path6Path closePath];
            path6Path.miterLimit = 4;
            
            path6Path.usesEvenOddFillRule = YES;
            
            [color2 setFill];
            [path6Path fill];
            
            UIBezierPath* path8Path = UIBezierPath.bezierPath;
            [path8Path moveToPoint: CGPointMake(4, 0.88)];
            [path8Path addCurveToPoint: CGPointMake(7.19, 4.07) controlPoint1: CGPointMake(5.76, 0.88) controlPoint2: CGPointMake(7.19, 2.31)];
            [path8Path addCurveToPoint: CGPointMake(4, 7.26) controlPoint1: CGPointMake(7.19, 5.83) controlPoint2: CGPointMake(5.76, 7.26)];
            [path8Path addCurveToPoint: CGPointMake(0.81, 4.07) controlPoint1: CGPointMake(2.24, 7.26) controlPoint2: CGPointMake(0.81, 5.83)];
            [path8Path addCurveToPoint: CGPointMake(4, 0.88) controlPoint1: CGPointMake(0.81, 2.31) controlPoint2: CGPointMake(2.24, 0.88)];
            [path8Path closePath];
            [path8Path moveToPoint: CGPointMake(4, 5.6)];
            [path8Path addCurveToPoint: CGPointMake(5.53, 4.07) controlPoint1: CGPointMake(4.84, 5.6) controlPoint2: CGPointMake(5.53, 4.91)];
            [path8Path addCurveToPoint: CGPointMake(4, 2.55) controlPoint1: CGPointMake(5.53, 3.23) controlPoint2: CGPointMake(4.84, 2.55)];
            [path8Path addCurveToPoint: CGPointMake(2.47, 4.07) controlPoint1: CGPointMake(3.16, 2.55) controlPoint2: CGPointMake(2.47, 3.23)];
            [path8Path addCurveToPoint: CGPointMake(4, 5.6) controlPoint1: CGPointMake(2.47, 4.91) controlPoint2: CGPointMake(3.16, 5.6)];
            [path8Path closePath];
            path8Path.miterLimit = 4;
            
            path8Path.usesEvenOddFillRule = YES;
            
            [color2 setFill];
            [path8Path fill];
            
            UIBezierPath* path10Path = UIBezierPath.bezierPath;
            [path10Path moveToPoint: CGPointMake(23.74, 2.88)];
            [path10Path addLineToPoint: CGPointMake(9.42, 2.88)];
            [path10Path addCurveToPoint: CGPointMake(8.81, 3.71) controlPoint1: CGPointMake(9.08, 2.88) controlPoint2: CGPointMake(8.81, 3.25)];
            [path10Path addCurveToPoint: CGPointMake(9.42, 4.55) controlPoint1: CGPointMake(8.81, 4.17) controlPoint2: CGPointMake(9.08, 4.55)];
            [path10Path addLineToPoint: CGPointMake(23.74, 4.55)];
            [path10Path addCurveToPoint: CGPointMake(24.35, 3.71) controlPoint1: CGPointMake(24.08, 4.55) controlPoint2: CGPointMake(24.35, 4.17)];
            [path10Path addCurveToPoint: CGPointMake(23.74, 2.88) controlPoint1: CGPointMake(24.35, 3.25) controlPoint2: CGPointMake(24.08, 2.88)];
            [path10Path closePath];
            path10Path.miterLimit = 4;
            
            path10Path.usesEvenOddFillRule = YES;
            
            [color2 setFill];
            [path10Path fill];
        }
    }
}

@end

@implementation MXRMessengerMicIconNode
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

@implementation MXRMessengerEmojiIconNode
+ (void)drawRect:(CGRect)bounds withParameters:(id<NSObject>)parameters isCancelled:(asdisplaynode_iscancelled_block_t)isCancelledBlock isRasterizing:(BOOL)isRasterizing {
    UIColor* color0 = [UIColor colorWithRed: 0.564 green: 0.564 blue: 0.564 alpha: 1];
    UIColor* color2 = [UIColor colorWithRed: 0.5 green: 0.5 blue: 0.5 alpha: 1];
    
    {
        {
            UIBezierPath* stroke1Path = UIBezierPath.bezierPath;
            [stroke1Path moveToPoint: CGPointMake(16.86, 3.56)];
            [stroke1Path addCurveToPoint: CGPointMake(3.54, 3.56) controlPoint1: CGPointMake(13.19, -0.11) controlPoint2: CGPointMake(7.21, -0.11)];
            [stroke1Path addCurveToPoint: CGPointMake(3.54, 16.88) controlPoint1: CGPointMake(-0.13, 7.23) controlPoint2: CGPointMake(-0.13, 13.21)];
            [stroke1Path addCurveToPoint: CGPointMake(10.54, 19.63) controlPoint1: CGPointMake(5.46, 18.81) controlPoint2: CGPointMake(8.02, 19.72)];
            [stroke1Path addCurveToPoint: CGPointMake(16.86, 16.88) controlPoint1: CGPointMake(12.84, 19.55) controlPoint2: CGPointMake(15.11, 18.63)];
            [stroke1Path addCurveToPoint: CGPointMake(19.23, 9.16) controlPoint1: CGPointMake(20.54, 13.21) controlPoint2: CGPointMake(19.23, 9.16)];
            stroke1Path.miterLimit = 4;
            
            stroke1Path.lineCapStyle = kCGLineCapRound;
            
            stroke1Path.usesEvenOddFillRule = YES;
            
            [color0 setStroke];
            stroke1Path.lineWidth = 1.5;
            [stroke1Path stroke];
            
            UIBezierPath* pathPath = UIBezierPath.bezierPath;
            [pathPath moveToPoint: CGPointMake(6.31, 8.2)];
            [pathPath addCurveToPoint: CGPointMake(7.86, 6.66) controlPoint1: CGPointMake(6.31, 7.35) controlPoint2: CGPointMake(7.01, 6.66)];
            [pathPath addCurveToPoint: CGPointMake(9.4, 8.2) controlPoint1: CGPointMake(8.71, 6.66) controlPoint2: CGPointMake(9.4, 7.35)];
            [pathPath addCurveToPoint: CGPointMake(8.96, 8.64) controlPoint1: CGPointMake(9.4, 8.45) controlPoint2: CGPointMake(9.21, 8.64)];
            [pathPath addCurveToPoint: CGPointMake(8.52, 8.2) controlPoint1: CGPointMake(8.72, 8.64) controlPoint2: CGPointMake(8.52, 8.45)];
            [pathPath addCurveToPoint: CGPointMake(7.86, 7.54) controlPoint1: CGPointMake(8.52, 7.84) controlPoint2: CGPointMake(8.22, 7.54)];
            [pathPath addCurveToPoint: CGPointMake(7.2, 8.2) controlPoint1: CGPointMake(7.5, 7.54) controlPoint2: CGPointMake(7.2, 7.84)];
            [pathPath addCurveToPoint: CGPointMake(6.76, 8.64) controlPoint1: CGPointMake(7.2, 8.45) controlPoint2: CGPointMake(7, 8.64)];
            [pathPath addCurveToPoint: CGPointMake(6.31, 8.2) controlPoint1: CGPointMake(6.51, 8.64) controlPoint2: CGPointMake(6.31, 8.45)];
            [pathPath closePath];
            pathPath.miterLimit = 4;
            
            pathPath.usesEvenOddFillRule = YES;
            
            [color0 setFill];
            [pathPath fill];
            
            UIBezierPath* path2Path = UIBezierPath.bezierPath;
            [path2Path moveToPoint: CGPointMake(7.12, 12.17)];
            [path2Path addCurveToPoint: CGPointMake(7.4, 11.47) controlPoint1: CGPointMake(7, 11.9) controlPoint2: CGPointMake(7.13, 11.59)];
            [path2Path addCurveToPoint: CGPointMake(7.61, 11.43) controlPoint1: CGPointMake(7.47, 11.45) controlPoint2: CGPointMake(7.54, 11.43)];
            [path2Path addCurveToPoint: CGPointMake(8.1, 11.76) controlPoint1: CGPointMake(7.82, 11.43) controlPoint2: CGPointMake(8.02, 11.56)];
            [path2Path addCurveToPoint: CGPointMake(11.21, 13.72) controlPoint1: CGPointMake(8.59, 12.95) controlPoint2: CGPointMake(9.82, 13.72)];
            [path2Path addCurveToPoint: CGPointMake(14.31, 11.76) controlPoint1: CGPointMake(12.58, 13.72) controlPoint2: CGPointMake(13.79, 12.95)];
            [path2Path addCurveToPoint: CGPointMake(15.01, 11.48) controlPoint1: CGPointMake(14.42, 11.49) controlPoint2: CGPointMake(14.74, 11.37)];
            [path2Path addCurveToPoint: CGPointMake(15.28, 12.18) controlPoint1: CGPointMake(15.28, 11.6) controlPoint2: CGPointMake(15.4, 11.91)];
            [path2Path addCurveToPoint: CGPointMake(11.21, 14.78) controlPoint1: CGPointMake(14.6, 13.76) controlPoint2: CGPointMake(13, 14.78)];
            [path2Path addCurveToPoint: CGPointMake(7.12, 12.17) controlPoint1: CGPointMake(9.38, 14.78) controlPoint2: CGPointMake(7.78, 13.76)];
            [path2Path closePath];
            path2Path.miterLimit = 4;
            
            path2Path.usesEvenOddFillRule = YES;
            
            [color2 setFill];
            [path2Path fill];
            
            UIBezierPath* path4Path = UIBezierPath.bezierPath;
            [path4Path moveToPoint: CGPointMake(11.24, 8.21)];
            [path4Path addCurveToPoint: CGPointMake(12.78, 6.66) controlPoint1: CGPointMake(11.24, 7.35) controlPoint2: CGPointMake(11.93, 6.66)];
            [path4Path addCurveToPoint: CGPointMake(14.33, 8.21) controlPoint1: CGPointMake(13.63, 6.66) controlPoint2: CGPointMake(14.33, 7.35)];
            [path4Path addCurveToPoint: CGPointMake(13.88, 8.65) controlPoint1: CGPointMake(14.33, 8.45) controlPoint2: CGPointMake(14.13, 8.65)];
            [path4Path addCurveToPoint: CGPointMake(13.44, 8.21) controlPoint1: CGPointMake(13.64, 8.65) controlPoint2: CGPointMake(13.44, 8.45)];
            [path4Path addCurveToPoint: CGPointMake(12.78, 7.55) controlPoint1: CGPointMake(13.44, 7.84) controlPoint2: CGPointMake(13.14, 7.55)];
            [path4Path addCurveToPoint: CGPointMake(12.12, 8.21) controlPoint1: CGPointMake(12.42, 7.55) controlPoint2: CGPointMake(12.12, 7.84)];
            [path4Path addCurveToPoint: CGPointMake(11.68, 8.65) controlPoint1: CGPointMake(12.12, 8.45) controlPoint2: CGPointMake(11.93, 8.65)];
            [path4Path addCurveToPoint: CGPointMake(11.24, 8.21) controlPoint1: CGPointMake(11.44, 8.65) controlPoint2: CGPointMake(11.24, 8.45)];
            [path4Path closePath];
            path4Path.miterLimit = 4;
            
            path4Path.usesEvenOddFillRule = YES;
            
            [color2 setFill];
            [path4Path fill];
        }
    }
}
@end

@implementation MXRMessengerIconButtonNode

- (instancetype)init {
    self = [super init];
    if (self) {
        self.automaticallyManagesSubnodes = YES;
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
    return [ASCenterLayoutSpec centerLayoutSpecWithCenteringOptions:ASCenterLayoutSpecCenteringXY sizingOptions:ASCenterLayoutSpecSizingOptionMinimumXY child:_icon];
}

+ (instancetype)buttonWithIcon:(MXRMessengerIconNode *)icon matchingToolbar:(MXRMessengerInputToolbar *)toolbar {
    MXRMessengerIconButtonNode* button = [[MXRMessengerIconButtonNode alloc] init];
    button.icon = icon;
    icon.displaysAsynchronously = NO; // otherwise it doesnt appear until viewDidAppear
    button.displaysAsynchronously = NO;
    icon.color = toolbar.tintColor;
    CGFloat iconWidth = ceilf(toolbar.font.lineHeight) + 2.0f;
    icon.style.preferredSize = CGSizeMake(iconWidth, iconWidth + 5);
    button.style.preferredSize = CGSizeMake(iconWidth + 22.0f, toolbar.heightOfTextNodeWithOneLineOfText);
    button.hitTestSlop = UIEdgeInsetsMake(-4.0f, 0, -10.0f, 0.0f);
    return button;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    if ([self.delegate respondsToSelector:@selector(touchDidBegin:)])
        [self.delegate touchDidBegin:event.allTouches.allObjects[0]];
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    
    if ([self.delegate respondsToSelector:@selector(touchDidMove:)])
        [self.delegate touchDidMove:event.allTouches.allObjects[0]];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    if ([self.delegate respondsToSelector:@selector(touchDidEnd:)])
        [self.delegate touchDidEnd:event.allTouches.allObjects[0]];
}

-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    
    if ([self.delegate respondsToSelector:@selector(touchDidCancel:)])
        [self.delegate touchDidCancel:event.allTouches.allObjects[0]];
}

@end
