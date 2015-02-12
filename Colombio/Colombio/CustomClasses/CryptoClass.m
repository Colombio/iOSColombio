/////////////////////////////////////////////////////////////
//
//  CryptoClass.m
//  Armin Vrevic
//
//  Created by Colombio on 8/6/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//
//  Class that primarily serves for the crypto algorithm functions
//
///////////////////////////////////////////////////////////////


#import "CryptoClass.h"
#import <CommonCrypto/CommonDigest.h>

@implementation CryptoClass

/**
 *  Produces md5 hash out of provided string input
 *
 *  @param input "Input that user wants to hash"
 *
 *  @return md5 hash in string format
 *
 */
+ (NSString *) md5:(NSString *) input
{
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    CC_MD5(cStr,(CC_LONG)strlen(cStr),digest);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i=0; i<CC_MD5_DIGEST_LENGTH;i++){
        [output appendFormat:@"%02x", digest[i]];
    }
    return output;
}

/**
 *  Method that produces base64encoded string out of provided binary data
 *
 *  @param input "Binary data"
 *
 *  @return base64 encoded string
 *
 */
+ (NSMutableString*)base64Encoding:(NSData*)data{
    static char base64EncodingTable[64] = {
        'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
        'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
        'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
        'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/'
    };
    int length = (int)[data length];
    unsigned long ixtext, lentext;
    long ctremaining;
    unsigned char input[3], output[4];
    short i, charsonline = 0, ctcopy;
    const unsigned char *raw;
    NSMutableString *result;
    lentext = [data length];
    result = [NSMutableString stringWithCapacity: lentext];
    raw = [data bytes];
    ixtext = 0;
    while (true) {
        ctremaining = lentext - ixtext;
        if (ctremaining <= 0)
            break;
        for (i = 0; i < 3; i++) {
            unsigned long ix = ixtext + i;
            if (ix < lentext)
                input[i] = raw[ix];
            else
                input[i] = 0;
        }
        output[0] = (input[0] & 0xFC) >> 2;
        output[1] = ((input[0] & 0x03) << 4) | ((input[1] & 0xF0) >> 4);
        output[2] = ((input[1] & 0x0F) << 2) | ((input[2] & 0xC0) >> 6);
        output[3] = input[2] & 0x3F;
        ctcopy = 4;
        switch (ctremaining) {
            case 1:
                ctcopy = 2;
                break;
            case 2:
                ctcopy = 3;
                break;
        }
        for (i = 0; i < ctcopy; i++)
            [result appendString: [NSString stringWithFormat: @"%c", base64EncodingTable[output[i]]]];
        for (i = ctcopy; i < 4; i++)
            [result appendString: @"="];
        ixtext += 3;
        charsonline += 4;
        if ((length > 0) && (charsonline >= length))
            charsonline = 0;
    }
    return result;
}

@end
