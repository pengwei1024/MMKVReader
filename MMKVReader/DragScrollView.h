//
// Created by Peng,Wei(BAMRD) on 2020/10/25.
// Copyright (c) 2020 apkfuns.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^DragBlock)(NSArray *);

@interface DragScrollView : NSScrollView

@property(nonatomic, assign) BOOL isDragIn;

@property DragBlock dragListener;

@end

NS_ASSUME_NONNULL_END