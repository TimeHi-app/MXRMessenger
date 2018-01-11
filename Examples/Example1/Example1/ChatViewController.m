//
//  MXRExampleViewController.m
//  MXRMessenger
//
//  Created by Scott Kensell on 4/18/17.
//  Copyright © 2017 Scott Kensell. All rights reserved.
//

#import "ChatViewController.h"

#import <MXRMessenger/MXRMessageCellFactory.h>
#import <MXRMessenger/UIColor+MXRMessenger.h>

#import "Message.h"
#import "Person.h"

@interface ChatViewController () <MXRMessageCellFactoryDataSource, MXRMessageContentNodeDelegate, MXRMessageMediaCollectionNodeDelegate, ASTableDelegate, ASTableDataSource>

@property (nonatomic, strong) MXRMessageCellFactory* cellFactory;
@property (nonatomic, strong) NSMutableArray <Message*>* messages;
@property (nonatomic, strong) NSURL* otherPersonsAvatar;

@end

@implementation ChatViewController {
    CGPoint pointAudioStart;
    AVAudioRecorder *audioRecorder;
    NSTimer *timerAudio;
    NSDate *dateAudioStart;
}

- (instancetype)initWithPerson:(Person *)person {
    self = [super init];
    if (self) {
        self.title = person.name;
        
        MXRMessengerIconButtonNode* addPhotosBarButtonButtonNode = [MXRMessengerIconButtonNode buttonWithIcon:[[MXRMessengerPlusIconNode alloc] init] matchingToolbar:self.toolbar];
//        [addPhotosBarButtonButtonNode addTarget:self action:@selector(tapAddPhotos:) forControlEvents:ASControlNodeEventTouchUpInside];
        self.toolbar.leftButtonsNode = addPhotosBarButtonButtonNode;
//        [self.toolbar.defaultSendButton addTarget:self action:@selector(tapSend:) forControlEvents:ASControlNodeEventTouchUpInside];
        
        _otherPersonsAvatar = person.avatarURL;
    }
    return self;
}

-(void)audioRecorderGesture:(UILongPressGestureRecognizer *)gestureRecognizer {
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            pointAudioStart = [gestureRecognizer locationInView:self.view];
            [self audioRecorderInit];
            [self audioRecorderStart];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            break;
        }
        case UIGestureRecognizerStateEnded: {
            CGPoint pointAudioStop = [gestureRecognizer locationInView:self.view];
            CGFloat distanceAudio = sqrtf(powf(pointAudioStop.x - pointAudioStart.x, 2) + pow(pointAudioStop.y - pointAudioStart.y, 2));
            [self audioRecorderStop:(distanceAudio < 50)];
            break;
        }
        case UIGestureRecognizerStatePossible:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            break;
    }
}

-(void)audioRecorderInit {
    NSString *dir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path = [dir stringByAppendingString:@"audioRecorder.mp3"];
    NSError *error;
    
    NSDictionary *settings = @{
                               AVFormatIDKey : @(kAudioFormatMPEG4AAC),
                               AVSampleRateKey : @(44100),
                               AVNumberOfChannelsKey : @(2)
                               };
    
    audioRecorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:path] settings:settings error:&error];
    audioRecorder.meteringEnabled = YES;
    
    [audioRecorder prepareToRecord];
}

-(void)audioRecorderStart {
    [audioRecorder record];
    
    dateAudioStart = [NSDate date];
    
    timerAudio = [NSTimer scheduledTimerWithTimeInterval:0.07 target:self selector:@selector(audioRecorderUpdate) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timerAudio forMode:NSRunLoopCommonModes];
    
    [self audioRecorderUpdate];
}

-(void)audioRecorderStop:(BOOL)sending {
    [audioRecorder stop];
    
    [timerAudio invalidate];
    timerAudio = nil;
    
    if ((sending) && ([[NSDate date] timeIntervalSinceDate:dateAudioStart] >= 1)) {
        
    } else {
        [audioRecorder deleteRecording];
    }
}

-(void)audioRecorderUpdate {
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:dateAudioStart];
    int millisec = (int) (interval * 100) % 100;
    int seconds = (int) interval % 60;
    int minutes = (int) interval / 60;
    //    labelInputAudio.text = [NSString stringWithFormat:@"%01d:%02d,%02d", minutes, seconds, millisec];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = self.title;
    
    self.node.tableNode.delegate = self; // actually redundant bc MXRMessenger sets it
    self.node.tableNode.dataSource = self;
    self.node.tableNode.allowsSelection = YES;
    
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(audioRecorderGesture:)];
    gesture.minimumPressDuration = 1;
    gesture.cancelsTouchesInView = NO;
    [self.toolbar.rightButtonsNode.view addGestureRecognizer:gesture];
    
    
    [self customizeCellFactory];
    [self fetchMessages];
}

