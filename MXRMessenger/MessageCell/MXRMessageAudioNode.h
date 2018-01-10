//
//  MXRMessageAudioNode.h
//  MXRMessenger
//
//  Created by Kiddo Labs on 09/01/18.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>

#import "MXRMessageNodeConfiguration.h"
#import "MXRMessageContentNode.h"

@class MXRMessageAudioConfiguration, MXRMessengerPlayButtonNode, MXRMessengerPauseButtonNode, MXRMessengerButtonContainerNode;

@interface MXRMessageAudioNode : MXRMessageContentNode

@property (nonatomic, strong, readonly) ASDisplayNode *scrubberNode;
@property (nonatomic, strong, readonly) MXRMessengerButtonContainerNode *containerNode;
@property (nonatomic, strong, readonly) ASTextNode *durationTextNode;
@property (nonatomic, strong, readonly) ASImageNode *backgroundImageNode;
@property (nonatomic, strong, readonly) NSURL *audioURL;

- (instancetype)initWithAudioURL:(NSURL *)audioURL configuration:(MXRMessageAudioConfiguration *)configuration cornersToApplyMaxRadius:(UIRectCorner)cornerHavingRadius NS_DESIGNATED_INITIALIZER;

@end

@interface MXRMessageAudioConfiguration : MXRMessageNodeConfiguration

-(instancetype)initWithBackgroundColor:(UIColor *)backgroundColor;

@end

@interface MXRMessengerAudioIconNode : ASButtonNode

@property (strong, nonatomic) UIColor *color;

@end

@interface MXRMessengerPlayButtonNode : MXRMessengerAudioIconNode
@end

@interface MXRMessengerPauseButtonNode : MXRMessengerAudioIconNode
@end

@interface MXRMessengerButtonContainerNode : ASDisplayNode

@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, strong) MXRMessengerPlayButtonNode *playButtonNode;
@property (nonatomic, strong) MXRMessengerPauseButtonNode *pauseButtonNode;

@end

@interface MXRMessengerAudioIconButtonNode : ASControlNode

@property (nonatomic, strong) MXRMessengerAudioIconNode* icon;

+ (instancetype)buttonWithIcon:(MXRMessengerAudioIconNode*)icon matchingAudioNode:(MXRMessageAudioNode*)audioNode;

@end


