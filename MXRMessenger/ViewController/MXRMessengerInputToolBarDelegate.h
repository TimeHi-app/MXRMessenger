//
//  MXRMessengerInputToolBarDelegate.h
//  MXRMessenger
//
//  Created by Kiddo Labs on 17/01/18.
//

#ifndef MXRMessengerInputToolBarDelegate_h
#define MXRMessengerInputToolBarDelegate_h

@class AVPlayerItem;

@protocol MXRMessengerInputToolBarDelegate <NSObject>

-(void)didRecordMP3Audio:(NSData *)playerItem;
-(void)didTapSendButton;

@end

#endif /* MXRMessengerInputToolBarDelegate_h */
