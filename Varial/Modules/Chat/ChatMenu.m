//
//  ChatMenu.m
//  EJabberChat
//
//  Created by jagan on 24/05/16.
//  Copyright © 2016 Shanmuga priya. All rights reserved.
//

#import "ChatMenu.h"
#import "MediaComposing.h"
#import "MediaGallery.h"
#import "FriendProfile.h"
#import "FriendsChat.h"

@interface ChatMenu ()

@end

@implementation ChatMenu

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //Set model style
    self.view.backgroundColor = [UIColor clearColor];
    self.modalPresentationStyle = UIModalPresentationCurrentContext;
    self.modalPresentationStyle = UIModalPresentationFormSheet;
    
//    titleArray = [[NSMutableArray alloc]initWithObjects:NSLocalizedString(IMAGE,nil) ,NSLocalizedString(VIDEO, nil) , NSLocalizedString(MEDIA, nil) , NSLocalizedString(CAMERA, nil) , NSLocalizedString(PROFILE, nil) , nil];
//    imageArray = [[NSMutableArray alloc]initWithObjects:@"image.png", @"video.png" , @"mediagray.png" , @"cameraGrey.png" , @"profileGrey.png" , nil];
    
    titleArray = [[NSMutableArray alloc]initWithObjects:NSLocalizedString(IMAGE,nil) ,NSLocalizedString(VIDEO, nil) , NSLocalizedString(CAMERA, nil) , nil];
    imageArray = [[NSMutableArray alloc]initWithObjects:@"image.png", @"video.png" , @"cameraGrey.png" , nil];
    
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideMoreMenu:)];
    [self.view addGestureRecognizer:gestureRecognizer];

    for (NSLayoutConstraint *constraint in self.chatOptions.constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeTop) {
            constraint.constant = 80;
            [self.view layoutIfNeeded];
            break;
        }
    }
}

