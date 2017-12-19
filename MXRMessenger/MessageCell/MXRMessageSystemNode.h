//
//  MXRMessageSystemNode.h
//  MXRMessenger
//
//  Created by Bruno Rendeiro on 18/12/17.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>

#import "MXRMessageNodeConfiguration.h"
#import "MXRMessageContentNode.h"

@class MXRMessageSystemConfiguration;

@interface MXRMessageSystemNode : MXRMessageContentNode

- (instancetype)initWithText:(NSString*)text configuration:(MXRMessageSystemConfiguration*)configuration cornersToApplyMaxRadius:(UIRectCorner)cornersHavingRadius NS_DESIGNATED_INITIALIZER;

@property (nonatomic, strong, readonly) ASTextNode* textNode;
@property (nonatomic, strong, readonly) ASImageNode* backgroundImageNode;

@end

@interface MXRMessageSystemConfiguration : MXRMessageNodeConfiguration

@property (nonatomic, assign) UIEdgeInsets textInset; // Default: 8,12,8,12
- (void)setTextInset:(UIEdgeInsets)textInset adjustMaxCornerRadiusToKeepCircular:(BOOL)adjustMaxCornerRadius;

@property (nonatomic, strong, readonly) NSDictionary* textAttributes;

- (instancetype)initWithFont:(UIFont*)font textColor:(UIColor*)textColor backgroundColor:(UIColor*)backgroundColor;
- (instancetype)initWithTextAttributes:(NSDictionary*)attributes backgroundColor:(UIColor*)backgroundColor;

@end
