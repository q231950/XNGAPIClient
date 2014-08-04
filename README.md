#  The official Objective-C XING API Client

## NOTE

The initial release of the Pod was named `XINGAPI`. This was confusing a lot of our users so we decided to rename it after the repository `XNGAPIClient`.

*PLEASE NOTE* that in favor of the new `XNGAPIClient` the `XINGAPI` pod will no longer be updated. Please switch your codebase to be future-proof.

If you have any questions please open an issue.

===

[![Build Status](https://travis-ci.org/xing/XNGAPIClient.svg?branch=master)](https://travis-ci.org/xing/XNGAPIClient) [![Dependency Status](https://www.versioneye.com/objective-c/xngapiclient/badge.svg)](https://www.versioneye.com/objective-c/xngapiclient)
[![Reference Status](https://www.versioneye.com/objective-c/xngapiclient/reference_badge.svg)](https://www.versioneye.com/objective-c/xngapiclient/references)

XNGAPIClient is the official client to access the XING API. In order to access the API, you only need an account on https://xing.com and an oauth consumer key and secret which can be obtained at https://dev.xing.com. Both is totally free and only takes a minute!

XNGAPIClient is built on top of AFNetworking, so it takes full advantage of blocks. We also included an example project that takes care of storing your oauth token in the keychain to get you started even quicker. At the moment only iOS is supported. Not tested yet on Mac OS X.

## Getting started

### Option 1
If you use [CocoaPods](http://cocoapods.org), you can add the ```XNGAPIClient``` pod to your Podfile. Then run ```pod install```, and the XING API Client will be available in your project.

### Option 2
Clone & Watch our repository by visiting https://github.com/xing/XNGAPIClient

## Optain a consumer key
You can optain a consumer key and consumer secret by visiting https://dev.xing.com/applications and pressing the create app button.

## Set callback URL for OAuth authentication
You need to setup the callback URL, which can be called after the user successfully logged in via Safari. Using the XING API Client your callback URL scheme will be ```xingapp<YOUR CONSUMER KEY>```. An example would be ```xingapp4a568854ef676b```

To set it up just these steps:

1. Click on your Project file.
2. Make sure your main target is selected.
3. Click on the Info button.
4. Expand the URL Types section.
5. Hit the + button.
6. Add your scheme in the above described style

## Configure your App Delegate

1. Import ```#import XNGAPI.h``` in your Application Delegate
2. Add following method to your Application Delegate:
``` objective-c
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    if ([[XNGAPIClient sharedClient] handleOpenURL:url]) {
        return YES;
    } else {
        //insert your own handling
    }

    return NO;
}
```

## Example Usage

register your consumer key and secret with the shared client:

``` objective-c
XNGAPIClient *client = [XNGAPIClient sharedClient];
client.consumerKey = @"xXxXxXxXxXxXxXxXxXxXxX";
client.consumerSecret = @"xXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxX";
```

login with oauth:

``` objective-c
[client loginOAuthWithSuccess:^{
			 	// handle success
			  }
              failure:^(NSError *error) {
			 	 // handle failure
			  }];
```

make a call to load your own profile:

``` objective-c
[client getUserWithID:@"me"
           userFields:nil
              success:^(id JSON) {
			 	// handle success
			  }
              failure:^(NSError *error) {
			 	 // handle failure
			  }];
```

## Contact

XING AG

- https://github.com/xing
- https://twitter.com/xingdevs
- https://dev.xing.com

## License

XNGAPIClient is available under the MIT license. See the LICENSE file for more info.
