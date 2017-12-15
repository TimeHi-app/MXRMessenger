//
//  _MXRMessengerInputToolbarContainerView.h
//  Mixer
//
//  Created by Scott Kensell on 3/18/17.
//  Copyright © 2017 Two To Tango. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MXRMessenger/MXRMessengerInputToolbar.h>

/**
 * This container view is meant to be returned as an inputAccessoryView
 * http://stackoverflow.com/questions/25816994/changing-the-frame-of-an-inputaccessoryview-in-ios-8
 */

@interface MXRNewSizeNotifyingNode : ASDisplayNode

@property (nonatomic, strong) ASDisplayNode* innerNode;
@property (nonatomic, strong) ASDisplayNode* node;

@end

@interface MXRMessengerInputToolbarContainerView : UIView

@property (nonatomic, strong, readonly) MXRMessengerInputToolbar* toolbarNode;
@property (strong, nonatomic) MXRNewSizeNotifyingNode* containerNode;

- (instancetype)initWithMessengerInputToolbar:(MXRMessengerInputToolbar *)toolbarNode constrainedSize:(ASSizeRange)constrainedSize andNode:(ASDisplayNode *)node;

@end
