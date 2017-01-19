//
//  HMACBridge.m
//  Trakx
//
//  Created by Matt Croxson on 28/06/2015.
//  Copyright © 2016 Matt Croxson. All rights reserved.
//

#import "HMACBridge.h"
#import <CommonCrypto/CommonHMAC.h>

@implementation HMACBridge

+ (NSURL *)signedURLWithPath: (NSString *)path {
   
   NSString *apiDevURL = @"http://timetableapi.ptv.vic.gov.au";
   
   NSString *apiFileLoc = [[NSBundle mainBundle] pathForResource:@"APIKeys" ofType:@"plist"];
   
   if ([apiFileLoc isEqual: @""]) {
      return nil;
   }
   
   NSDictionary *apiPlist = [NSDictionary dictionaryWithContentsOfFile:apiFileLoc];

   NSString *apiDevID = [apiPlist valueForKey:@"PTVAPIDevID"];
   NSString *apiDevKey = [apiPlist valueForKey:@"PTVAPIDevKey"];
   
   if (![path containsString:apiDevURL])
   {
      return nil;
   }
   
   NSRange deleteRange = {0,[apiDevURL length]};
   
   NSMutableString *urlString = [[NSMutableString alloc]initWithString:path];
   [urlString deleteCharactersInRange:deleteRange];
   
   if( [urlString containsString:@"?"])
   {
      [urlString appendString:@"&"];
   }
   else
   {
      [urlString appendString:@"?"];
   }
   
   [urlString appendFormat:@"devid=%@", apiDevID];
   
   const char *cKey = [apiDevKey UTF8String];
   const char *cData = [urlString UTF8String];
   
   unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
   CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
   
   NSString *hash;
   
   NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
   for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
      [output appendFormat:@"%02x", cHMAC[i]];
   
   hash = output;
   NSString* signature = [hash uppercaseString];
   
   NSString *urlSuffix = [NSString stringWithFormat:@"devid=%@&signature=%@", apiDevID ,signature];
   
   NSURL *url = [NSURL URLWithString:path];
   
   NSString *urlQuery = [url query];
   
   if(urlQuery != nil && [urlQuery length] > 0){
      url = [NSURL URLWithString:[NSString stringWithFormat:@"%@&%@",path,urlSuffix]];
   }else{
      url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@",path,urlSuffix]];
   }
   
   return url;
}

@end

