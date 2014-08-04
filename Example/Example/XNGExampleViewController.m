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

#import "XNGExampleViewController.h"
#import "XNGAPI.h"
#import "XNGLoginWebViewController.h"

#define kCellID @"XNGCellID"

@interface XNGExampleViewController ()
@property (nonatomic, strong) NSArray *contacts;
@property (nonatomic, strong) XNGLoginWebViewController *loginWebViewController;
@end

@implementation XNGExampleViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    XNGAPIClient *client = [XNGAPIClient sharedClient];
    if ([client isLoggedin] == NO) {
        [self setupLoginButton];
    } else {
        [self setupLogoutButton];
        [self loadContacts];
    }

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellID];
}

#pragma mark - login / logout button setup

- (void)setupLoginButton {
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Login"
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(loginButtonPressed:)];
    self.navigationItem.rightBarButtonItem = barButtonItem;

}

-(void)setupLogoutButton {
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout"
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(logoutButtonPressed:)];
    self.navigationItem.rightBarButtonItem = barButtonItem;
}

- (void)loginButtonPressed:(id)sender {
    [self login];
}

- (void)logoutButtonPressed:(id)sender {
    [self logout];
}

#pragma mark - login / logout

- (void)login {
    __weak __typeof(&*self)weakSelf = self;
    
    [[XNGAPIClient sharedClient] loginOAuthAuthorize:^(NSURL *authURL) {
        self.loginWebViewController = [[XNGLoginWebViewController alloc] initWithAuthURL:authURL];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.loginWebViewController];
        NSLog(@"Gonna present");
        [self presentViewController:navigationController animated:YES completion:NULL];
    } loggedIn:^{
        [weakSelf setupLogoutButton];
        [weakSelf loadContacts];
        if (![weakSelf.presentedViewController isBeingDismissed]) {
            [weakSelf.loginWebViewController dismiss];
        } 
    } failuire:^(NSError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        if (![weakSelf.presentedViewController isBeingDismissed]) {
            [weakSelf.loginWebViewController dismiss];
        }
    }];
}

- (void)logout {
    self.contacts = nil;
    [self.tableView reloadData];
    [[XNGAPIClient sharedClient] logout];
    [self setupLoginButton];
}

#pragma mark - Sample API call usage

- (void)loadContacts {
    __weak __typeof(&*self)weakSelf = self;
    [[XNGAPIClient sharedClient] getContactsForUserID:@"me"
                                                limit:100
                                               offset:0
                                              orderBy:XNGContactsOrderOptionByLastName
                                           userFields:@"display_name"
                                              success:^(id JSON)
     {
         if (![JSON isKindOfClass:[NSDictionary class]]) {
             return;
         }
         weakSelf.contacts = [JSON valueForKeyPath:@"contacts.users.display_name"];
         [weakSelf.tableView reloadData];
     }
                                              failure:^(NSError *error)
     {
         NSLog(@"Error:\n %@",error);
         
     }];
}

#pragma mark - UITableViewDatasource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.contacts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID forIndexPath:indexPath];
    cell.textLabel.text = self.contacts[indexPath.row];
    return cell;
}

@end