//Detect outside the touch of chat menus
- (void) hideMoreMenu:(UITapGestureRecognizer *)tapRecognizer{
 
    CGPoint point = [tapRecognizer locationInView:tapRecognizer.view];
    if (!CGRectContainsPoint(_chatOptions.frame, point)) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else{
        CGPoint tappedPoint = [tapRecognizer locationInView:_chatOptions];
        NSIndexPath *indexPath = [_chatOptions indexPathForItemAtPoint:tappedPoint];
        if (indexPath != nil) {
            [self collectionView:_chatOptions didSelectItemAtIndexPath:indexPath];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark CollectionView Delegates
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [titleArray count];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(collectionView.frame.size.width/3.2 , 80);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"optionCell" forIndexPath:indexPath];
    if(cell==nil)
        cell=[[[NSBundle mainBundle] loadNibNamed:@"optionCell" owner:self options:nil] objectAtIndex:0];
    
    cell.backgroundColor = [UIColor whiteColor];
    UIImageView *imag = (UIImageView *)[cell viewWithTag:10];
    UILabel *label = (UILabel *)[cell viewWithTag:11];
    
    UIImage *optionImage = [[UIImage imageNamed:[imageArray objectAtIndex:indexPath.row]] imageWithRenderingMode:UIImageRenderingModeAutomatic];
    imag.image = optionImage;
    label.text = [titleArray objectAtIndex:indexPath.row];
    
    return  cell;
}

-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = (UICollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
   
    UIImageView *imag = (UIImageView *)[cell viewWithTag:10];
    UILabel *label = (UILabel *)[cell viewWithTag:11];
    
    UIImage *optionImage = [[UIImage imageNamed:[imageArray objectAtIndex:indexPath.row]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    imag.image = optionImage;
    [imag setTintColor:[UIColor redColor]];
    [label setTextColor:[UIColor redColor]];
    
//    if (indexPath.row == 2)
//    {
//        
//        [self dismissViewControllerAnimated:YES completion:^{
//             UINavigationController *navigation = (UINavigationController *)[UIApplication sharedApplication].delegate.window.rootViewController;
//            FriendsChat *friendsChat = (FriendsChat *)[[navigation viewControllers] lastObject];
//            MediaGallery *media = [self.storyboard instantiateViewControllerWithIdentifier:@"MediaGallery"];
//            media.receiverID = friendsChat.receiverID;
//            media.receiverName = friendsChat.receiverName;
//            media.receiverImage = friendsChat.receiverImage;
//            media.isSingleChat = friendsChat.isSingleChat;
//            [navigation pushViewController:media animated:YES];
//        }];
//    }
    if(indexPath.row != 3)
    {
        UINavigationController *navigation = (UINavigationController *)[UIApplication sharedApplication].delegate.window.rootViewController;
        FriendsChat *friendsChat = (FriendsChat *)[[navigation viewControllers] lastObject];
        
        if (!friendsChat.isBlocked) {
            MediaComposing *photo = [self.storyboard instantiateViewControllerWithIdentifier:@"MediaComposing"];
            photo.type = (int) indexPath.row;
            [self dismissViewControllerAnimated:YES completion:^{
                UINavigationController *navigation = (UINavigationController *)[UIApplication sharedApplication].delegate.window.rootViewController;
                [navigation pushViewController:photo animated:YES];
            }];
        }
        else
        {
            [imag setTintColor:[UIColor grayColor]];
            [label setTextColor:[UIColor grayColor]];
        }
    }
    else if(indexPath.row == 4)
    {
        UINavigationController *navigation = (UINavigationController *)[UIApplication sharedApplication].delegate.window.rootViewController;
        FriendsChat *friendsChat = (FriendsChat *)[[navigation viewControllers] lastObject];
        
        if ([friendsChat.isSingleChat isEqualToString:@"TRUE"]) {
            FriendProfile *friendProfile = [self.storyboard instantiateViewControllerWithIdentifier:@"FriendProfile"];
            NSArray *friendIds = [_receiverID componentsSeparatedByString:@"_"];
            if ([friendIds count] > 0) {
                NSString *friendId = friendIds[0];
                friendProfile.friendId = friendId;
                friendProfile.friendName = _receiverName;
                [self dismissViewControllerAnimated:YES completion:^{
                    UINavigationController *navigation = (UINavigationController *)[UIApplication sharedApplication].delegate.window.rootViewController;
                    [navigation pushViewController:friendProfile animated:YES];
                }];
            }
        }
        else
        {
            // Nonmemberview Controller
            if ([_teamRelationID isEqualToString:@"4"]) {
                
                NonMemberTeamViewController *nonMember = [self.storyboard instantiateViewControllerWithIdentifier:@"NonMemberTeamViewController"];
                
                NSArray *teamIds = [_receiverID componentsSeparatedByString:@"_"];
                if ([teamIds count] > 0) {
                    NSString *teamId = teamIds[0];
                    nonMember.teamId = teamId;
                    [self dismissViewControllerAnimated:YES completion:^{
                        UINavigationController *navigation = (UINavigationController *)[UIApplication sharedApplication].delegate.window.rootViewController;
                        [navigation pushViewController:nonMember animated:YES];
                    }];
                }
            }
            else
            {
                TeamViewController *teamDetails = [self.storyboard instantiateViewControllerWithIdentifier:@"TeamViewController"];
                NSArray *teamIds = [_receiverID componentsSeparatedByString:@"_"];
                if ([teamIds count] > 0) {
                    NSString *teamId = teamIds[0];
                    teamDetails.teamId = teamId;
                    teamDetails.roomId = _receiverID;
                    
                    [self dismissViewControllerAnimated:YES completion:^{
                        UINavigationController *navigation = (UINavigationController *)[UIApplication sharedApplication].delegate.window.rootViewController;
                        [navigation pushViewController:teamDetails animated:YES];
                    }];
                }
            }
            
        }
    }
}


@end
