//
//  MXRMessageSystemNode.m
//  MXRMessenger
//
//  Created by Bruno Rendeiro on 18/12/17.
//

#import "MXRMessageSystemNode.h"

#import "UIImage+MXRMessenger.h"
#import "UIColor+MXRMessenger.h"
#import "MXRMessageContentNode+Subclasses.h"

@interface MXRMessageSystemNode () <ASTextNodeDelegate>

@end

@implementation MXRMessageSystemNode {
    MXRMessageSystemConfiguration* _configuration;
    UIRectCorner _cornersHavingRadius;
}

-(instancetype)initWithText:(NSString *)text configuration:(MXRMessageSystemConfiguration *)configuration cornersToApplyMaxRadius:(UIRectCorner)cornersHavingRadius {
    if (self = [super initWithConfiguration:configuration]) {
        self.automaticallyManagesSubnodes = YES;
        _configuration = configuration;
        
        _textNode = [[ASTextNode alloc] init];
        _textNode.layerBacked = YES;
        NSMutableAttributedString* attributedText = [[NSMutableAttributedString alloc] initWithString:(text ? : @"") attributes:_configuration.textAttributes];
        _textNode.attributedText = attributedText;
        _backgroundImageNode = [[ASImageNode alloc] init];
        _backgroundImageNode.layerBacked = YES;
        [self redrawBubble];
    }
    return self;
}

- (instancetype)init {
    ASDISPLAYNODE_NOT_DESIGNATED_INITIALIZER();
    return [self initWithText:nil configuration:nil cornersToApplyMaxRadius:UIRectCornerAllCorners];
}

- (instancetype)initWithConfiguration:(MXRMessageNodeConfiguration *)configuration {
    ASDISPLAYNODE_NOT_DESIGNATED_INITIALIZER();
    return [self initWithText:nil configuration:nil cornersToApplyMaxRadius:UIRectCornerAllCorners];
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
    ASInsetLayoutSpec* textInset = [ASInsetLayoutSpec insetLayoutSpecWithInsets:_configuration.textInset child:_textNode];
    return [ASBackgroundLayoutSpec backgroundLayoutSpecWithChild:textInset background:_backgroundImageNode];
}

- (void)didLoad {
    [super didLoad];
}

- (void)redrawBubble {
    [self redrawBubbleImageWithColor:_configuration.backgroundColor];
}

- (void)redrawBubbleImageWithColor:(UIColor*)color {
    _backgroundImageNode.image = [UIImage mxr_bubbleImageWithMaximumCornerRadius:_configuration.maxCornerRadius minimumCornerRadius:_configuration.minCornerRadius color:color cornersToApplyMaxRadius:_cornersHavingRadius];
}

#pragma mark - MXRMessageContentNode

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
}

- (void)setHighlighted:(BOOL)highlighted {
    BOOL didChange = highlighted != self.highlighted;
    [super setHighlighted:highlighted];
    if (didChange) {
        if (highlighted) {
            [self redrawBubbleImageWithColor:[_configuration.backgroundColor mxr_darkerColor]];
        } else {
            [self redrawBubbleImageWithColor:_configuration.backgroundColor];
        }
    }
}

- (void)setDelegate:(id<MXRMessageContentNodeDelegate>)delegate {
    [super setDelegate:delegate];
}

- (void)copy:(id)sender {
    [[UIPasteboard generalPasteboard] setString:self.textNode.attributedText.string];
    [super copy:sender];
}

- (void)redrawBubbleWithCorners:(UIRectCorner)cornersHavingRadius {
    _cornersHavingRadius = cornersHavingRadius;
    [self redrawBubble];
}

@end

@implementation MXRMessageSystemConfiguration

- (instancetype)init {
    return [self initWithFont:[UIFont systemFontOfSize:15] textColor:[UIColor blackColor] backgroundColor:[UIColor mxr_greyBotCell]];
}

- (instancetype)initWithFont:(UIFont *)font textColor:(UIColor *)textColor backgroundColor:(UIColor *)backgroundColor {
    return [self initWithTextAttributes:@{NSFontAttributeName: (font ? : [UIFont systemFontOfSize:15]), NSForegroundColorAttributeName: (textColor ? : [UIColor blackColor])} backgroundColor:backgroundColor];
}

- (instancetype)initWithTextAttributes:(NSDictionary *)attributes backgroundColor:(UIColor *)backgroundColor {
    self = [super init];
    if (self) {
        NSMutableDictionary* attrsMutable = [(attributes ? : @{}) mutableCopy];
        attrsMutable[NSFontAttributeName] = attrsMutable[NSFontAttributeName] ? : [UIFont systemFontOfSize:15];
        attrsMutable[NSForegroundColorAttributeName] = attrsMutable[NSForegroundColorAttributeName] ? : [UIColor blackColor];
        self.showsUIMenuControllerOnLongTap = YES;
        self.menuItemTypes |= MXRMessageMenuItemTypeCopy;
        self.backgroundColor = backgroundColor;
        _textAttributes = [attrsMutable copy];
        _textInset = UIEdgeInsetsMake(8, 12, 8, 12);
        [self setTextInset:UIEdgeInsetsMake(8, 12, 8, 12) adjustMaxCornerRadiusToKeepCircular:YES];
    }
    return self;
}

- (void)setTextInset:(UIEdgeInsets)textInset {
    [self setTextInset:textInset adjustMaxCornerRadiusToKeepCircular:YES];
}

- (void)setTextInset:(UIEdgeInsets)textInset adjustMaxCornerRadiusToKeepCircular:(BOOL)adjustMaxCornerRadius {
    _textInset = textInset;
    if (adjustMaxCornerRadius) {
        UIFont* font = self.textAttributes[NSFontAttributeName];
        if (font) {
            self.maxCornerRadius = (ceilf(font.lineHeight) + _textInset.top + _textInset.bottom)/2.0f;
        }
    }
}

@end

