//
//  ShopDetails.m
//  Varial
//
//  Created by Shanmuga priya on 3/15/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "ShopDetails.h"
#import "Util.h"

@interface ShopDetails ()

@end

@implementation ShopDetails
BOOL isChina;
- (void)viewDidLoad {
    [super viewDidLoad];
    isChina = FALSE;
    [self designTheView];
    [self getOfferDetails];
    [self showMap];
    [_googleMap setHidden:YES];
    [_baiduMap setHidden:YES];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)designTheView
{
    [_containerView setHidden:YES];
    [_containerView setBackgroundColor:[UIColor clearColor]];
    [_headerView setHeader: NSLocalizedString(SHOP_DETAILS, nil)];
    [_headerView.logo setHidden:YES];
   
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(deviceOrientationDidChange:) name: UIDeviceOrientationDidChangeNotification object: nil];
    [self setTabBarColor];

    _addressLabel.numberOfLines=0;
    _tabBar.delegate=self;
    [_tabBar setSelectedItem:_tabTwo];
    [_googleMap setHidden:YES];
    [_baiduMap setHidden:YES];
    [_offerDescription setHidden:NO];
    _offerDescription.contentMode = UIViewContentModeTopLeft;
    [[Util sharedInstance] addImageZoom:_imageView];
    [Util createBorder:_tabBar withColor:UIColorFromHexCode(THEME_COLOR)];
    
}

-(void)setTabBarColor
{
    // Tab Bar
    [_tabBar setTintColor:[UIColor whiteColor]];
    [_tabBar setSelectionIndicatorImage:[Util convertColorToImage:UIColorFromHexCode(THEME_COLOR) byDivide:2 withHeight:60]];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIFont fontWithName:@"CenturyGothic" size:13], NSFontAttributeName,
                                [UIColor whiteColor], NSForegroundColorAttributeName, nil];
    
    [[UITabBarItem appearance] setTitleTextAttributes:attributes forState:UIControlStateNormal];
}

- (void)deviceOrientationDidChange:(NSNotification *)notification
{
    [self setTabBarColor];
    self.tabBar.itemPositioning = UITabBarItemPositioningFill;
}

-(void)getOfferDetails{
    
    //Send offer list from shop request
    //Build Input Parameters
    NSMutableDictionary *inputParams = [[NSMutableDictionary alloc] init];
    [inputParams setValue:[Util getFromDefaults:@"auth_token"] forKey:@"auth_token"];
    [inputParams setValue:_offerId forKey:@"offer_id"];
    [[Util sharedInstance]  sendHTTPPostRequest:inputParams withRequestUrl:OFFER_DETAILS withCallBack:^(NSDictionary * response){
        if([[response valueForKey:@"status"] boolValue]){
            if(mediaBase == nil)
                mediaBase = [response valueForKey:@"media_base_url"];
            
            offerDetail=[response objectForKey:@"offers_details"];
            NSString *profileUrl = [NSString stringWithFormat:@"%@%@",mediaBase,[offerDetail valueForKey:@"shop_image_thumb"]];
            
            [_imageView setImageWithURL:[NSURL URLWithString:profileUrl] placeholderImage:[UIImage imageNamed:IMAGE_HOLDER_SHOP]];
            _name.text = [offerDetail valueForKey:@"offer_name"];
            _addressLabel.text = [offerDetail valueForKey:@"shop_address"];
            _offerDescription.text = [offerDetail valueForKey:@"offer_description"];
            [_offerDescription sizeToFit];
            
            
            [_offerDescriptionView loadHTMLString:[offerDetail valueForKey:@"offer_description"] baseURL:nil];
            [_offerDescriptionView setBackgroundColor:[UIColor blackColor]];
            
            [_tabBar.items objectAtIndex:1].title = [NSString stringWithFormat:NSLocalizedString(VALID_UPTO, nil),[Util getDate:[[offerDetail valueForKey:@"valid_timestamp"] longLongValue]]];
            
            latitude = [offerDetail valueForKey:@"latitude"];
            longitude = [offerDetail valueForKey:@"longitude"];
            
            [_containerView setHidden:NO];
            [self getDirections];
            
        }
        else{
            [[AlertMessage sharedInstance] showMessage:[response valueForKey:@"message"]];
        }
    } isShowLoader:YES];
    
}

