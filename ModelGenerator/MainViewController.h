//
//  MainViewController.h
//  ModelGenerator
//
//  Created by zhubch on 15/8/11.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MainViewController : NSViewController

@property (unsafe_unretained) IBOutlet NSTextView *codeTextView;

@property (unsafe_unretained) IBOutlet NSTextView *jsonTextView;

@property (unsafe_unretained) IBOutlet NSTextField *placeHolder;

@property (weak) IBOutlet NSTextField *classNameField;

@property (weak) IBOutlet NSComboBox *comboBox;

@property (weak) IBOutlet NSButton *startBtn;

- (IBAction)generate:(id)sender;

- (IBAction)selectedLanguage:(id)sender;

@end

