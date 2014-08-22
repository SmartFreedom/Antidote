//
//  ChatFileCell.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 14.08.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "ChatFileCell.h"
#import "UIView+Utilities.h"
#import "UIColor+Utilities.h"

static const CGFloat kCellHeight = 50.0;
static const NSTimeInterval kAnimationDuration = 0.5;

typedef NS_ENUM(NSUInteger, TypeImageViewType) {
    TypeImageViewTypeNone,
    TypeImageViewTypeBasic,
    TypeImageViewTypeDeleted,
    TypeImageViewTypeCanceled,
};

typedef NS_ENUM(NSUInteger, PlayPauseImageType) {
    PlayPauseImageTypeNone,
    PlayPauseImageTypePlay,
    PlayPauseImageTypePause,
};

@interface ChatFileCell()

@property (strong, nonatomic) UIImageView *typeImageView;

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *descriptionLabel;

@property (strong, nonatomic) UIButton *yesButton;
@property (strong, nonatomic) UIButton *noButton;

@property (strong, nonatomic) UIProgressView *progressView;
@property (strong, nonatomic) UIButton *playPauseButton;

@property (assign, nonatomic) TypeImageViewType currentTypeImageViewType;
@property (assign, nonatomic) PlayPauseImageType currentPlayPauseImageType;

@end

@implementation ChatFileCell

#pragma mark -  Lifecycle

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];

    if (self) {
        [self createTypeImageView];
        [self createLabels];
        [self createYesNoButtons];
        [self createProgressViews];
    }

    return self;
}

#pragma mark -  Actions

- (void)yesButtonPressed
{
    [self.delegate chatFileCell:self answerButtonPressedWith:YES];
}

- (void)noButtonPressed
{
    [self.delegate chatFileCell:self answerButtonPressedWith:NO];
}

- (void)playPauseButtonPressed
{

}

#pragma mark -  Public

- (void)redrawAnimated:(BOOL)animated
{
    CGRect oldTitleLabelFrame = self.titleLabel.frame;
    CGRect oldDescriptionLabelFrame = self.descriptionLabel.frame;
    CGRect oldNoButtonFrame = self.noButton.frame;

    // order matters
    [self updateTypeImageViewAnimated:animated];
    [self updateYesButton];
    [self updateNoButton];
    [self updateTitleLabel];
    [self updateDescriptionLabel];
    [self updatePlayPauseButton];
    [self updateProgressViewAnimated:animated];

    CGRect newTitleLabelFrame = self.titleLabel.frame;
    CGRect newNoButtonFrame = self.noButton.frame;
    CGRect newDescriptionLabelFrame = self.descriptionLabel.frame;

    BOOL animateTitleLabel = ! CGRectEqualToRect(oldTitleLabelFrame, newTitleLabelFrame);
    BOOL animateNoButton   = ! CGRectEqualToRect(oldNoButtonFrame,   newNoButtonFrame);

    BOOL animateDescriptionLabel = self.descriptionLabel.alpha &&
        ! CGPointEqualToPoint(oldDescriptionLabelFrame.origin, newDescriptionLabelFrame.origin);

    if (animated && (animateTitleLabel || animateDescriptionLabel || animateNoButton)) {
        if (animateTitleLabel) {
            self.titleLabel.frame = oldTitleLabelFrame;
        }
        if (animateDescriptionLabel) {
            self.descriptionLabel.alpha = 0.0;
        }
        if (animateNoButton) {
            self.noButton.frame = oldNoButtonFrame;
        }

        self.userInteractionEnabled = NO;

        [UIView animateWithDuration:kAnimationDuration animations:^{
            [self changeHiddenForSubview];

            if (animateTitleLabel) {
                self.titleLabel.frame = newTitleLabelFrame;
            }
            if (animateDescriptionLabel) {
                self.descriptionLabel.alpha = 1.0;
            }
            if (animateNoButton) {
                self.noButton.frame = newNoButtonFrame;
            }

        } completion:^(BOOL f) {
            self.userInteractionEnabled = YES;
        }];
    }
    else {
        [self changeHiddenForSubview];
    }
}

