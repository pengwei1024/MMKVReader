//
// Created by Peng,Wei(BAMRD) on 2020/10/25.
// Copyright (c) 2020 apkfuns.com. All rights reserved.
//


#import "DragScrollView.h"

@implementation DragScrollView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
    if (_isDragIn) {
    }
    // Drawing code here.
}

- (NSDragOperation)draggingEntered:(id)sender {
    _isDragIn = YES;
    [self setNeedsDisplay:YES];
    return NSDragOperationCopy;
}

- (void)draggingExited:(id)sender {
    _isDragIn = NO;
    [self setNeedsDisplay:YES];
}

- (BOOL)prepareForDragOperation:(id)sender {
    _isDragIn = NO;
    [self setNeedsDisplay:YES];
    return YES;
}

- (BOOL)performDragOperation:(id)sender {
    if ([sender draggingSource] != self) {
        NSArray *filePaths = [[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType];
        if (_dragListener != nil) {
            _dragListener(filePaths);
        }
    }
    return YES;
}

@end
