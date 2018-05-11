//
//  Menu.h
//  TableViewAnimation
//
//  Created by Shanmuga priya on 5/9/16.
//  Copyright © 2016 Shanmuga priya. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol MenuDelegate
-(void)menuActionForIndex:(int)tag;
@end
@interface Menu : UIView
{
    float height;
    NSArray *buttonTitles,*exeArray;
}
@property (assign) id<MenuDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIView *menuContainer;
@property (weak, nonatomic) IBOutlet UIView *titleBorder;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

-(id)initWithViews:(NSString *)title buttonTitle:(NSMutableArray*)array   withImage:(NSMutableArray*)imgArray;


@end
