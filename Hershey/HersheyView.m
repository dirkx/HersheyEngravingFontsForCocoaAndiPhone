//
//  HersheyView.m
//  Hershey Demo
//
// Copyright 2013 Dirk-Willem van Gulik, All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "HersheyView.h"
#import "Hershey.h"

@implementation HersheyView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

#define N (16)

- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor whiteColor] set];
    NSRectFill(self.bounds);
    
    double s = (self.bounds.size.width - 32) / N;
    double w = N * s;
    double ox = ( self.bounds.size.width - w ) / 2.;
    double oy = ox;
    double hScale = s/50.;
    
    int i = 0;
    for(NSNumber * cn in [self.font orderedArrayOfGlyps]) {
        NSGlyph c = (unsigned int)[cn integerValue];
        NSPoint o = NSMakePoint(ox+ (i % N) * s,
                                - oy/2 + self.bounds.size.height - ((1+(int)(i / N))) * s);
        
        NSAffineTransform * trans = [[NSAffineTransform alloc] init];
        [trans translateXBy:o.x+s/2 yBy:o.y+s/2];
        [trans scaleBy:hScale];
        
        NSRect b = NSMakeRect(o.x, o.y, s-4,s-4);
        [[NSColor darkGrayColor] setStroke];
        [NSBezierPath strokeRect:b];

        if (!self.font)
            self.font = [Hershey bundledFont:kHersheyDefaultFont];
        
        HersheyGlyphDefinition * gdata = [self.font glyph:c];
        NSBezierPath * p = [gdata.path copy];
        if (p) {
            [p transformUsingAffineTransform:trans];
            
            [[NSColor blackColor] setStroke];
            [p setLineWidth:s/20];
            [p setLineJoinStyle:NSRoundLineJoinStyle];
            [p setLineCapStyle:NSRoundLineCapStyle];
            [p stroke];
            
            [[NSColor redColor] setStroke];
            [p setLineWidth:0.8];
            [p setLineJoinStyle:NSRoundLineJoinStyle];
            [p setLineCapStyle:NSRoundLineCapStyle];
            [p stroke];
            
            // 1x1 at center
            [[NSColor blueColor] setStroke];
            [NSBezierPath strokeLineFromPoint:NSMakePoint(o.x+s/2.+hScale/2., o.y+s/2.)
                                      toPoint:NSMakePoint(o.x+s/2.-hScale/2., o.y+s/2.)];
            
             [NSBezierPath strokeLineFromPoint:NSMakePoint(o.x+s/2., o.y+s/2.+hScale/2.)
                                       toPoint:NSMakePoint(o.x+s/2., o.y+s/2.-hScale/2.)];
             
            int lx = gdata.lx;
            int rx = gdata.rx;
            int baseY = gdata.baseY;
            int accentY = gdata.accentY;
            
            [NSBezierPath strokeRect:NSMakeRect(o.x+s/2+hScale*lx,
                                                o.y + s/2. - baseY * hScale,
                                                hScale * (rx-lx),
                                                hScale * accentY)];
            if (1)
            [NSBezierPath strokeLineFromPoint:NSMakePoint(o.x+s/2+hScale*lx, o.y + s/2. - baseY * hScale)
                                      toPoint:NSMakePoint(o.x+s/2+hScale*rx, o.y + s/2. - baseY * hScale)];
            
        }
        o.x +=2;
        if(1) {
            double fontSize = MIN(20,s/10);
            if (fontSize > 4)
                [[NSString stringWithFormat:@"%c/%03d/%05d",isprint(c) ? c : ' ', c, gdata.idx]
                  drawAtPoint:o
               withAttributes:@{
                   NSFontAttributeName :[NSFont fontWithName:@"GillSans" size:fontSize],
               }
             ];
        }
        i++;
    }
    double fontSize = 20 * hScale;
    
    [self.font.name drawAtPoint:NSMakePoint(self.bounds.origin.x+20, self.bounds.origin.y+8)
          withAttributes:@{
      NSFontAttributeName :[NSFont fontWithName:@"GillSans" size:fontSize],}];
        
    NSString * testStr = @"The quick brown fox jumps over the lazy dog.";
    
    NSBezierPath * p = [self.font copyOfPathForString:testStr
                                     withSize:fontSize*1.7];
    [[NSColor blackColor] setStroke];
    
    NSAffineTransform * trans = [[NSAffineTransform alloc] init];
    [trans translateXBy:self.bounds.origin.x+20+fontSize * [self.font.name length] * 0.8
                    yBy:self.bounds.origin.y+12];
    [trans scaleBy:hScale*0.7];
    
    [p transformUsingAffineTransform:trans];
    [p setLineWidth:s/25.];
    [p setLineJoinStyle:NSRoundLineJoinStyle];
    [p setLineCapStyle:NSRoundLineCapStyle];
    [p stroke];

}
@end
