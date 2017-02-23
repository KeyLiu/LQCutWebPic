//
//  ShardViewController.m
//  LQCutWebPic
//
//  Created by 0000 on 17/2/8.
//  Copyright © 2017年 wisdomparents. All rights reserved.
//

#import "ShardViewController.h"
#import <WebKit/WebKit.h>

#define WINSIZE_WIDTH [UIScreen mainScreen].bounds.size.width
#define WINSIZE_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface ShardViewController ()<WKNavigationDelegate>

@property (nonatomic, strong)WKWebView *webView;
@end

@implementation ShardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithTitle:@"生成图片" style:UIBarButtonItemStylePlain target:self action:@selector(sharedImage)];
    [self.navigationItem setRightBarButtonItem:shareButton];
    
    UIButton *picBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, WINSIZE_HEIGHT - 50, WINSIZE_WIDTH, 50)];
    picBtn.backgroundColor = [UIColor cyanColor];
    [picBtn setTitle:@"分享" forState:UIControlStateNormal];
    [picBtn addTarget:self action:@selector(sharedImage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:picBtn];
    
    NSString *jScript = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
    
    WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    WKUserContentController *wkUController = [[WKUserContentController alloc] init];
    [wkUController addUserScript:wkUScript];
    
    WKWebViewConfiguration *wkWebConfig = [[WKWebViewConfiguration alloc] init];
    wkWebConfig.userContentController = wkUController;
    
    _webView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 64, WINSIZE_WIDTH, WINSIZE_HEIGHT -64-50) configuration:wkWebConfig];
    _webView.navigationDelegate = self;
    
    //加载pic.html
    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"pic" ofType:@"html"];
    
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:filePath]]];
    
    [self.view addSubview:_webView];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    [self addstrData:_cutTxt];
}

/**
 *拼接用户名和内容名
 **/
- (void)addstrData:(NSString *)strData{
    
    if(strData == nil)
        strData =@"";

    [_webView evaluateJavaScript:[NSString stringWithFormat:@"changeContents(\"%@\")",strData] completionHandler:^(id _Nullable what, NSError * _Nullable error) {
        
       
        
    }];
}
//
///**
// *改变样式
// **/
//- (void)changeDay{
//
//    
//}

/**
 *生成图片
 **/
- (void)sharedImage{
    CGRect snapshotFrame = CGRectMake(0, 0, _webView.scrollView.contentSize.width, _webView.scrollView.contentSize.height);
    UIEdgeInsets snapshotEdgeInsets = UIEdgeInsetsZero;
    UIImage *shareImage = [self snapshotViewFromRect:snapshotFrame withCapInsets:snapshotEdgeInsets];
    NSString *path_document = NSHomeDirectory();
    //设置一个图片的存储路径
    
    NSString *imagePath = [path_document stringByAppendingString:@"/Documents/picc.png"];
    //把图片直接保存到指定的路径（同时应该把图片的路径imagePath存起来，下次就可以直接用来取）
    
    NSLog(@"%@",imagePath);
    
    [UIImagePNGRepresentation(shareImage) writeToFile:imagePath atomically:YES];
}


- (UIImage *)snapshotViewFromRect:(CGRect)rect withCapInsets:(UIEdgeInsets)capInsets {
    
    CGFloat scale = [UIScreen mainScreen].scale;
    
    CGSize boundsSize = self.webView.bounds.size;
    CGFloat boundsWidth = boundsSize.width;
    CGFloat boundsHeight = boundsSize.height;
    
    CGSize contentSize = self.webView.scrollView.contentSize;
    CGFloat contentHeight = contentSize.height;
    //CGFloat contentWidth = contentSize.width;
    
    CGPoint offset = self.webView.scrollView.contentOffset;
    
    [self.webView.scrollView setContentOffset:CGPointMake(0, 0)];
    
    NSMutableArray *images = [NSMutableArray array];
    while (contentHeight > 0) {
        UIGraphicsBeginImageContextWithOptions(boundsSize, NO, [UIScreen mainScreen].scale);
        [self.webView.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [images addObject:image];
        
        CGFloat offsetY = self.webView.scrollView.contentOffset.y;
        [self.webView.scrollView setContentOffset:CGPointMake(0, offsetY + boundsHeight)];
        contentHeight -= boundsHeight;
    }
    
    
    [self.webView.scrollView setContentOffset:offset];
    
    CGSize imageSize = CGSizeMake(contentSize.width * scale,
                                  contentSize.height * scale);
    UIGraphicsBeginImageContext(imageSize);
    [images enumerateObjectsUsingBlock:^(UIImage *image, NSUInteger idx, BOOL *stop) {
        [image drawInRect:CGRectMake(0,
                                     scale * boundsHeight * idx,
                                     scale * boundsWidth,
                                     scale * boundsHeight)];
    }];
    UIImage *fullImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageView * snapshotView = [[UIImageView alloc]initWithFrame:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height)];
    
    snapshotView.image = [fullImage resizableImageWithCapInsets:capInsets];
    return snapshotView.image;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
