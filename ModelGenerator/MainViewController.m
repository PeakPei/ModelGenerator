//
//  MainViewController.m
//  ModelGenerator
//
//  Created by zhubch on 15/8/11.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import "MainViewController.h"
#import "ModelGenerator.h"
#import "ClassViewController.h"

@interface MainViewController ()<ClassViewControllerDelegate,NSComboBoxDataSource,NSTextViewDelegate>

@end

@implementation MainViewController
{
    ModelGenerator *generater;
    id objectToResolve;
    NSString *result;
    NSArray *languageArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.preferredContentSize = CGSizeMake(700, 400);
    
    languageArray = @[@"Objective-C",@"Swift",@"Java"];
    generater = [ModelGenerator sharedGenerator];
    
    [_jsonTextView becomeFirstResponder];
    

    _comboBox.placeholderAttributedString = [[NSAttributedString alloc]initWithString:@"Language" attributes:@{NSFontAttributeName: [NSFont labelFontOfSize:14],NSForegroundColorAttributeName:[NSColor disabledControlTextColor]}];
    _classNameField.placeholderAttributedString = [[NSAttributedString alloc]initWithString:@"ClassName" attributes:@{NSFontAttributeName: [NSFont labelFontOfSize:14],NSForegroundColorAttributeName:[NSColor disabledControlTextColor]}];
    _startBtn.attributedTitle = [[NSAttributedString alloc]initWithString:@"Start" attributes:@{NSFontAttributeName: [NSFont fontWithName:@"Times New Roman" size:16],NSForegroundColorAttributeName:[NSColor whiteColor]}];
    _comboBox.stringValue = @"Objective-C";
    generater.language = ObjectiveC;
    [self makeRound:_comboBox];
    [self makeRound:_classNameField];
    [self makeRound:_startBtn];
}

- (void)makeRound:(NSView*)view{
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = 10;
    view.layer.borderWidth = 5;
    view.layer.borderColor = [NSColor whiteColor].CGColor;
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}

- (IBAction)generate:(id)sender {
//    NSLog(@"%@",_classNameField.stringValue);
    if (self.jsonTextView.textStorage.string.length == 0) {
        NSAlert *alert = [[NSAlert alloc]init];
        alert.messageText = @"请先输入要转换的Json文本";
        [alert addButtonWithTitle:@"好的"];
        alert.alertStyle = NSWarningAlertStyle;
        [alert runModal];
        return;
    }
    if (_classNameField.stringValue.length == 0) {
        NSAlert *alert = [[NSAlert alloc]init];
        alert.messageText = @"请输入要生成的类名";
        [alert addButtonWithTitle:@"好的"];
        alert.alertStyle = NSWarningAlertStyle;
        [alert runModal];
        return;
    }
    if (generater.language == Unknow) {
        NSAlert *alert = [[NSAlert alloc]init];
        alert.messageText = @"请选择语言";
        [alert addButtonWithTitle:@"好的"];
        alert.alertStyle = NSWarningAlertStyle;
        [alert runModal];
        return;
    }
    generater.className = _classNameField.stringValue;
    NSError *error = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[_jsonTextView.textStorage.string dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    if (error) {
        NSAlert *alert = [[NSAlert alloc]init];
        alert.messageText = @"无效的Json数据";
        [alert addButtonWithTitle:@"好的"];
        alert.alertStyle = NSWarningAlertStyle;
        [alert runModal];
        return;
    }
    self.codeTextView.editable = YES;
    [self.codeTextView insertText:@"" replacementRange:NSMakeRange(0, self.codeTextView.textStorage.string.length)];
    
    dispatch_async(dispatch_queue_create("generate", DISPATCH_QUEUE_CONCURRENT), ^{
        NSString *code = [generater generateModelFromDictionary:dic withBlock:^NSString *(id unresolvedObject) {

            objectToResolve = unresolvedObject;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performSegueWithIdentifier:@"showModal" sender:self];
            });
            result = nil;
            
            while (result == nil) {
                sleep(0.1);
            }
            return result;
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.codeTextView insertText:code replacementRange:NSMakeRange(0, 1)];
            self.codeTextView.editable = NO;
        });

    });
}

- (IBAction)selectedLanguage:(NSComboBox*)sender {
    if (sender.indexOfSelectedItem < languageArray.count) {
        generater.language = sender.indexOfSelectedItem;
    }
}

- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showModal"]) {
        ClassViewController *vc = segue.destinationController;
        vc.objectToResolve = objectToResolve;
        vc.delegate = self;
    }
}

#pragma mark NSTextViewDelegate

- (BOOL)textView:(NSTextView *)textView shouldChangeTextInRanges:(NSArray<NSValue *> *)affectedRanges replacementStrings:(nullable NSArray<NSString *> *)replacementStrings{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _placeHolder.hidden = textView.textStorage.string.length > 0;
    });
    return YES;
}

#pragma mark ClassViewControllerDelegate

- (void)didResolvedWithClassName:(NSString *)name
{
    if (generater.language == ObjectiveC && ![name hasSuffix:@"*"]) {
        name = [name stringByAppendingString:@"*"];
    }
    result = name;
//    NSLog(@"%@",result);
}

#pragma mark NSComboBoxDelegate & NSComboBoxDataSource

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox
{
    return languageArray.count;
}

- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index
{
    return languageArray[index];
}

@end
