//
//  SAVideoPlayer.m
//  Pods
//
//  Created by Gabriel Coman on 05/03/2016.
//
//

#import "SAVideoPlayer.h"
#import "SABlackMask.h"
#import "SACronograph.h"
#import <MobileVLCKit/MobileVLCKit.h>

// shorthand for notifs
#define ENTER_BG UIApplicationDidEnterBackgroundNotification
#define ENTER_FG UIApplicationWillEnterForegroundNotification

@interface SAVideoPlayer () <VLCMediaPlayerDelegate>

// subviews
@property (nonatomic, strong) UIView *videoView;
@property (nonatomic, strong) VLCMediaPlayer *mediaplayer;
@property (nonatomic, strong) UIView *chrome;
@property (nonatomic, strong) SABlackMask *mask;
@property (nonatomic, strong) SACronograph *chrono;
@property (nonatomic, strong) SAURLClicker *clicker;

// states
@property (nonatomic, assign) BOOL isReadyHandled;
@property (nonatomic, assign) BOOL isStartHandled;
@property (nonatomic, assign) BOOL isFirstQuartileHandled;
@property (nonatomic, assign) BOOL isMidpointHandled;
@property (nonatomic, assign) BOOL isThirdQuartileHandled;
@property (nonatomic, assign) BOOL isEndHandled;

// times
@property (nonatomic, assign) BOOL isTimeCalculated;
@property (nonatomic, assign) NSInteger duration;
@property (nonatomic, assign) NSInteger firstq;
@property (nonatomic, assign) NSInteger midpoint;
@property (nonatomic, assign) NSInteger thirdq;

// notification center reference
@property (nonatomic, strong) NSNotificationCenter *notif;

@end

@implementation SAVideoPlayer

#pragma mark <Init>

- (id) init {
    if (self = [super init]) {
        _notif = [NSNotificationCenter defaultCenter];
        _shouldShowSmallClickButton = false;
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _notif = [NSNotificationCenter defaultCenter];
        _shouldShowSmallClickButton = false;
    }
    return self;
}

- (id) initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _notif = [NSNotificationCenter defaultCenter];
        _shouldShowSmallClickButton = false;
    }
    return self;
}

#pragma mark <Check handling>

- (void) resetChecks {
    _isStartHandled =
    _isFirstQuartileHandled =
    _isMidpointHandled =
    _isThirdQuartileHandled =
    _isEndHandled = false;
    _isTimeCalculated = false;
    _duration = _firstq = _midpoint =  _thirdq = 0;
}

#pragma mark <Setup> functions

- (void) setup {
    self.backgroundColor = [UIColor blackColor];
    [self setupPlayer];
    [self setupChome];
    [self resetChecks];
}

