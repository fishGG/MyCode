//
//  MainViewController.m
//  PushTestTool
//
//  Created by Fish on 14-5-16.
//  Copyright (c) 2014年 Fish. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

@synthesize certificatePath;
@synthesize deviceToken;
@synthesize payload;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}



@end
