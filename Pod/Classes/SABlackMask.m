//
//  SABlackMask.m
//  Pods
//
//  Created by Gabriel Coman on 08/01/2016.
//
//

#import "SABlackMask.h"
#import "SAVideoPlayer.h"
#import "SAUtils.h"

@implementation SABlackMask

- (id) init {

    if (self = [super initWithImage:[UIImage imageWithContentsOfFile:[SAUtils filePathForName:@"mark"
                                                                                         type:@"png"
                                                                                    andBundle:@"SAVideoVLCPlayer"
                                                                                     andClass:self.classForCoder]]]) {
        
    }
    
    return self;
}

- (void) didMoveToSuperview {
    CGRect _parentFrame = self.superview.frame;
    self.alpha = 0.75f;
    self.frame = CGRectMake(0, _parentFrame.size.height - 40, _parentFrame.size.width, 40);
}
@end