- (void)customizeCellFactory {
    MXRMessageCellLayoutConfiguration* layoutConfigForMe = [MXRMessageCellLayoutConfiguration rightToLeft];
    MXRMessageCellLayoutConfiguration* layoutConfigForOthers = [MXRMessageCellLayoutConfiguration leftToRight];
    
    MXRMessageAvatarConfiguration* avatarConfigForMe = [[MXRMessageAvatarConfiguration alloc] init];
    MXRMessageAvatarConfiguration* avatarConfigForOthers = [[MXRMessageAvatarConfiguration alloc] init];
    
    MXRMessageTextConfiguration* textConfigForMe = [[MXRMessageTextConfiguration alloc] initWithFont:nil textColor:[UIColor whiteColor] backgroundColor:[UIColor mxr_fbMessengerBlue]];
    textConfigForMe.linkHighlightStyle = ASTextNodeHighlightStyleDark;
    MXRMessageTextConfiguration* textConfigForOthers = [[MXRMessageTextConfiguration alloc] initWithFont:nil textColor:[UIColor blackColor] backgroundColor:[UIColor mxr_bubbleLightGrayColor]];
    textConfigForOthers.linkHighlightStyle = ASTextNodeHighlightStyleLight;
    CGFloat maxCornerRadius = textConfigForMe.maxCornerRadius;
    
    MXRMessageImageConfiguration* imageConfig = [[MXRMessageImageConfiguration alloc] init];
    imageConfig.maxCornerRadius = maxCornerRadius;
    MXRMessageMediaCollectionConfiguration* mediaCollectionConfig = [[MXRMessageMediaCollectionConfiguration alloc] init];
    mediaCollectionConfig.maxCornerRadius = maxCornerRadius;
    
    MXRMessageAudioConfiguration *audioConfig = [[MXRMessageAudioConfiguration alloc] initWithBackgroundColor:[UIColor mxr_bubbleBlueGrey]];
    audioConfig.maxCornerRadius = maxCornerRadius;
    
    MXRMessageSystemConfiguration *systemConfig = [[MXRMessageSystemConfiguration alloc] initWithFont:nil textColor:[UIColor blueColor] backgroundColor:[UIColor mxr_bubbleBlueGrey]];
    
    textConfigForMe.menuItemTypes |= MXRMessageMenuItemTypeDelete;
    textConfigForOthers.menuItemTypes |= MXRMessageMenuItemTypeDelete;
    imageConfig.menuItemTypes |= MXRMessageMenuItemTypeDelete;
    imageConfig.showsUIMenuControllerOnLongTap = YES;
    CGFloat s = [UIScreen mainScreen].scale;
    imageConfig.borderWidth = s > 0 ? (1.0f/s) : 0.5f;
    
    MXRMessageCellConfiguration* cellConfigForMe = [[MXRMessageCellConfiguration alloc] initWithLayoutConfig:layoutConfigForMe avatarConfig:avatarConfigForMe textConfig:textConfigForMe imageConfig:imageConfig mediaCollectionConfig:mediaCollectionConfig systemConfig:systemConfig audioConfig:audioConfig];
    MXRMessageCellConfiguration* cellConfigForOthers = [[MXRMessageCellConfiguration alloc] initWithLayoutConfig:layoutConfigForOthers avatarConfig:avatarConfigForOthers textConfig:textConfigForOthers imageConfig:imageConfig mediaCollectionConfig:mediaCollectionConfig systemConfig:systemConfig audioConfig:audioConfig];
    
    self.cellFactory = [[MXRMessageCellFactory alloc] initWithCellConfigForMe:cellConfigForMe cellConfigForOthers:cellConfigForOthers];
    self.cellFactory.dataSource = self;
    self.cellFactory.contentNodeDelegate = self;
    self.cellFactory.mediaCollectionDelegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

#pragma mark - Target-Action

- (void)tapAddPhotos:(id)sender {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Photos!" message:@"You should present a photo picker here." preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)tapSend:(id)sender {
    NSString* text = [self.toolbar clearText];
    if (text.length == 0) return;
    Message* message = [[Message alloc] init];
    message.text = text;
    message.senderID = 0;
    message.timestamp = [NSDate date].timeIntervalSince1970;
    [self.messages insertObject:message atIndex:0];
    [self.cellFactory updateTableNode:self.node.tableNode animated:YES withInsertions:@[[NSIndexPath indexPathForRow:0 inSection:0]] deletions:nil reloads:nil completion:nil];
}

#pragma mark - MXMessageCellFactoryDataSource

- (BOOL)cellFactory:(MXRMessageCellFactory *)cellFactory isMessageFromMeAtRow:(NSInteger)row {
    return self.messages[row].senderID == 0;
}

- (NSURL *)cellFactory:(MXRMessageCellFactory *)cellFactory avatarURLAtRow:(NSInteger)row {
    return [self cellFactory:cellFactory isMessageFromMeAtRow:row] ? self.otherPersonsAvatar : self.otherPersonsAvatar;
}

- (NSTimeInterval)cellFactory:(MXRMessageCellFactory *)cellFactory timeIntervalSince1970AtRow:(NSInteger)row {
    return self.messages[row].timestamp;
}

#pragma mark - ASTable

- (NSInteger)tableNode:(ASTableNode *)tableNode numberOfRowsInSection:(NSInteger)section { return self.messages.count; }

- (ASCellNodeBlock)tableNode:(ASTableNode *)tableNode nodeBlockForRowAtIndexPath:(NSIndexPath *)indexPath {
    Message* message = self.messages[indexPath.row];
//    if (message.media.count > 1) {
//        return [self.cellFactory cellNodeBlockWithMedia:message.media tableNode:tableNode row:indexPath.row];
//    } else if (message.media.count == 1) {
//        MessageMedium* medium = message.media.firstObject;
//        return [self.cellFactory cellNodeBlockWithImageURL:medium.photoURL showsPlayButton:(medium.videoURL != nil) tableNode:tableNode row:indexPath.row];
//    } else {
//        return [self.cellFactory cellNodeBlockWithSystem:message.text tableNode:tableNode row:indexPath.row];
        return [self.cellFactory cellNodeBlockWithAudio:[NSURL URLWithString:@"http://devimages.apple.com/iphone/samples/bipbop/gear3/prog_index.m3u8"] tableNode:tableNode row:indexPath.row];
//    }
}

- (void)tableNode:(ASTableNode *)tableNode didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self dismissKeyboard];
    [tableNode deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - MXRMessageContentNodeDelegate

- (void)messageContentNode:(MXRMessageContentNode *)node didTapMenuItemWithType:(MXRMessageMenuItemTypes)menuItemType {
    if (menuItemType == MXRMessageMenuItemTypeDelete) {
        ASDisplayNode* supernode = [node supernode];
        if ([supernode isKindOfClass:[MXRMessageCellNode class]]) {
            [self deleteCellNode:(MXRMessageCellNode*)supernode];
        }
    }
}

- (void)messageContentNode:(MXRMessageContentNode *)node didSingleTap:(id)sender {
    if (![node.supernode isKindOfClass:[MXRMessageCellNode class]]) return;
    MXRMessageCellNode* cellNode = (MXRMessageCellNode*)node.supernode;
    if ([node isKindOfClass:[MXRMessageImageNode class]]) {
        // present a media viewer
        NSLog(@"Single tapped an image");
        return;
    } else if ([node isKindOfClass:[MXRMessageTextNode class]]) {
        NSLog(@"Single tapped text");
        [self.cellFactory toggleDateHeaderNodeVisibilityForCellNode:cellNode];
    }
}

- (void)messageContentNode:(MXRMessageContentNode*)node didTapURL:(NSURL*)url {
    NSLog(@"Tapped URL");
}

- (void)messageContentNode:(MXRMessageContentNode*)node didLongTapURL:(NSURL*)url {
    NSLog(@"Long-Tapped URL");
}

#pragma mark - MXMessageMediaCollectionNodeDelegate

- (void)messageMediaCollectionNode:(MXRMessageMediaCollectionNode *)messageMediaCollectionNode didSelectMedium:(id<MXRMessengerMedium>)medium atIndexPath:(NSIndexPath *)indexPath {
    // Show a media viewer
}

#pragma mark - Helper

- (void)deleteCellNode:(ASCellNode*)cellNode {
    NSIndexPath* indexPath = [cellNode indexPath];
    if (!indexPath) return;
    // delete cell in model
}

- (void)fetchMessages {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray* messages = [[NSMutableArray alloc] init];
        NSTimeInterval timestamp = [NSDate date].timeIntervalSince1970 - 3600;
        for (int i = 0; i < 20; i++) {
            Message* m = [Message randomMessage];
            m.timestamp = timestamp;
            timestamp -= arc4random_uniform(1200);
            [messages addObject:m];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.messages = messages;
            [self.node.tableNode reloadData];
        });
    });
}

@end
