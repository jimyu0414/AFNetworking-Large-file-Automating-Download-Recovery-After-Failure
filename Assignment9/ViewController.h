//
//  ViewController.h
//  Assignment9
//
//  Created by yu on 14-5-25.
//  Copyright (c) 2014年 yu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *ProgressShowLabel;
@property (weak, nonatomic) IBOutlet UIButton *BtnDownload;
@property (weak, nonatomic) IBOutlet UIProgressView *ProgressView;
- (IBAction)Download:(id)sender;
- (IBAction)Pause:(id)sender;
- (IBAction)Resume:(id)sender;
- (IBAction)Cancel:(id)sender;
@end
