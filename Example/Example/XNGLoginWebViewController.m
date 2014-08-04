//
// Copyright (c) 2013 XING AG (http://xing.com/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "XNGLoginWebViewController.h"

@interface XNGLoginWebViewController ()
@property (nonatomic, strong) NSURL *authURL;
@property (nonatomic, strong) UIWebView *webView;
@end

@implementation XNGLoginWebViewController

- (id)initWithAuthURL:(NSURL *)authURL {
    self = [super initWithNibName:nil bundle:nil];

    if (self) {
        _authURL = authURL;
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupNavigationBar];
    [self setupWebView];
    [self loadRequest];
}

- (void)setupNavigationBar {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Abbrechen"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(cancelButtonPressed:)];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"In Safari öffnen"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(openInSafariButtonPressed:)];
}

- (void)setupWebView {
    self.webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.webView];
}

- (void)loadRequest {
    NSURLRequest *request = [NSURLRequest requestWithURL:self.authURL];
    [self.webView loadRequest:request];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.webView.frame = self.view.bounds;
}

#pragma mark - public methods
//This is needed, to avoid dismissing during presenting animation
//(Sometimes the login is cashed in the webview and really fast!)
- (void)dismiss {
    [self performSelector:@selector(dismissDelayed) withObject:nil afterDelay:0.33];
}


#pragma mark - Actions

- (void)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)openInSafariButtonPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:self.authURL];
}

#pragma mark - private methods

- (void)dismissDelayed {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
