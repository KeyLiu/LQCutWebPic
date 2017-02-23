//
//  ViewController.m
//  LQCutWebPic
//
//  Created by 0000 on 17/1/23.
//  Copyright © 2017年 wisdomparents. All rights reserved.
//

#import "ViewController.h"
#import "ShardViewController.h"
#import <WebKit/WebKit.h>

#define WINSIZE_WIDTH [UIScreen mainScreen].bounds.size.width
#define WINSIZE_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface ViewController ()<WKNavigationDelegate>

@property (nonatomic, strong)WKWebView *webView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _webView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    _webView.navigationDelegate = self;
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.jianshu.com/p/efaf4a4945ca"]]];
    [self.view addSubview:_webView];
    
    UIButton *picBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, WINSIZE_HEIGHT - 50, WINSIZE_WIDTH, 50)];
    picBtn.backgroundColor = [UIColor greenColor];
    [picBtn setTitle:@"生成图片分享" forState:UIControlStateNormal];
    [picBtn addTarget:self action:@selector(setWebViewJavaScript) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:picBtn];
}

- (void)setWebViewJavaScript{

    NSString *js = @"(function getSelectedText() {\
    var txt;\
    if (window.getSelection) { \
    var range=window.getSelection().getRangeAt(0); \
    var container = window.document.createElement('div'); \
    container.appendChild(range.cloneContents()); \
    txt = container.innerHTML; \
    } else if (window.document.getSelection) { \
    var range=window.getSelection().getRangeAt(0); \
    var container = window.document.createElement('div'); \
    container.appendChild(range.cloneContents()); \
    txt = container.innerHTML; \
    } else if (window.document.selection) { \
    txt = window.document.selection.createRange().htmlText; \
    } \
    return txt; \
    })()";
    
    [_webView evaluateJavaScript:js completionHandler:^(id _Nullable cutTxt, NSError * _Nullable error) {
        
        ShardViewController *sharedVC = [[ShardViewController alloc]init];
        sharedVC.cutTxt = cutTxt;
        [self.navigationController pushViewController:sharedVC animated:YES];
        
    }];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    //[self setWebViewJavaScript];
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
