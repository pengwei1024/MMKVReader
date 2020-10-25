//
//  ViewController.m
//  MMKVReader
//
//  Created by Peng,Wei(BAMRD) on 2020/10/24.
//  Copyright © 2020 apkfuns.com. All rights reserved.
//

#import "ViewController.h"
#import "MMKV.h"
#import "DragScrollView.h"
#import "CodedInputData.h"

using namespace mmkv;

@implementation ViewController {
    MMKV *mmkv;
    // tableView 对象
    NSTableView *_tableView;
    // tableView 展示 key 列表数据
    NSMutableArray *_dataArray;
    // tableView 展示 value 列表数据
    NSMutableArray *_showArray;
    // tableView 展示 类型 列表数据
    NSArray *typeArray;
}

/**
 * 弹出提示框
 * @param message 展示消息
 */
- (void)alertMessage:(NSString *)message {
    NSAlert *alert = [NSAlert alertWithMessageText:@"提示" defaultButton:@"确定" alternateButton:nil otherButton:nil informativeTextWithFormat:message];
    [alert runModal];
}

/**
 * 弹出输入密码提示框
 * @param prompt 提示框标题
 * @return
 */
- (NSString *)inputBox:(NSString *)prompt {
    NSAlert *alert = [NSAlert alertWithMessageText:prompt
                                     defaultButton:@"OK"
                                   alternateButton:@"Cancel"
                                       otherButton:nil
                         informativeTextWithFormat:@""];
    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
    [alert setAccessoryView:input];
    NSInteger button = [alert runModal];
    if (button == NSAlertDefaultReturn) {
        [input validateEditing];
        return [input stringValue];
    } else if (button == NSAlertAlternateReturn) {
        return nil;
    } else {
        return nil;
    }
}

/**
 * 加载 mmkv 文件并刷新列表
 * @param name 文件名称
 */
- (void)loadFile:(std::string)name {
    NSString *cryptKey = [self inputBox:@"请输入加密key, 如果没有加密请直接确认"];
    std::string key = cryptKey ? [cryptKey UTF8String] : "";
    if (mmkv) {
        mmkv->close();
    }
    mmkv = MMKV::mmkvWithID(name, MMKV_SINGLE_PROCESS, &key);
    [_dataArray removeAllObjects];
    [_showArray removeAllObjects];
    for (id key in mmkv->allKeys()) {
        [_dataArray addObject:key];
        [_showArray addObject:@""];
    }
    [_tableView reloadData];
    NSLog(@"loadFile size=%ld", mmkv->actualSize());
}

/**
 * 初始化 View
 */
- (void)initView {
    NSString *rootPath = [NSHomeDirectory() stringByAppendingPathComponent:@"files"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    DragScrollView *tableContainer = [[DragScrollView alloc] init];
    tableContainer.frame = self.view.bounds;
    tableContainer.dragListener = ^(NSArray *array) {
        NSLog(@"拖拽文件地址%@", array);
        if (array.count != 2) {
            [self alertMessage:@"请同时拖入MMKV数据文件和crc文件"];
            return;
        }
        NSString *crcFile = array[0];
        NSString *dataFile = array[1];
        if (![crcFile containsString:@".crc"]) {
            crcFile = array[1];
            dataFile = array[0];
        }
        if (![crcFile containsString:dataFile]) {
            [self alertMessage:@"MMKV数据文件和crc文件不匹配"];
        }
        NSArray *fileArray = @[crcFile, dataFile];
        NSError *error = nil;
        for (id file in fileArray) {
            NSString *dstPath = [rootPath stringByAppendingPathComponent:
                    [fileManager displayNameAtPath:file]];
            if ([fileManager fileExistsAtPath:dstPath]) {
                [fileManager removeItemAtPath:dstPath error:nil];
            }
            [fileManager copyItemAtPath:file toPath:dstPath error:&error];
        }
        [self loadFile:[[fileManager displayNameAtPath:dataFile] UTF8String]];
    };
    _tableView = [[NSTableView alloc] initWithFrame:self.view.bounds];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [tableContainer setDocumentView:_tableView];
    [tableContainer setHasVerticalScroller:YES];
    tableContainer.autoresizingMask = NSViewHeightSizable | NSViewWidthSizable;
    [[self view] addSubview:tableContainer];
    // 初始化 table column
    NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:@"key"];
    column.title = @"key";
    column.resizingMask = NSTableColumnUserResizingMask;
    column.minWidth = 200;
    NSTableColumn *column2 = [[NSTableColumn alloc] initWithIdentifier:@"dataType"];
    column2.title = @"dataType";
    NSTableColumn *column3 = [[NSTableColumn alloc] initWithIdentifier:@"value"];
    column3.title = @"value";
    column3.minWidth = 400;

    column2.width = 100;
    column2.headerToolTip = @"提示";
    column2.hidden = NO;
    column2.sortDescriptorPrototype = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:NO];
    column.resizingMask = NSTableColumnUserResizingMask;

    [_tableView addTableColumn:column];
    [_tableView addTableColumn:column2];
    [_tableView addTableColumn:column3];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    typeArray = @[@"选择类型", @"string", @"bool", @"int",
            @"float", @"double", @"long", @"bytes", @"Set<String>"];
    _dataArray = [NSMutableArray array];
    _showArray = [NSMutableArray array];
    [self initView];
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    // Update the view, if already loaded.
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return _dataArray.count;
}

- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    NSView *view = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    if (view != nil) {
        return view;
    }
    if ([tableColumn.identifier isEqualToString:@"key"] || [tableColumn.identifier isEqualToString:@"value"]) {
        NSTextField *field = [[NSTextField alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
        field.backgroundColor = [NSColor clearColor];
        field.identifier = tableColumn.identifier;
        field.preferredMaxLayoutWidth = field.frame.size.width;
        return field;
    } else if ([tableColumn.identifier isEqualToString:@"dataType"]) {
        NSPopUpButton *popUpButton = [[NSPopUpButton alloc] initWithFrame:CGRectMake(100, 400, 200, 300)];
        //设置弹出菜单
        NSString *title = [[NSString alloc] initWithFormat:@"%ld", row];
        NSMenu *menu = [[NSMenu alloc] initWithTitle:title];
        for (int i = 0; i < typeArray.count; ++i) {
            [menu addItemWithTitle:typeArray[i] action:@selector(menuClick:) keyEquivalent:@""];
        }
        popUpButton.menu = menu;
        return popUpButton;
    }
    return view;
}

- (void)menuClick:(id)sender {
    NSMenuItem *item = sender;
    NSUInteger row = static_cast<NSUInteger>([item.menu.title intValue]);
    NSInteger index = [typeArray indexOfObject:item.title];
    NSString *key = _dataArray[static_cast<NSUInteger>(row)];
    NSLog(@"CLICK key=%@, selectIndex=%@, index=%li", key, item.title, index);
    switch (index) {
        case 1: {
            NSString *valueString = static_cast<NSString *>(mmkv->getObject(key, [NSString class]));
            if (!valueString) {
                valueString = @"";
            }
            _showArray[row] = valueString;
            NSLog(@"string=%@", _showArray[row]);
            break;
        }
        case 2: {
            bool readBool = mmkv->getBool(key, false);
            _showArray[row] = readBool ? @"true" : @"false";
            break;
        }
        case 3: {
            int32_t readInt = mmkv->getInt32(key, 0);
            _showArray[row] = [NSString stringWithFormat:@"%d", readInt];
            break;
        }
        case 4: {
            float readFloat = mmkv->getFloat(key, 0);
            NSLog(@"%f", readFloat);
            _showArray[row] = [NSString stringWithFormat:@"%f", readFloat];
            break;
        }
        case 5: {
            double readDouble = mmkv->getDouble(key, 0);
            NSLog(@"%f", readDouble);
            _showArray[row] = [NSString stringWithFormat:@"%f", readDouble];
            break;
        }
        case 6: {
            int64_t readLong = mmkv->getInt64(key, 0);
            NSLog(@"%lli", readLong);
            _showArray[row] = [NSString stringWithFormat:@"%lli", readLong];
            break;
        }
        case 7: {
            MMBuffer buffer = mmkv->getDataForKey(key);
            auto ptr = (uint8_t *) buffer.getPtr();
            NSString *result = [[NSString alloc] init];
            for (int i = 0; i < buffer.length(); ++i) {
                result = [result stringByAppendingString:[NSString stringWithFormat:@"%@", [[NSString alloc] initWithFormat:@"%1lx ", *(ptr + i)]]];
            }
            _showArray[row] = result;
            NSLog(@"string=%@", result);
            break;
        }
        case 8: {
            MMBuffer buffer = mmkv->getDataForKey(key);
            CodedInputData inputData(buffer.getPtr(), buffer.length());
            std::vector<std::string> result;
            inputData.readInt32();
            while (!inputData.isAtEnd()) {
                std::string value = [inputData.readString() UTF8String];
                result.push_back(value);
            }
            NSString *stringResult = @"";
            size_t count = result.size();
            for (int i = 0; i < count; i++) {
                stringResult = [stringResult stringByAppendingString:
                        [NSString stringWithFormat:@"[%d]: %s\n", i, result[i].c_str()]];
            }
            _showArray[row] = stringResult;
            break;
        }
        default:
            break;
    }
    [_tableView reloadData];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if ([tableColumn.identifier isEqualToString:@"key"]) {
        return _dataArray[row];
    } else if ([tableColumn.identifier isEqualToString:@"value"]) {
        return _showArray[row];
    } else {
        return nil;
    }
}

/**
 * 子串出现的次数
 * @param substring 子串
 * @param s 完整字符串
 * @return 出现次数
 */
- (NSInteger)countOfSubstring:(NSString *)substring inString:(NSString *)s {
    NSArray *ary = [s componentsSeparatedByString:substring];
    NSString *str = [ary componentsJoinedByString:@""];
    NSUInteger sCount = s.length;
    NSUInteger strCount = str.length;
    NSUInteger count = (sCount - strCount) / substring.length;
    return count;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    NSString *val = _showArray[row];
    NSInteger count = [self countOfSubstring:@"\n" inString:val];
    NSInteger fontSize = 14;
    if (count > 2) {
        return fontSize * count;
    } else if (val.length > 100) {
        return fontSize * (val.length % 100 + 1);
    }
    return 25;
}


@end
