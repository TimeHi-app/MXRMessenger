//
//  MXRMessageExplosiveNode.h
//  MXRMessenger
//
//  Created by Kiddo Labs on 21/03/18.
//

#import "MXRMessageContentNode.h"

@class MXRMessageExplosiveConfiguration;

@interface MXRMessageExplosiveNode : MXRMessageContentNode

@property (nonatomic, strong, readonly) ASNetworkImageNode *imageNode;
@property (nonatomic, strong, readonly) ASImageNode *blurNode;

-(instancetype)initWithExplosiveConfiguration:(MXRMessageExplosiveConfiguration *)configuration cornersToApplyMaxRadius:(UIRectCorner)cornersHavingRadius image:(UIImage *)image NS_DESIGNATED_INITIALIZER;

@end

@interface MXRMessageExplosiveConfiguration : MXRMessageNodeConfiguration

@property (nonatomic, assign) CGSize maximumImageSize;

+ (CGSize)suggestedMaxImageSizeForScreenSize:(CGSize)screenSize;

@end
