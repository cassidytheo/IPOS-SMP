//
//  APIManager.m
//  DIMOPayiOS
//
//

#import "DIMOAPIManager.h"
#import "DAFNetworking.h"
#import "DIMOUtility.h"
#import "DReachability.h"
#import "XMLReader.h"

@implementation DIMOAPIManager
static int const errorCode401 = 401;

// STAGING
#define BASE_URL @"https://54.255.194.95:8443/webapi/sdynamic?channelID=7&mspID=1"
//#define SIMOBI_URL @"https://staging.dimo.co.id:8470/webapi/sdynamic?channelID=7&"
#define PayByQR_URL  ServerURLUat
#define DOWNLOAD_PDF_URL @"https://54.255.194.95:8443/webapi/"

// Production


+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (BOOL)isInternetConnectionExist {
    DReachability *networkReachability = [DReachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        DLog(@"There IS NO internet connection");
        return NO;
    } else {
        DLog(@"There IS internet connection");
        return YES;
    }
    //return ((AFNetworkReachabilityManager*)[NSClassFromString(@"AFNetworkReachabilityManager") sharedManager]).reachable;
}
#pragma mark - API
+ (void)callAPIWithParameters:(NSDictionary *)dict
        andComplete:(void(^)( NSDictionary *response, NSError *err))completion {
    
    [self startHTTPRequestWithMethod:ConnectionManagerHTTPMethodGET
                           urlString:BASE_URL
                              params:dict
                          completion:^(DAFHTTPRequestOperation *operation, id responseObject, NSError *err) {
                              completion(responseObject, err);
                          }];
}

#pragma mark - Private Methods

+ (BOOL)checkConnectionAndUrlCompatible:(NSString *)url {
    //check compatible of api here
    if (![self isInternetConnectionExist]) {
        //no internet connection
        DLog(@"Internet connection not exist detected");
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_SIMASPAY_API_NO_INTERNET_CONNECTION object:nil];
        return NO;
    }
    return YES;
}

