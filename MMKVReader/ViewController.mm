//
//  ViewController.m
//  MMKVReader
//
//  Created by Peng,Wei(BAMRD) on 2020/10/24.
//  Copyright © 2020 apkfuns.com. All rights reserved.
//

#import "ViewController.h"
#import "MMKV.h"

using namespace mmkv;

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    size_t x = 11;
    MMBuffer data(x);
    NSLog(@"size = %d", data.length());
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    // Update the view, if already loaded.
}


@end
