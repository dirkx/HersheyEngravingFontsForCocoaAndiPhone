//
//  PlayView.m
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

#import "PlayView.h"
#import "Hershey.h"

@implementation PlayView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSArray * labels = @[ @"STOP", @"FAST", @"SLOM", @"HOLD", @"BACK", @"FOO", @"123",@"BAR",@"HALT" ];
    
    NSPoint center = NSMakePoint(self.bounds.origin.x+self.bounds.size.width/2,self.bounds.origin.y+self.bounds.size.height/2);
    double dist = MIN(self.bounds.size.width, self.bounds.size.height)-32;
    
    double r1 = (dist-10) / 4;
    double r2 = (dist -10)/ 2;
    int steps = 6;
    
    for(int i = 0; i < [labels count]; i++) {
        double angle = i * M_PI / steps;
        Hershey * fontDev = [Hershey bundledFont:kHersheyDefaultFont];
        
        NSPoint (^map)(NSPoint)= ^NSPoint(NSPoint p){
            double x = p.x;
            double y = p.y;
            
            if (angle > 0.45 * M_PI && angle < 0.55 * M_PI) {
                double a = x;
                x = y;
                y = a;
            } else
            if (angle > M_PI / 2)
                y = fontDev.accentY - y - 2 ;
            
            if (angle > 0.8 * M_PI) {
                x = 50 - x;
            };
            
            double dx = y - fontDev.baseY - 0.5;
            x *= (r2 - r1)/70;
            x += r1;
            y = dx * (1+x/25.);
            //            y = dx;
            
            double r = sqrt(x*x+y*y);
            double a = atan2(y,x);

            //            r += pow(x,2)/3500;
            a += angle;
            
            //            r = r + r * r / 20;
            
            x = r * cos(a);
            y = r * sin(a);
            
            return NSMakePoint(x, y);
        };

        
        NSBezierPath * p = [fontDev copyOfPathForString:labels[i]
                                         withSize:35
                                    withTransform:nil];
        NSRect pbounds = [p bounds];
        
        [Hershey transformBezierPath:p withTransform:map];
        
        (i == 2) ?
        [[NSColor redColor] setStroke] :
        [[NSColor blackColor] setStroke];
        
        NSAffineTransform * trans = [[NSAffineTransform alloc] init];
        [trans translateXBy:center.x yBy:center.y];
//        [trans scaleBy:1];
        [p transformUsingAffineTransform:trans];
        
        [p setLineWidth:2];
        [p setLineJoinStyle:NSRoundLineJoinStyle];
        [p setLineCapStyle:NSRoundLineCapStyle];
        
        [p stroke];
        
        if (1) {
            NSBezierPath * box = [[NSBezierPath alloc] init];
            // [box appendBezierPathWithRect:NSMakeRect(-100, 0, 250, 20)];
            [box appendBezierPathWithRect:pbounds];
            
            [Hershey transformBezierPath:box withTransform:map];
            
            [[NSColor darkGrayColor] setStroke];
            [box setLineWidth:0.2];
            [box setLineJoinStyle:NSRoundLineJoinStyle];
            [box setLineCapStyle:NSRoundLineCapStyle];
            
            [box transformUsingAffineTransform:trans];
            [box stroke];
        }
        
        double space = M_PI/60;
        if(0) {
            NSBezierPath * slice = [[NSBezierPath alloc] init];
            [slice appendBezierPathWithArcWithCenter:center
                                              radius:r1
                                          startAngle:(angle + space                - M_PI / steps / 2) * 360. / 2. / M_PI
                                            endAngle:(angle - space + M_PI / steps - M_PI / steps / 2) * 360. / 2. / M_PI
             ];
            [slice appendBezierPathWithArcWithCenter:center
                                              radius:r2
                                          startAngle:(angle - space + M_PI / steps - M_PI / steps / 2) * 360. / 2. / M_PI
                                            endAngle:(angle + space                - M_PI / steps / 2) * 360. / 2. / M_PI
                                           clockwise:YES
             ];
            [slice closePath];
            [slice stroke];
        }
        {
            double z1 = 0.4;
            double z2 = 0.2;
            
            // [[NSColor redColor] setStroke];
            NSBezierPath * slice = [[NSBezierPath alloc] init];
            [slice appendBezierPathWithArcWithCenter:center
                                              radius:r1-6
                                          startAngle:(angle + z1*space                - M_PI / steps / 2) * 360. / 2. / M_PI
                                            endAngle:(angle - z1*space + M_PI / steps - M_PI / steps / 2) * 360. / 2. / M_PI
             ];
            
            [slice appendBezierPathWithArcWithCenter:center
                                              radius:r2+8
                                          startAngle:(angle - z2*space + M_PI / steps - M_PI / steps / 2) * 360. / 2. / M_PI
                                            endAngle:(angle + z2*space                - M_PI / steps / 2) * 360. / 2. / M_PI
                                           clockwise:YES
             ];
            [slice closePath];
            [slice setLineWidth:3];
            [slice stroke];
        }
    }
    
}

@end
