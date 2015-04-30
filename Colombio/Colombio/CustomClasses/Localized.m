//
//  Localized.m
//  Colombio
//
//  Created by Vlatko Šprem on 29/11/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//

#import "Localized.h"

static Localized *localized = nil;

@implementation Localized

@synthesize bundleAttribute;
@synthesize pathAttribute;

- (id)init {
    if ((self = [super init])) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.pathAttribute = [defaults stringForKey:SELECTED_LANGUAGE];
        
        NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
        NSString *dataPath;
        if ([self.pathAttribute length] > 0) {
            dataPath = [bundlePath stringByAppendingPathComponent:self.pathAttribute];
        } else {
            dataPath = bundlePath;
        }
        NSBundle *b = [[NSBundle alloc] initWithPath:dataPath];
        self.bundleAttribute = b;
        //assert(self.bundleAttribute!= nil);
        [self.bundleAttribute load];
    }
    return self;
}

+ (NSBundle *)bundle {
    @synchronized(localized) {
        if (localized == nil) {
            localized = [[Localized alloc] init];
        }
        return localized.bundleAttribute;
    }
    return nil;
}

+ (NSString *)prefferedLocalization {
    @synchronized(localized) {
        if (localized == nil) {
            localized = [[Localized alloc] init];
        }
    }
    if (localized.pathAttribute == nil) {
        NSArray *localizations = [[NSBundle mainBundle] localizations];
        localizations = [NSBundle preferredLocalizationsFromArray:localizations];
        if ([localizations count] > 0) {
            return [localizations objectAtIndex:0];
        }
        return nil;
    }
    const NSRange range = [localized.pathAttribute rangeOfString:@"."];
    if (range.location == NSNotFound) {
        assert(false);
        return localized.pathAttribute;
    }
    return [localized.pathAttribute substringToIndex:range.location];
}

+ (NSString *)string:(NSString *)stringKey {
    NSString *s = NSLocalizedStringFromTableInBundle(stringKey, @"Localizable", [Localized bundle], @"comment");
    if (!s) {
        s = NSLocalizedStringFromTableInBundle(stringKey, @"Localizable", [NSBundle mainBundle], @"comment");
    }
    
    return s;
}

+ (void)save:(NSString *)languageKey {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSString stringWithFormat:@"%@.lproj",languageKey] forKey:SELECTED_LANGUAGE];
    @synchronized(localized) {
        if (localized != nil) {
            localized = nil;
        }
    }
    [defaults synchronize];
}

+ (void)reset {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:SELECTED_LANGUAGE];
    @synchronized(localized) {
        if (localized != nil) {
            localized = nil;
        }
    }
}

+ (NSString *)path {
    @synchronized(localized) {
        if (localized == nil) {
            localized = [[Localized alloc] init];
        }
        return localized.pathAttribute;
    }
    return nil;
}

@end

