//
//  MXRMessengerInputToolbar.h
//  Mixer
//
//  Created by Scott Kensell on 3/3/17.
//  Copyright © 2017 Two To Tango. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>

#import <MXRMessenger/MXRGrowingEditableTextNode.h>
#import <MXRMessenger/MXRMessengerInputToolBarDelegate.h>

@class MXRMessengerIconButtonNode, MXRMessengerRecordingNode;

@interface MXRMessengerInputToolbar : ASDisplayNode <ASEditableTextNodeDelegate>

@property (assign, nonatomic) id<MXRMessengerInputToolBarDelegate>toolBarDelegate;

@property (nonatomic, strong, readonly) MXRGrowingEditableTextNode* textInputNode;
@property (nonatomic, strong) ASDisplayNode* leftButtonsNode;
@property (nonatomic, strong) ASDisplayNode* rightButtonsNode;
@property (nonatomic, strong, readonly) MXRMessengerIconButtonNode* defaultSendButton; // setting rightButtonsNode hides this
@property (nonatomic, strong, readonly) MXRMessengerIconButtonNode* audioInputButton;
@property (nonatomic, strong, readonly) ASImageNode* recordingNode;
@property (nonatomic, strong, readonly) ASTextNode* recDurationNode;
@property (nonatomic, strong, readonly) ASDisplayNode* recContainerNode;
@property (nonatomic, strong, readonly) ASTextNode* sliderNode;

@property (nonatomic, assign, readonly) CGFloat heightOfTextNodeWithOneLineOfText;
@property (nonatomic, strong, readonly) UIFont* font;
@property (nonatomic, strong, readonly) UIColor* tintColor;
@property (assign, nonatomic) id<ASEditableTextNodeDelegate>delegate;

- (instancetype)initWithFont:(UIFont*)font placeholder:(NSString*)placeholder tintColor:(UIColor*)tintColor;

- (NSString*)clearText; // clears and returns the current text with whitespace trimmed

@end

@interface MXRMessengerIconNode : ASDisplayNode

@property (nonatomic, strong) UIColor* color;

@end

@interface MXRMessengerSendIconNode : MXRMessengerIconNode
@end

@interface MXRMessengerPlusIconNode : MXRMessengerIconNode
@end

@interface MXRMessengerMicIconNode : MXRMessengerIconNode
@end

@interface MXRMessengerEmojiIconNode : MXRMessengerIconNode
@end

@protocol MXRMessengerIconButtonDelegate <NSObject>

-(void)touchDidBegin:(UITouch *)touch;
-(void)touchDidMove:(UITouch *)touch;
-(void)touchDidEnd:(UITouch *)touch;
-(void)touchDidCancel:(UITouch *)touch;

@end

@interface MXRMessengerIconButtonNode : ASControlNode

@property (nonatomic, strong) MXRMessengerIconNode* icon;

+ (instancetype)buttonWithIcon:(MXRMessengerIconNode*)icon matchingToolbar:(MXRMessengerInputToolbar*)toolbar;

@property (assign, nonatomic) id<MXRMessengerIconButtonDelegate>delegate;

@end