- (void)redrawLoadingPercentOnlyAnimated:(BOOL)animated
{
    [self updateDescriptionLabel];
    [self updateProgressViewAnimated:animated];
}

+ (CGFloat)height
{
    return kCellHeight;
}

+ (NSString *)reuseIdentifier
{
    return NSStringFromClass([self class]);
}

#pragma mark -  Private

- (void)createTypeImageView
{
    self.typeImageView = [[UIImageView alloc] init];
    self.typeImageView.tintColor = [UIColor uColorOpaqueWithWhite:150];
    [self.contentView addSubview:self.typeImageView];
}

- (void)createLabels
{
    self.titleLabel = [self.contentView addLabelWithTextColor:[UIColor blackColor] bgColor:[UIColor clearColor]];
    self.titleLabel.font = [AppearanceManager fontHelveticaNeueWithSize:14];

    self.descriptionLabel = [self.contentView addLabelWithTextColor:[UIColor blackColor] bgColor:[UIColor clearColor]];
    self.descriptionLabel.textColor = [UIColor uColorOpaqueWithWhite:160];
    self.descriptionLabel.font = [AppearanceManager fontHelveticaNeueLightWithSize:12];
}

- (void)createYesNoButtons
{
    UIImage *yesImage = [UIImage imageNamed:@"chat-file-download"];
    yesImage = [yesImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    UIImage *noImage = [UIImage imageNamed:@"chat-file-cancel"];
    noImage = [noImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    CGRect frame = CGRectZero;
    frame.size = yesImage.size;

    self.yesButton = [[UIButton alloc] initWithFrame:frame];
    [self.yesButton setImage:yesImage forState:UIControlStateNormal];
    [self.yesButton addTarget:self action:@selector(yesButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    self.yesButton.tintColor = [AppearanceManager statusOnlineColor];
    [self.contentView addSubview:self.yesButton];

    frame.size = noImage.size;

    self.noButton = [[UIButton alloc] initWithFrame:frame];
    [self.noButton setImage:noImage forState:UIControlStateNormal];
    [self.noButton addTarget:self action:@selector(noButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    self.noButton.tintColor = [AppearanceManager statusBusyColor];
    [self.contentView addSubview:self.noButton];
}

- (void)createProgressViews
{
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.progressView.progressTintColor = [AppearanceManager textMainColor];
    self.progressView.trackTintColor = [UIColor uColorOpaqueWithWhite:160];
    [self.contentView addSubview:self.progressView];

    self.playPauseButton = [UIButton new];
    self.playPauseButton.tintColor = [AppearanceManager textMainColor];
    [self.playPauseButton addTarget:self
                             action:@selector(playPauseButtonPressed)
                   forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.playPauseButton];

    self.currentPlayPauseImageType = PlayPauseImageTypeNone;
}

- (void)updatePlayPauseImageWith:(PlayPauseImageType)imageType
{
    if (self.currentPlayPauseImageType == imageType) {
        return;
    }
    self.currentPlayPauseImageType = imageType;

    UIImage *image = nil;

    if (imageType == PlayPauseImageTypePlay) {
        image = [UIImage imageNamed:@"chat-file-play"];
    }
    else if (imageType == PlayPauseImageTypePause) {
        image = [UIImage imageNamed:@"chat-file-pause"];
    }

    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    [self.playPauseButton setImage:image forState:UIControlStateNormal];
}

- (void)changeHiddenForSubview
{
    if (self.type == ChatFileCellTypeIncomingWaitingConfirmation) {
        self.descriptionLabel.alpha = 1.0;

        self.yesButton.alpha = 1.0;
        self.noButton.alpha = 1.0;

        self.progressView.alpha = 0.0;
        self.playPauseButton.alpha = 0.0;
    }
    else if (self.type == ChatFileCellTypeIncomingDownloading) {
        self.descriptionLabel.alpha = 1.0;

        self.yesButton.alpha = 0.0;
        self.noButton.alpha = 1.0;

        self.progressView.alpha = 1.0;
        self.playPauseButton.alpha = 1.0;
    }
    else if (self.type == ChatFileCellTypeIncomingLoaded) {
        self.descriptionLabel.alpha = 0.0;

        self.yesButton.alpha = 0.0;
        self.noButton.alpha = 0.0;

        self.progressView.alpha = 0.0;
        self.playPauseButton.alpha = 0.0;
    }
    else if (self.type == ChatFileCellTypeIncomingDeleted ||
             self.type == ChatFileCellTypeIncomingCanceled)
    {
        self.descriptionLabel.alpha = 1.0;

        self.yesButton.alpha = 0.0;
        self.noButton.alpha = 0.0;

        self.progressView.alpha = 0.0;
        self.playPauseButton.alpha = 0.0;
    }
}

- (void)updateTypeImageViewAnimated:(BOOL)animated
{
    TypeImageViewType newType = TypeImageViewTypeBasic;

    if (self.type == ChatFileCellTypeIncomingDeleted) {
        newType = TypeImageViewTypeDeleted;
    }
    else if (self.type == ChatFileCellTypeIncomingCanceled) {
        newType = TypeImageViewTypeCanceled;
    }

    if (self.currentTypeImageViewType != newType) {
        self.currentTypeImageViewType = newType;

        UIImage *image = nil;

        if (newType == TypeImageViewTypeBasic) {
            image = [UIImage imageNamed:@"chat-file-type-basic"];
        }
        else if (newType == TypeImageViewTypeDeleted) {
            image = [UIImage imageNamed:@"chat-file-type-deleted"];
        }
        else if (newType == TypeImageViewTypeCanceled) {
            image = [UIImage imageNamed:@"chat-file-type-canceled"];
        }

        self.typeImageView.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

        if (animated) {
            CATransition *transition = [CATransition animation];
            transition.duration = kAnimationDuration;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            transition.type = kCATransitionMoveIn;

            [self.typeImageView.layer addAnimation:transition forKey:nil];
        }
    }

    CGRect frame = CGRectZero;
    frame.size = self.typeImageView.image.size;
    frame.origin.x = 20.0;
    frame.origin.y = (kCellHeight - frame.size.height) / 2;
    self.typeImageView.frame = frame;
}

- (void)updateYesButton
{
    if (self.type != ChatFileCellTypeIncomingWaitingConfirmation) {
        return;
    }

    CGRect frame = self.yesButton.frame;
    frame.origin.x = self.frame.size.width - frame.size.width - 20.0;
    frame.origin.y = (kCellHeight - frame.size.height) / 2;
    self.yesButton.frame = frame;
}

- (void)updateNoButton
{
    if (self.type != ChatFileCellTypeIncomingWaitingConfirmation &&
        self.type != ChatFileCellTypeIncomingDownloading)
    {
        return;
    }

    CGRect frame = self.noButton.frame;
    frame.origin.y = (kCellHeight - frame.size.height) / 2;

    if (self.type == ChatFileCellTypeIncomingWaitingConfirmation) {
        frame.origin.x = CGRectGetMinX(self.yesButton.frame) - frame.size.width - 20.0;
    }
    else if (self.type == ChatFileCellTypeIncomingDownloading) {
        frame.origin.x = self.frame.size.width - frame.size.width - 20.0;
    }

    self.noButton.frame = frame;
}

- (void)updateTitleLabel
{
    self.titleLabel.text = self.fileName;

    if (self.type == ChatFileCellTypeIncomingWaitingConfirmation ||
        self.type == ChatFileCellTypeIncomingDownloading ||
        self.type == ChatFileCellTypeIncomingDeleted ||
        self.type == ChatFileCellTypeIncomingCanceled)
    {
        self.titleLabel.textColor = [UIColor blackColor];
    }
    else if (self.type == ChatFileCellTypeIncomingLoaded) {
        self.titleLabel.textColor = [AppearanceManager textMainColor];
    }

    [self.titleLabel sizeToFit];
    CGRect frame = self.titleLabel.frame;
    frame.origin.x = CGRectGetMaxX(self.typeImageView.frame) + 5.0;

    if (self.type == ChatFileCellTypeIncomingWaitingConfirmation ||
        self.type == ChatFileCellTypeIncomingDownloading)
    {
        frame.origin.y = self.typeImageView.frame.origin.y;
        frame.size.width = CGRectGetMinX(self.noButton.frame) - frame.origin.x - 5.0;
    }
    else if (self.type == ChatFileCellTypeIncomingDeleted ||
            self.type == ChatFileCellTypeIncomingCanceled)
    {
        frame.origin.y = self.typeImageView.frame.origin.y;
        frame.size.width = self.contentView.frame.size.width - frame.origin.x - 5.0;
    }
    else if (self.type == ChatFileCellTypeIncomingLoaded) {
        frame.origin.y = (kCellHeight - frame.size.height) / 2;
        frame.size.width = self.contentView.frame.size.width - frame.origin.x - 5.0;
    }

    self.titleLabel.frame = frame;
}

- (void)updateDescriptionLabel
{
    if (self.type != ChatFileCellTypeIncomingWaitingConfirmation &&
        self.type != ChatFileCellTypeIncomingDownloading &&
        self.type != ChatFileCellTypeIncomingDeleted &&
        self.type != ChatFileCellTypeIncomingCanceled)
    {
        return;
    }

    if (self.type == ChatFileCellTypeIncomingWaitingConfirmation) {
        self.descriptionLabel.text = self.fileSize;

    }
    else if (self.type == ChatFileCellTypeIncomingDownloading) {
        self.descriptionLabel.text = [NSString stringWithFormat:@"%d%%", (int) (self.loadedPercent * 100)];
    }
    else if (self.type == ChatFileCellTypeIncomingDeleted) {
        self.descriptionLabel.text = NSLocalizedString(@"Deleted", @"Chat");
    }
    else if (self.type == ChatFileCellTypeIncomingCanceled) {
        self.descriptionLabel.text = NSLocalizedString(@"Canceled", @"Chat");
    }

    [self.descriptionLabel sizeToFit];
    CGRect frame = self.descriptionLabel.frame;
    frame.origin.y = CGRectGetMaxY(self.typeImageView.frame) - frame.size.height;

    if (self.type == ChatFileCellTypeIncomingWaitingConfirmation ||
        self.type == ChatFileCellTypeIncomingDeleted ||
        self.type == ChatFileCellTypeIncomingCanceled)
    {
        frame.origin.x = self.titleLabel.frame.origin.x;
    }
    else if (self.type == ChatFileCellTypeIncomingDownloading) {
        frame.origin.x = CGRectGetMinX(self.noButton.frame) - self.descriptionLabel.frame.size.width - 5.0;
    }

    self.descriptionLabel.frame = frame;
}

- (void)updatePlayPauseButton
{
    if (self.type != ChatFileCellTypeIncomingDownloading) {
        return;
    }

    [self updatePlayPauseImageWith:self.isPaused ? PlayPauseImageTypePause : PlayPauseImageTypePlay];

    CGRect frame = CGRectZero;
    frame.size = self.playPauseButton.imageView.image.size;
    frame.origin.x = self.titleLabel.frame.origin.x - 4.0;
    frame.origin.y = CGRectGetMaxY(self.typeImageView.frame) - frame.size.height + 5.0;
    self.playPauseButton.frame = frame;
}

- (void)updateProgressViewAnimated:(BOOL)animated
{
    if (self.type != ChatFileCellTypeIncomingDownloading) {
        return;
    }

    [self.progressView setProgress:self.loadedPercent animated:animated];

    CGRect frame = self.progressView.frame;
    frame.size.height = 10.0;
    frame.origin.x = CGRectGetMaxX(self.playPauseButton.frame) + 5.0;
    frame.origin.y = CGRectGetMinY(self.playPauseButton.frame) +
        self.playPauseButton.frame.size.width - frame.size.height - 3.0;
    frame.size.width = CGRectGetMinX(self.descriptionLabel.frame) - frame.origin.x - 10.0;
    self.progressView.frame = frame;
}

@end