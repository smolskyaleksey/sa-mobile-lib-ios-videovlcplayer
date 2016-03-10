//
//  SABlackMask.m
//  Pods
//
//  Created by Gabriel Coman on 08/01/2016.
//
//

#import "SABlackMask.h"
#import "SAVideoPlayer.h"

@implementation SABlackMask

- (id) init {
    
    // get bundle
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"SAVideoVLCPlayer" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    
    if (self = [super initWithImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"mark" ofType:@"png"]]]) {
        
    }
    
    return self;
}

- (void) didMoveToSuperview {
    CGRect _parentFrame = self.superview.frame;
    self.alpha = 0.75f;
    self.frame = CGRectMake(0, _parentFrame.size.height - 40, _parentFrame.size.width, 40);
}
@end
