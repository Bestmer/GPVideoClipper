//
//  GPVideoPlayerView.m
//  GPVideoClipper
//
//  Created by Roc Kwok on 2020/5/6.
//  Copyright © 2020 Roc Kwok. All rights reserved.
//

#import "GPVideoPlayerView.h"

@interface GPVideoPlayerView()

@property (nonatomic, strong) AVPlayerLayer *avPlayer;
@property (nonatomic, strong) NSURL *videoURL;

@end

@implementation GPVideoPlayerView

- (instancetype)initWithFrame:(CGRect)frame videoURL:(NSURL *)videoURL {
    if (self = [super initWithFrame:frame]) {
        self.videoURL = videoURL;
        [self.layer addSublayer:self.avPlayer];
        self.avPlayer.frame = self.bounds;
        [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoDidPlayEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus status = self.playerItem.status;
        if (status == AVPlayerItemStatusReadyToPlay) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(gp_videoReadyToPlay)]) {
                [self.delegate gp_videoReadyToPlay];
            }
            [self.playerItem removeObserver:self forKeyPath:@"status"];
        } else {
            NSString *error = [NSString stringWithFormat:@"Video play failed:%@", keyPath];
            NSAssert(NO, error);
        }
    }
}

- (void)videoDidPlayEnd:(NSNotification *)notification {
    [self.player pause];
    [self.playerItem seekToTime:CMTimeMake(self.maker.startTime * 1000, 1000) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:nil];
    [self.player play];
}

#pragma mark - Public

- (void)play {
    [self.player play];
}

- (void)pause {
    [self.player pause];
}

#pragma mark - Private

- (AVPlayer *)player {
    if (!_player) {
        _player = [AVPlayer playerWithPlayerItem:self.playerItem];
    }
    return _player;
}

- (AVPlayerItem *)playerItem {
    if (!_playerItem) {
        _playerItem = [AVPlayerItem playerItemWithURL:self.videoURL];
    }
    return _playerItem;
}

- (AVPlayerLayer *)avPlayer {
    if (!_avPlayer) {
        _avPlayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    }
    return _avPlayer;
}

@end
