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
    NSBundle *podBundle = [NSBundle bundleForClass:self.classForCoder];
    NSURL *bundleUrl = [podBundle URLForResource:@"SAVideoVLCPlayer" withExtension:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithURL:bundleUrl];
    NSString *file = [bundle pathForResource:@"mark" ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:file];
    
    if (self = [super initWithImage:image]) {
        
    }
    
    return self;
}

- (void) didMoveToSuperview {
    CGRect _parentFrame = self.superview.frame;
    self.alpha = 0.75f;
    self.frame = CGRectMake(0, _parentFrame.size.height - 40, _parentFrame.size.width, 40);
}
@end
