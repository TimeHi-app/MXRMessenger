//
//  MXRMessageContentNodeDelegate.h
//  Mixer
//
//  Created by Scott Kensell on 3/31/17.
//  Copyright © 2017 Two To Tango. All rights reserved.
//

#ifndef MXRMessageContentNodeDelegate_h
#define MXRMessageContentNodeDelegate_h

#import "MXRMessageCellConstants.h"

@class MXRMessageContentNode;

@protocol MXRMessageContentNodeDelegate <NSObject>

@optional
- (void)messageContentNode:(MXRMessageContentNode*)node didSingleTap:(id)sender;
- (void)messageContentNode:(MXRMessageContentNode*)node didLongTap:(id)sender;
- (void)messageContentNode:(MXRMessageContentNode*)node didTapMenuItemWithType:(MXRMessageMenuItemTypes)menuItemType;
- (void)messageContentNode:(MXRMessageContentNode*)node didTapURL:(NSURL*)url;

@end

#endif /* MXRMessageContentNodeDelegate_h */
