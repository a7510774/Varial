//
//  InAppPurchaseManager.h
//  Varial
//
//  Created by jagan on 17/02/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "YesNoPopup.h"
#import "KLCPopup.h"
#import "NetworkAlert.h"
#import "MBProgressHUD.h"
#import "Util.h"


@interface InAppPurchaseManager : NSObject<SKProductsRequestDelegate, SKPaymentTransactionObserver>{
    
    SKProduct *product;
    SKProductsRequest *productsRequest;
    KLCPopup *productNotFoundPopup;
    NetworkAlert *productNotFound;
    MBProgressHUD *loader;
    
}

+ (instancetype) sharedInstance;
- (BOOL)canMakePurchases;
- (void)purchaseProduct:(NSString *)productId;

@end
