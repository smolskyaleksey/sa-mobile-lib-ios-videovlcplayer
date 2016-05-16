//
//  SAURLClicker.h
//  Pods
//
//  Created by Gabriel Coman on 17/12/2015.
//
//

#import <UIKit/UIKit.h>

typedef enum ClickerStyle {
    Fullscreen = 0,
    Button = 1
} ClikerStyle;

//
// Class definition
@interface SAURLClicker : UIButton
@property (nonatomic, assign) enum ClickerStyle style;
@end
