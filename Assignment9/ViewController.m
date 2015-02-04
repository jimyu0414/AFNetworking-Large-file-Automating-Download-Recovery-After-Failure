//
//  ViewController.m
//  Assignment9
//
//  Created by yu on 14-5-25.
//  Copyright (c) 2014年 yu. All rights reserved.
//

#import "ViewController.h"
#import "AFURLSessionManager.h"
#import "AFHTTPSessionManager.h"
#import "AFHTTPRequestOperation.h"
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPRequestOperation.h"

@interface ViewController ()
{
    AFHTTPRequestOperation *op;
    AFHTTPRequestOperationManager *manager;
    AFNetworkReachabilityManager *network;
    NSUInteger downloadLength;
    NSString *downloadPath;
    UIAlertView *connectionAlert;
    NSOperationQueue *thequeue;
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.ProgressView setProgress:0 animated:NO];
    [self.ProgressShowLabel setText:@"0.00%"];
    
    downloadPath = @"/Users/Yu/Downloads/CDDMADOWNLOADSAMPLE/DownloadSample.dmg";
    //check file
    thequeue = [[NSOperationQueue alloc] init];
    [thequeue addOperation:op];
    manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://dldir1.qq.com/qqfile/QQforMac/QQ_V3.1.1.dmg"]];

    network = manager.reachabilityManager;
    //check the network status
    if ([[NSFileManager defaultManager] fileExistsAtPath:downloadPath]) {
        NSData *data = [[NSData alloc] initWithContentsOfFile:downloadPath];
        if (data.length > 0 ) {
            self.BtnDownload.enabled = NO;
            [self Resume:nil];
        }
    }
    [network setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status)
     {
         if(status == 2)
         {
             if (op != nil || op.isCancelled) {
//                 connectionAlert = [[UIAlertView alloc] initWithTitle:@"Connection Success" message:@"continue to download" delegate: self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//                 [connectionAlert show];
                 NSLog(@"Network Connected");
                 [self Resume:nil];
             }
         }
         if(status == 0||status == -1)
         {
             //connectionAlert = [[UIAlertView alloc] initWithTitle:@"Connection failed" message:@"Check wireless or 3G net" delegate: self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
             //[connectionAlert show];
             NSLog(@"No Network Connection");
             [op cancel];
         }
     }];
    
    [network startMonitoring];
    
    NSLog(@"%@",[network localizedNetworkReachabilityStatusString]);

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)Download:(id)sender {
    

        [self.ProgressView setProgress:0 animated:NO];
        [self.ProgressShowLabel setText:@"0.00%"];
        [self startDownload];
    self.BtnDownload.enabled = NO;
}

-(void)startDownload
{
    
    NSLog(@"%@",[network localizedNetworkReachabilityStatusString]);
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://dldir1.qq.com/qqfile/QQforMac/QQ_V3.1.1.dmg"]];
    op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.outputStream = [NSOutputStream outputStreamToFileAtPath:downloadPath append:NO];
    //Moniter download at begining
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSLog(@"Download Begin");
     }failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         if(!operation.isCancelled)
         {
             NSLog(@"Download Fail");
         }
     }];
    [self performSelectorOnMainThread:@selector(setProgressBar) withObject:nil waitUntilDone:NO];
    [op start];

}

-(void)setProgressBar{
    [op setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead)
     {
         CGFloat percentage = (CGFloat)totalBytesRead/totalBytesExpectedToRead;
         [self.ProgressView setProgress:percentage animated:YES];
         NSString *percentageDisplay = [NSString stringWithFormat:@"%.02f", percentage * 100];
         percentageDisplay = [percentageDisplay stringByAppendingString:@"%"];
         [self.ProgressShowLabel setText:percentageDisplay];
     }];
}

- (IBAction)Pause:(id)sender {
    [op cancel];
}

- (IBAction)Resume:(id)sender {
    NSLog(@"%@",[network localizedNetworkReachabilityStatusString]);
    if(op.isCancelled || op == nil)
    {
       // NSURLRequest *request = [NSURLRequest requestWithURL:[manager baseURL]];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://dldir1.qq.com/qqfile/QQforMac/QQ_V3.1.1.dmg"]];
        NSData *data = [[NSData alloc] initWithContentsOfFile:downloadPath];
        downloadLength = [data length];
        NSMutableURLRequest *mutableURLRequest = [request mutableCopy];
        NSString *requestRange = [NSString stringWithFormat:@"bytes=%u-", downloadLength];
        [mutableURLRequest setValue:requestRange forHTTPHeaderField:@"Range"];
        request = mutableURLRequest;
        op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        op.outputStream = [NSOutputStream outputStreamToFileAtPath:downloadPath append:YES];
        [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             NSLog(@"Download Succeed");
         }failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             if(!operation.isCancelled)
             {
                 NSLog(@"Resume Download Fail");
                 //[self Resume:sender];
             }
         }];
        [op setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead)
         {
             CGFloat percentage = (CGFloat)(totalBytesRead + downloadLength)/(totalBytesExpectedToRead + downloadLength);
             [self.ProgressView setProgress:percentage animated:YES];
             NSString *percentageDisplay = [NSString stringWithFormat:@"%.02f", percentage * 100];
             percentageDisplay = [percentageDisplay stringByAppendingString:@"%"];
             [self.ProgressShowLabel setText:percentageDisplay];
         }];
        [op start];
    }
    }

- (IBAction)Cancel:(id)sender {
    [op cancel];
    [self.ProgressView setProgress:0 animated:NO];
    [self.ProgressShowLabel setText:@"0.00%"];
    op = nil;
    [[NSFileManager defaultManager] removeItemAtPath:downloadPath error:nil];
    self.BtnDownload.enabled = YES;
}
@end
