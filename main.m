//
//  main.m
//  DIYComic
//
//  Created by Andreas Wulf on 31/03/10.
//  Copyright 2moro Mobile 2010. All rights reserved.
//

#import <Three20/Three20.h>

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, @"DIYComicAppDelegate");
    [pool release];
    return retVal;
}
