//
//  main.c
//  GenerateTurtle
//
//  Created by Dirk-Willem van Gulik on 03/06/15.
//  Copyright (c) 2015 Dirk-Willem van Gulik. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GenerateTurtle.h"

int main(int argc, char *argv[])
{
    if (argc == 1)
        [GenerateTurtle all];
    else if (argc == 2)
        [GenerateTurtle generate:[NSString stringWithUTF8String:argv[1]]];
    else {
        fprintf(stderr, "Syntax %s [fontName]", argv[0]);
        exit(1);
    }
    exit (0);
}