+ (DAFHTTPRequestOperationManager *)createRequestManager {
    DAFHTTPRequestOperationManager *manager = [DAFHTTPRequestOperationManager manager];
    //manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //manager.requestSerializer = [AFJSONRequestSerializer serializer];
    //manager.securityPolicy.allowInvalidCertificates = YES;
    //manager.requestSerializer.HTTPMethodsEncodingParametersInURI = [NSSet set];
    //[manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    //[manager.requestSerializer setHTTPShouldHandleCookies:NO];
    
    NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    [manager.requestSerializer setValue:appVersion forHTTPHeaderField:@"AppVersion"];
    [manager.requestSerializer setTimeoutInterval:30];
    manager.responseSerializer = [DAFHTTPResponseSerializer serializer];
    manager.requestSerializer = [DAFHTTPRequestSerializer serializer];
    
    DAFSecurityPolicy* policy = [DAFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    [policy setValidatesDomainName:NO];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.securityPolicy.allowInvalidCertificates = YES;
    return manager;
}

+ (void)startHTTPRequestWithMethod:(ConnectionManagerHTTPMethod)method
                         urlString:(NSString *)urlString
                            params:(NSDictionary *)params
                        completion:(void(^)(DAFHTTPRequestOperation *operation, id responseObject, NSError *err))completion
{
    if (!urlString) {
        completion(nil, nil, nil);
        return;
    }
    // Remove all white space
    urlString = [urlString stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (![self checkConnectionAndUrlCompatible:urlString]) return;
    
    if (![self isInternetConnectionExist]) {
        NSError *err = [NSError errorWithDomain:@"No internet connection"
                                           code:0
                                       userInfo:@{@"error" : @"Tidak dapat terhubung dengan server SimasPay. Harap periksa koneksi internet Anda dan coba kembali setelah beberapa saat."}];
        completion(nil, nil, err);
        return;
    }
    
    // Logging url called
    DLog([NSString stringWithFormat:@"Try to call : %@\nwith params %@", urlString, params]);
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    DAFHTTPRequestOperationManager *manager = [self createRequestManager];
    if (method == ConnectionManagerHTTPMethodPOST) {
        [manager POST:urlString parameters:params success:^(DAFHTTPRequestOperation *operation, id responseObject) {
            [DIMOAPIManager handleSuccessForOperation:operation
                                          responseObject:responseObject
                                              completion:completion];
        } failure:^(DAFHTTPRequestOperation *operation, NSError *error) {
            [DIMOAPIManager handleErrorForOperation:operation
                                                 error:error
                                            completion:completion];
        }];
    } else {
        [manager GET:urlString parameters:params success:^(DAFHTTPRequestOperation *operation, id responseObject) {
            [DIMOAPIManager handleSuccessForOperation:operation
                                          responseObject:responseObject
                                              completion:completion];
        } failure:^(DAFHTTPRequestOperation *operation, NSError *error) {
            [DIMOAPIManager handleErrorForOperation:operation
                                                 error:error
                                            completion:completion];
        }];
    }
}


+ (void)handleSuccessForOperation:(DAFHTTPRequestOperation *)operation
                   responseObject:(id)responseObject
                       completion:(void(^)(DAFHTTPRequestOperation *operation, id responseObject, NSError *err))completion
{
    static int successCode = 200;
    id result = nil;
    NSString *response = operation.responseString;
    if (response && response != NULL) {
        NSData *data = [response dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        result = (NSDictionary *)[XMLReader dictionaryForXMLData:data error:&error];
        result = result[@"response"];
        //result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    if (completion && completion != NULL) {
        if (operation.response.statusCode == successCode) {
            if ([result isKindOfClass:[NSArray class]]) {
                // means success with array
                completion(operation, result, nil);
                return;
            }
            
            if (result[kDIMO_RESULT_SUCCESS] != nil) {
                if ([result[kDIMO_RESULT_SUCCESS][@"text"] isEqualToString:@"true"]) {
                    completion(operation, result, nil);
                } else if ([result[kDIMO_RESULT_SUCCESS][@"text"] isEqualToString:kDIMO_RESULT_NOK]) {
                    NSError *err = [NSError errorWithDomain:@"NOK"
                                                       code:operation.response.statusCode
                                                   userInfo:result];
                    completion(operation, result, err);
                } else {
                    NSError *err = [NSError errorWithDomain:@"Unknown result type"
                                                       code:operation.response.statusCode
                                                   userInfo:result];
                    completion(operation, result, err);
                }
            } else {
                completion(operation, result, nil);
            }
        } else {
            // 401 for authentication error
            if (operation.response.statusCode == errorCode401) {
                DLog(@"Error code 401");
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_SIMASPAY_AUTHENTICATION_ERROR object:nil];
            } else {
                NSError *err = [NSError errorWithDomain:@"ConnectionManagerError:StatusCodeNot200"
                                                   code:operation.response.statusCode
                                               userInfo:@{@"error" : @"Status code not 200"}];
                completion(operation, result, err);
            }
        }
    }
}

+ (void)handleErrorForOperation:(DAFHTTPRequestOperation *)operation
                          error:(NSError *)error
                     completion:(void(^)(DAFHTTPRequestOperation *operation, id responseObject, NSError *err))completion
{
    id result = nil;
    NSString *response = operation.responseString;
    if (response && response != NULL) {
        NSData *data = [response dataUsingEncoding:NSUTF8StringEncoding];
        result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    // 401 for authentication error
    if (operation.response.statusCode == errorCode401) {
        DLog(@"Error code 401");
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_SIMASPAY_AUTHENTICATION_ERROR object:nil];
    } else if (operation.response.statusCode == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_SIMASPAY_UNKNOWN_ERROR object:nil];
        //completion(operation, result, nil);
    }
    
    DLog([NSString stringWithFormat:@"operation.response.statusCode : %d", (int)operation.response.statusCode]);
    
    if (completion && completion != NULL) {
        completion(operation, result, error);
    }
}

+ (void)startHTTPRequestWithMethodAndHeader:(ConnectionManagerHTTPMethod)method
                                    headers:(NSDictionary *)headers
                                  urlString:(NSString *)urlString
                                     params:(NSDictionary *)params
                                 completion:(void(^)(DAFHTTPRequestOperation *operation, id responseObject, NSError *err))completion
{
    if (!urlString) {
        completion(nil, nil, nil);
        return;
    }
    // Remove all white space
    urlString = [urlString stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (![self checkConnectionAndUrlCompatible:urlString]) return;
    
    // Logging url called
    DLog([NSString stringWithFormat:@"Try to call : %@\nwith params %@", urlString, params]);
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    DAFHTTPRequestOperationManager *manager = [self createRequestManager];
    if (method == ConnectionManagerHTTPMethodPOST) {
        manager.requestSerializer = [DAFJSONRequestSerializer serializer];
        for (NSString *key in headers) {
            [manager.requestSerializer setValue:[headers objectForKey:key] forHTTPHeaderField:key];
        }
        [manager POST:urlString parameters:params success:^(DAFHTTPRequestOperation *operation, id responseObject) {
            [DIMOAPIManager handleSuccessForOperation:operation
                                       responseObject:responseObject
                                           completion:completion];
        } failure:^(DAFHTTPRequestOperation *operation, NSError *error) {
            [DIMOAPIManager handleErrorForOperation:operation
                                              error:error
                                         completion:completion];
        }];
    } else {
        for (NSString *key in headers) {
            [manager.requestSerializer setValue:[headers objectForKey:key] forHTTPHeaderField:key];
        }
        [manager GET:urlString parameters:params success:^(DAFHTTPRequestOperation *operation, id responseObject) {
            [DIMOAPIManager handleSuccessForOperation:operation
                                       responseObject:responseObject
                                           completion:completion];
        } failure:^(DAFHTTPRequestOperation *operation, NSError *error) {
            [DIMOAPIManager handleErrorForOperation:operation
                                              error:error
                                         completion:completion];
        }];
    }
}

@end