//Called it when location updates
- (void) updateLocation:(NSNotification *) data{
    [[LocationManager sharedManager] stopUpdateLocation];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LocationUpdated" object:nil];
}

//Get direction based on country
- (void)getDirections{
    
    NSString *country = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"country_code"]];
    // IF ch or zh is an CHINA
    if([country isEqualToString:@"cn"] || [country isEqualToString:@"zh"]){
        CLLocationCoordinate2D source,destination;
        source = [[LocationManager sharedManager] locationCoordinate];
        destination.latitude = [latitude longLongValue];
        destination.longitude = [longitude longLongValue];
        [baiduMap RouteSearchFromCurrentLocaton:source destination:destination withName:_name.text withCityName:_addressLabel.text isFrom:@"Shops"];
    }
    else{
        NSMutableDictionary *locationInfo = [[NSMutableDictionary alloc] init];
        [locationInfo setValue:_name.text forKey:@"name"];
        [locationInfo setValue:_addressLabel.text forKey:@"subTitle"];
        [locationInfo setValue:latitude forKey:@"latitude"];
        [locationInfo setValue:longitude forKey:@"longitude"];
        //    [locationInfo setValue:@"12.9912" forKey:@"latitude"];
        //    [locationInfo setValue:@"80.2363" forKey:@"longitude"];
        [_googleMap getDirections:locationInfo forModule:@"ClubPromotions"];
    }
}


-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    if(item.tag==1){
        [_offerDescription setHidden:YES];
        if (isChina) {
            [_baiduMap setHidden:NO];
            [_googleMap setHidden:YES];
        }
        else{
            [_baiduMap setHidden:YES];
            [_googleMap setHidden:NO];
        }
    }
    else{
        [_offerDescription setHidden:NO];
        [_baiduMap setHidden:YES];
        [_googleMap setHidden:YES];
    }
}


// Show Map based the Location
-(void)showMap
{
    [[LocationManager sharedManager] startUpdateLocation];
    
    NSString *country = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"country_code"]];
    
    // IF ch or zh is an CHINA
    if([country isEqualToString:@"cn"] || [country isEqualToString:@"zh"]){
        
        [_baiduMap setHidden:NO];
        [_googleMap setHidden:YES];
        
        // Start Update location Service
        // Show Alert if location service is disabled
        [[LocationManager sharedManager] startUpdateLocation];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLocation:) name:@"LocationUpdated" object:nil];
        if( ![Util checkLocationIsEnabled] )
        {
            [[Util sharedInstance] showLocationAlert];
        }
        
        [self showBaiduMap];
        isChina = TRUE;
    }
    else{
        [_baiduMap setHidden:YES];
        [_googleMap setHidden:NO];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLocation:) name:@"LocationUpdated" object:nil];
        [[LocationManager sharedManager] startUpdateLocation];
        if( ![Util checkLocationIsEnabled] )
        {
            [[Util sharedInstance] showLocationAlert];
        }
        isChina = FALSE;
    }
}

// If Current user is China show the Baidu Map
-(void)showBaiduMap
{
    // CUSTOM MAPVIEW
    baiduMap = [[BaiduMap alloc] initWithFrame:CGRectMake(2, 2, _baiduMap.bounds.size.width - 4, _baiduMap.bounds.size.height - 4)];
    baiduMap.delegate = self;
    baiduMap.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_baiduMap addSubview:baiduMap];    
    
}

// BaiduMap Delegate
-(void)RouteSearchResults : (NSArray *)searchResults
{
    if ([searchResults count] == 0)
    {
        [[AlertMessage sharedInstance] showMessage:NSLocalizedString(NO_ROUTESEARCH_FOR_SHOP, nil)];
    }
}

- (void)didSelectAnnotaion:(BMKMapView *)mapView annotation:(BMKAnnotationView *)annotation
{
    
}

- (void)didSelectAnnotaionViewBubble:(BMKAnnotationView *)mapViewbubble
{
    
}



@end
