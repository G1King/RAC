//
//  ViewController.m
//  RAC
//
//  Created by Joshua on 2017/6/9.
//  Copyright © 2017年 SPIC. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveCocoa.h>
#import <ReactiveCocoa/RACDelegateProxy.h>
@interface People : NSObject
@property (nonatomic,copy) NSString * name;
@end

@implementation People



@end
@interface ViewController ()
@property (nonatomic,strong) UILabel * nameLbl;
@property (nonatomic,strong) People * people;

@property (nonatomic) RACDelegateProxy * proxy;
@end

@implementation ViewController
{
    UITextField * _textfield;
    UITextField * _textfield1;
    
    UIButton * _loginBt;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
   
    // test RAC-KVO
//    [self testRAC_kvo];
    
    // test textfiled
//    [self testTextFiled];
    
    // test button
//    [self testLoginBt];
    // test delegate
//    [self delegateDemo];
    
    //NSNotificationCenter
    [self notifaction];
}
-(void)notifaction{
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillChangeFrameNotification object:nil] subscribeNext:^(id x) {
        NSLog(@"我是键盘啊");
    }];
}
-(void)delegateDemo{
    _textfield = [[UITextField alloc]initWithFrame:CGRectMake(100, 200, 100, 40)];
    _textfield.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:_textfield];
    _textfield1= [[UITextField alloc]initWithFrame:CGRectMake(200, 200, 100, 40)];
    _textfield1.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:_textfield1];
    

    self.proxy = [[RACDelegateProxy alloc]initWithProtocol:@protocol(UITextFieldDelegate)];
    
    [[self.proxy rac_signalForSelector:@selector(textFieldShouldReturn:)] subscribeNext:^(id x) {
        if ([_textfield hasText]) {
            [_textfield1 becomeFirstResponder];
        }
    }];
    _textfield.delegate  = (id<UITextFieldDelegate>)self.proxy;

}
-(void)testLoginBt{
    _loginBt = [[UIButton alloc]initWithFrame:CGRectMake(40, 40, 40, 40)];
    [_loginBt setTitle:@"click" forState:UIControlStateNormal];
    [_loginBt setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [[_loginBt rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        NSLog(@"click me");
    }];
    [self.view addSubview:_loginBt];
}
-(void)testTextFiled{
    _textfield = [[UITextField alloc]initWithFrame:CGRectMake(100, 200, 100, 40)];
    _textfield.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:_textfield];
    _textfield1= [[UITextField alloc]initWithFrame:CGRectMake(200, 200, 100, 40)];
    _textfield1.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:_textfield1];
    
//    [[_textfield rac_textSignal]subscribeNext:^(id x) {
//        NSLog(@"_textfield====>%@",x);
//    }];
    // 文本框组合
    
    id _textfieldSet = @[[_textfield rac_textSignal],[_textfield1 rac_textSignal]];
    [[RACSignal combineLatest: _textfieldSet] subscribeNext:^(RACTuple * x) {
        
        NSString * one = [x first];
        NSString * two = [x second];
        if ((one.length > 0) && (two.length > 0)) {
            NSLog(@"name==%@ password==%@",one,two);
        }else{
            NSLog(@"不能登录");
        }
    }];
}
-(void)testRAC_kvo{
    self.nameLbl = [[UILabel alloc]initWithFrame:CGRectMake(100, 100, 60, 60)];
    self.nameLbl.textColor = [UIColor redColor];
    [self.view addSubview:self.nameLbl];
    @weakify(self)
    [RACObserve(self.people, name) subscribeNext:^(id x) {
        @strongify(self)
        if (!self) {
            return ;
        }
        self.nameLbl.text = x;
    }];
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.people.name = [NSString stringWithFormat:@"我第%d",arc4random()%100];
    
}
-(People*)people{
    if (!_people) {
        _people = [[People alloc]init];
    }
    return _people;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
