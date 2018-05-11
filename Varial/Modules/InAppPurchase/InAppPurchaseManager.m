//
//  InAppPurchaseManager.m
//  Varial
//
//  Created by jagan on 17/02/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import "InAppPurchaseManager.h"


@implementation InAppPurchaseManager

+ (instancetype) sharedInstance{
    static InAppPurchaseManager *inAPP = nil;
    @synchronized(self) {
        if (inAPP == nil) {
            inAPP = [[self alloc] init];
            [inAPP createAlertPopups];
        }
    }
    return inAPP;
}

- (void)createAlertPopups{
    
    productNotFound = [[NetworkAlert alloc] init];
    [productNotFound setNetworkHeader:NSLocalizedString(POINTS, nil)];
    productNotFound.subTitle.text = NSLocalizedString(POINTS_NOT_FOUND, nil);
    
    productNotFoundPopup = [KLCPopup popupWithContentView:productNotFound showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:YES];
}


//Send purchase the product request
- (void)purchaseProduct:(NSString *)productId{    
    NSSet *productIdentifiers = [NSSet setWithObject:productId ];
    productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    productsRequest.delegate = self;
    [productsRequest start];
    loader = [Util showLoading];
}

//Check can we made purcahse
- (BOOL)canMakePurchases
{
    return [SKPaymentQueue canMakePayments];
}

#pragma mark SKProductsRequestDelegate methods
// called when the transaction status is updated
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
            default:
                break;
        }
    }
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSArray *products = response.products;
    product = [products count] == 1 ? [products firstObject] : nil;
    if (product)
    {
        NSLog(@"Product title: %@" , product.localizedTitle);
        NSLog(@"Product description: %@" , product.localizedDescription);
        NSLog(@"Product price: %@" , product.price);
        NSLog(@"Product id: %@" , product.productIdentifier);
        
        //Send product payment request
        SKPayment *payment = [SKPayment paymentWithProduct:product];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
    else{
        [productNotFoundPopup show];
        [Util hideLoading:loader];
    }
    
    for (NSString *invalidProductId in response.invalidProductIdentifiers)
    {
        [Util hideLoading:loader];
        [productNotFoundPopup show];
        NSLog(@"Invalid product id: %@" , invalidProductId);
    }
    
}


// removes the transaction from the queue and posts a notification with the transaction result
- (void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)wasSuccessful
{
    // remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    NSLog(@"Transaction Data: %@",transaction);;
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:transaction, @"transaction" , nil];
    if (wasSuccessful)
    {
        NSLog(@"Transaction success");
        NSLog(@"Transaction Data: %@",userInfo);
        NSLog(@"Transaction identifier: %@",transaction.transactionIdentifier);
        NSLog(@"Transaction state %ld",transaction.transactionState);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TransactionCompleted" object:nil userInfo:userInfo];
        // send out a notification that we’ve finished the transaction
    }
    else
    {
        NSLog(@"Transaction failed");
         [[NSNotificationCenter defaultCenter] postNotificationName:@"TransactionCompleted" object:nil userInfo:nil];
        // send out a notification for the failed transaction
    }
    [Util hideLoading:loader];
}


// called when the transaction was successful
- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"Transaction finished");
    [self finishTransaction:transaction wasSuccessful:YES];
}


// called when a transaction has been restored and and successfully completed
- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"Transaction restore");
    [self finishTransaction:transaction wasSuccessful:YES];
}


// called when a transaction has failed
- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        // error!
        NSLog(@"Transaction failed");
        [self finishTransaction:transaction wasSuccessful:NO];
    }
    else
    {
        NSLog(@"Transaction Canceled");
        // this is fine, the user just cancelled, so don’t notify
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TransactionCompleted" object:nil userInfo:nil];
    }
    [Util hideLoading:loader];
}



@end
