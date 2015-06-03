//
//  GenerateTurtle.m
//  Hershey Demo
//
//  Created by Dirk-Willem van Gulik on 03/06/15.
//  Copyright (c) 2015 Dirk-Willem van Gulik. All rights reserved.
//

#import "GenerateTurtle.h"
#import "Hershey.h"

@implementation GenerateTurtle

+(void)generate:(NSString *)fontName {
    
    Hershey * font = [Hershey bundledFont:fontName];
    if (!font) {
        fprintf(stderr,"Oh dear - no %s font known. Giving up.\n", [fontName cStringUsingEncoding:NSUTF8StringEncoding]);
        return;
    }
    
    printf("// Font - %s\n", [fontName cStringUsingEncoding:NSUTF8StringEncoding]);
    for(NSNumber *idx in [font orderedArrayOfGlyps]) {
        NSGlyph glyph = [idx intValue];
        printf("// Glyph <%c> (0x%02x, %d)\n", isprint(glyph) ? glyph : 0, glyph, glyph);
        
        HersheyGlyphDefinition * def = [font glyph:glyph];
        for(NSInteger i = 0; i < def.path.elementCount; i++) {
            NSPoint p[3];
            NSBezierPathElement e = [def.path elementAtIndex:i associatedPoints:p];
            switch(e) {
                case NSMoveToBezierPathElement:
                    printf("MoveTo(%f,%f);\n", p[0].x, p[0].y);
                    break;
                case NSLineToBezierPathElement:
                    printf("DrawTo(%f,%f);\n", p[0].x, p[0].y);
                    break;
                case NSClosePathBezierPathElement:
                    printf("--not supported-- \n");
                    break;
                case NSCurveToBezierPathElement:
                    printf("-- not supported --\n");
                    break;
            }
        }
        printf("\n\n");
    }
}

+(void)all {
    for(NSString * fontName in [Hershey bundledFonts]) {
        NSString * fileName = [NSString stringWithFormat:@"%@.c", fontName];
        stdout = fopen([fileName cStringUsingEncoding:NSUTF8StringEncoding], "w");
        [self generate:fontName];
    }
}

@end
