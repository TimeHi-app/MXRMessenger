//
//  MXRMessageAudioNode.h
//  MXRMessenger
//
//  Created by Kiddo Labs on 09/01/18.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>

#import "MXRMessageNodeConfiguration.h"
#import "MXRMessageContentNode.h"

@class MXRMessageAudioConfiguration;

@interface MXRMessageAudioNode : MXRMessageContentNode

@property (nonatomic, strong, readonly) ASButtonNode *playButtonNode;
@property (nonatomic, strong, readonly) ASDisplayNode *scrubberNode;
@property (nonatomic, strong, readonly) ASTextNode *durationTextNode;
@property (nonatomic, strong, readonly) ASImageNode *backgroundImageNode;

- (instancetype)initWithAudioURL:(NSURL *)audioURL configuration:(MXRMessageAudioConfiguration *)configuration cornersToApplyMaxRadius:(UIRectCorner)cornerHavingRadius NS_DESIGNATED_INITIALIZER;

@end

@interface MXRMessageAudioConfiguration : MXRMessageNodeConfiguration

-(instancetype)initWithBackgroundColor:(UIColor *)backgroundColor;

@end
