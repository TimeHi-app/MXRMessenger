//
//  _MXRMessengerInputToolbarContainerView.m
//  Mixer
//
//  Created by Scott Kensell on 3/18/17.
//  Copyright © 2017 Two To Tango. All rights reserved.
//

#import <MXRMessenger/_MXRMessengerInputToolbarContainerView.h>

static NSString* MXRNewCalculatedSizeNotification = @"MXRNewCalculatedSizeNotification";



@implementation MXRMessengerInputToolbarContainerView {
    id _newSizeNotification;
}

- (instancetype)initWithMessengerInputToolbar:(MXRMessengerInputToolbar *)toolbarNode constrainedSize:(ASSizeRange)constrainedSize andNode:(ASDisplayNode *)node {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _toolbarNode = toolbarNode;
        
        _containerNode = [[MXRNewSizeNotifyingNode alloc] init];
        _containerNode.innerNode = _toolbarNode;
        _containerNode.node = node;
        [_toolbarNode layoutSpecThatFits:constrainedSize];
        [_containerNode layoutThatFits:constrainedSize];
        _containerNode.frame = CGRectMake(0, 0, _containerNode.calculatedSize.width, _containerNode.calculatedSize.height);
        self.frame = _containerNode.frame;
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight; // NOTE: Do not set flexibleHeight on Node too, creates bugs.
        
        CALayer* iphoneXHackyLayer = [[CALayer alloc] init];
        iphoneXHackyLayer.backgroundColor = [toolbarNode.backgroundColor CGColor];
        iphoneXHackyLayer.frame = CGRectMake(0, 0, self.frame.size.width, 10*self.frame.size.height);
        [self.layer addSublayer:iphoneXHackyLayer];
        
        [self addSubview:_containerNode.view];
        
        __weak typeof(self) weakSelf = self;
        _newSizeNotification = [[NSNotificationCenter defaultCenter] addObserverForName:MXRNewCalculatedSizeNotification object:_containerNode queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            [weakSelf invalidateIntrinsicContentSize];
        }];
    }
    return self;
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    if (@available(iOS 11, *)) {
        NSLayoutYAxisAnchor* systemBottomAnchor = self.window.safeAreaLayoutGuide.bottomAnchor;
        if (systemBottomAnchor) {
            [self.bottomAnchor constraintLessThanOrEqualToSystemSpacingBelowAnchor:systemBottomAnchor multiplier:1.0f].active = YES;
        }
    }
}

- (void)dealloc { [[NSNotificationCenter defaultCenter] removeObserver:_newSizeNotification]; }
- (CGSize)intrinsicContentSize { return _containerNode.calculatedSize; }

@end


@implementation MXRNewSizeNotifyingNode {
    CGSize _previouslyCalculatedSize;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.automaticallyManagesSubnodes = YES;
    }
    return self;
}

- (void)calculatedLayoutDidChange {
    [super calculatedLayoutDidChange];
    if (!CGSizeEqualToSize(_previouslyCalculatedSize, self.calculatedSize)) {
        _previouslyCalculatedSize = self.calculatedSize;
        [[NSNotificationCenter defaultCenter] postNotificationName:MXRNewCalculatedSizeNotification object:self];
    }
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
    NSMutableArray *verticalChildren = [NSMutableArray array];
    
    ASStackLayoutSpec *containerStack = [ASStackLayoutSpec verticalStackLayoutSpec];
    
    if (_node)
        [verticalChildren addObject:[ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsMake(10, 0, 0, 0) child:_node]];
    [verticalChildren addObject:[ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsZero child:_innerNode]];
    
    containerStack.children = verticalChildren;
    
    return containerStack;
}

@end