- (void) setupPlayer {
    // subview that will display the player
    _videoView = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:_videoView];
    
    // video player
    _mediaplayer = [[VLCMediaPlayer alloc] initWithOptions:@[[NSString stringWithFormat:@"--%@=%@",@"extraintf",@""]]];
    _mediaplayer.drawable = _videoView;
    _mediaplayer.delegate = self;
    
    // notifications
    [_notif addObserver:self selector:@selector(didEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [_notif addObserver:self selector:@selector(didEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void) setupChome {
    _chrome = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:_chrome];
    
    _mask = [[SABlackMask alloc] init];
    [_chrome addSubview:_mask];
    
    _chrono = [[SACronograph alloc] init];
    [_chrome addSubview:_chrono];
    
    _clicker = [[SAURLClicker alloc] init];
    _clicker.shouldShowSmallClickButton = _shouldShowSmallClickButton;
    [_clicker addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
    [_chrome addSubview:_clicker];
}

#pragma mark <Destroy> functions

- (void) destroy {
    [self destroyPlayer];
    [self destroyChrome];
}

- (void) destroyPlayer {
    // remove observers
    [_notif removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [_notif removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];

    // remove player
    if (_mediaplayer) {
        [_mediaplayer stop];
        _mediaplayer = NULL;
    }
    
    // remove the video view
    [_videoView removeFromSuperview];
    _videoView = NULL;
}

- (void) destroyChrome {
    [_mask removeFromSuperview];
    [_chrono removeFromSuperview];
    [_clicker removeTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
    [_clicker removeFromSuperview];
    [_chrome removeFromSuperview];
    _mask = NULL;
    _clicker = NULL;
    _chrono = NULL;
    _chrome = NULL;
}

#pragma mark <Update> functions

- (void) updateToFrame:(CGRect)frame {
    self.frame = frame;
    _videoView.frame = self.bounds;
    _chrome.frame = self.bounds;
    [self destroyChrome];
    [self setupChome];
}

- (void) reset {
    [self destroy];
    [self setup];
}

- (void) didEnterBackground {
    NSLog(@"enter background");
    [_mediaplayer pause];
}

- (void) didEnterForeground {
    NSLog(@"enter foreground");
    [_mediaplayer play];
}

#pragma mark <Play> function

- (void) playWithMediaURL:(NSURL *)url {
    [self setup];
    _mediaplayer.media = [VLCMedia mediaWithURL:url];
    [_mediaplayer play];
}

#pragma mark <Click> function

- (void) onClick:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(didGoToURL)]) {
        [_delegate didGoToURL];
    }
}

#pragma mark <VLCMediaPlayer> delegate

- (void) mediaPlayerStateChanged:(NSNotification *)aNotification {
    VLCMediaPlayer *player = (VLCMediaPlayer*)[aNotification object];
    NSInteger state = player.state;
    
    if ((state == VLCMediaPlayerStateBuffering || state == VLCMediaPlayerStatePlaying) &&
        !_isReadyHandled && _delegate && [_delegate respondsToSelector:@selector(didFindPlayerReady)]) {
        _isReadyHandled = true;
        [_delegate didFindPlayerReady];
    }
}

- (void) mediaPlayerTimeChanged:(NSNotification *)aNotification {
    // update the current time in the chronograph
    VLCMediaPlayer *player = (VLCMediaPlayer*)[aNotification object];
    
    // start sending out events
    if (!_isTimeCalculated) {
        _isTimeCalculated = true;
        _duration = [self getSeconds:player.remainingTime.intValue];
        _firstq = (NSInteger)(_duration / 4);
        _midpoint = (NSInteger)(_duration / 2);
        _thirdq = (NSInteger)(3 * _duration / 4);
        NSLog(@"Duration: %ld", _duration);
    }
    
    // send out other events
    NSInteger remaining = [self getSeconds:player.remainingTime.intValue];
    NSInteger current = [self getSeconds:player.time.intValue];
    
    if (current >= 1 && !_isStartHandled && _delegate && [_delegate respondsToSelector:@selector(didStartPlayer)]){
        _isStartHandled = true;
        [_delegate didStartPlayer];
    }
    if (current >= _firstq && !_isFirstQuartileHandled && _delegate && [_delegate respondsToSelector:@selector(didReachFirstQuartile)]){
        _isFirstQuartileHandled = true;
        [_delegate didReachFirstQuartile];
    }
    if (current >= _midpoint && !_isMidpointHandled && _delegate && [_delegate respondsToSelector:@selector(didReachMidpoint)]){
        _isMidpointHandled = true;
        [_delegate didReachMidpoint];
    }
    if (current >= _thirdq && !_isThirdQuartileHandled && _delegate && [_delegate respondsToSelector:@selector(didReachThirdQuartile)]){
        _isThirdQuartileHandled = true;
        [_delegate didReachThirdQuartile];
    }
    if (current >= _duration && !_isEndHandled && _delegate && [_delegate respondsToSelector:@selector(didReachEnd)]){
        _isEndHandled = true;
        [_delegate didReachEnd];
    }
    
    // update interface
    [_chrono setTime:remaining];
    
}

- (NSInteger) getSeconds:(int)miliseconds {
    return (NSInteger)(fabsf(miliseconds / 1000.0f));
}

- (VLCMediaPlayer*) getPlayer {
    return _mediaplayer;
}

#pragma mark <Dealloc>

- (void) dealloc {
    NSLog(@"SAVideoPlayer dealloc");
}

@end
