//
//  SotView.m
//  Hershey Demo
//
//  Created by Dirk-Willem van Gulik on 25-08-13.
//  Copyright (c) 2013 Dirk-Willem van Gulik. All rights reserved.
//

#import "SotView.h"
#import "Hershey.h"

@interface SotView () {
    NSInteger steps;
    double inset;
    double angleCover;
    double outerBand;
    double gap;
    double innerBand;
    NSMutableArray * labels;
}
@property (assign, nonatomic) IBOutlet NSForm * items;
@property (assign, nonatomic) IBOutlet NSDrawer * drawer;
@end

@implementation SotView

-(void)viewWillMoveToSuperview:(NSView *)newSuperview {
    [super viewWillMoveToSuperview:newSuperview];
    inset = 15;
    steps = 7;
    angleCover = 180 * (steps + 1)/steps;
    outerBand = 16;
    gap = 5;
    innerBand = 35;
    labels = [[NSMutableArray alloc] initWithArray:@[ @"STOP", @"FAST", @"SLOM", @"HOLD", @"BACK", @"FOO", @"123",@"BAR",@"HALT" ]];
    [self.items removeEntryAtIndex:0];
    [self jiggle];
}

- (void)drawerWillOpen:(NSNotification *)notification {
    [self jiggle];
}

-(IBAction)setSteps:(NSSlider *)sender {
    steps = [sender integerValue];
    [self setNeedsDisplay:YES];
    [self jiggle];
}

-(void)jiggle {
    NSInteger n = [self.items numberOfRows];
    while(n > steps) {
        [self.items removeEntryAtIndex:0];
        n--;
    }
    
    while(n < steps) {
        if ([labels count] <= n) [labels addObject:@"XXX"];
        [self.items insertEntry:[NSString stringWithFormat:@"#%ld",n+1] atIndex:0];
        [[self.items cellAtRow:0 column:0] setStringValue:[labels objectAtIndex:n]];
        n++;
    }
    [self.items sizeToCells];
}

-(IBAction)setInset:(NSSlider *)sender {
    inset = [sender integerValue];
    [self setNeedsDisplay:YES];
}

-(IBAction)setAngle:(NSSlider *)sender {
    angleCover = [sender integerValue];
    [self setNeedsDisplay:YES];
}

-(IBAction)setGap:(NSSlider *)sender {
    gap = [sender integerValue];
    [self setNeedsDisplay:YES];
}

-(IBAction)setOuterband:(NSSlider *)sender {
    outerBand = [sender integerValue];
    [self setNeedsDisplay:YES];
}

-(IBAction)setInnerband:(NSSlider *)sender {
    innerBand = [sender integerValue];
    [self setNeedsDisplay:YES];
}

-(IBAction)setForm:(id)sender {
    for(int i =0; i < [self.items numberOfRows]; i++)
        [labels setObject:[[self.items cellAtRow:i column:0] stringValue] atIndexedSubscript:i];
    
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect
{

    NSPoint center = NSMakePoint(self.bounds.origin.x+self.bounds.size.width/2,self.bounds.origin.y+self.bounds.size.height/2);
    double dist = MIN(self.bounds.size.width, self.bounds.size.height)-32;
    
    double r1 = (dist -10) * innerBand / 200;
    double r2 = (dist -10)/ 2 - outerBand;
    double r3 = (dist -10)/ 2;
    double r4 = 30; // axis hole.
    
    [[NSColor blackColor] setStroke];
    [[NSColor whiteColor] setFill];
    {
        NSBezierPath * outline =  [[NSBezierPath alloc] init];
        [outline appendBezierPathWithArcWithCenter:center
                                            radius:r3
                                        startAngle:0
                                          endAngle:360];
//        [outline closePath];

        [outline moveToPoint:NSMakePoint(center.x + r4, center.y)];
        [outline appendBezierPathWithArcWithCenter:center
                                            radius:r4
                                        startAngle:0
                                          endAngle:360];
        [outline closePath];
        [outline setLineWidth:3];
        [outline setWindingRule:NSEvenOddWindingRule];
        [outline fill];
        [outline stroke];
    }
    
    double sectorAngle = angleCover / 180. * M_PI / (steps);
    double rad2deg = 180. / M_PI;
    
    for(int i = 0; i < steps; i++) {
        double angle = i * sectorAngle;
        
        (i == steps/2) ?
        [[NSColor redColor] setStroke] :
        [[NSColor blackColor] setStroke];
        
        (i == steps/2) ?
        [[NSColor redColor] setFill] :
        [[NSColor blackColor] setFill];
        
        
        NSBezierPath * triMarker =  [[NSBezierPath alloc] init];
        [triMarker moveToPoint:NSMakePoint(center.x + r2 * cos(angle), center.y + r2 * sin(angle))];
        [triMarker appendBezierPathWithArcWithCenter:center
                                              radius:r3
                                          startAngle:(angle-sectorAngle / 10.) * rad2deg
                                            endAngle:(angle+sectorAngle / 10. ) * rad2deg];
        [triMarker closePath];
        [triMarker fill];
        
        angle -= sectorAngle / 2.;
        
        NSBezierPath * slice = [[NSBezierPath alloc] init];
        
        
        NSPoint p1 = NSMakePoint(center.x + r1 * cos(angle) - gap * sin(angle) / 2.,
                                 center.y + r1 * sin(angle) + gap * cos(angle) / 2.);
        NSPoint p2 = NSMakePoint(center.x + r2 * cos(angle) - gap * sin(angle) / 2.,
                                 center.y + r2 * sin(angle) + gap * cos(angle) / 2.);
        
        double angleE = angle + sectorAngle;
        NSPoint p3 = NSMakePoint(center.x + r2 * cos(angleE) + gap * sin(angleE) / 2.,
                                 center.y + r2 * sin(angleE) - gap * cos(angleE) / 2.);
        NSPoint p4 = NSMakePoint(center.x + r1 * cos(angleE) + gap * sin(angleE) / 2.,
                                 center.y + r1 * sin(angleE) - gap * cos(angleE) / 2.);
        
        [slice moveToPoint:p1];
        [slice appendBezierPathWithArcWithCenter:center
                                          radius:r2
                                      startAngle:rad2deg*atan2(p2.y - center.y, p2.x - center.x)
                                        endAngle:rad2deg*atan2(p3.y - center.y, p3.x - center.x)
                                       clockwise:NO];
        [slice appendBezierPathWithArcWithCenter:center
                                          radius:r1
                                      startAngle:rad2deg*atan2(p4.y - center.y,
                                                               p4.x - center.x)
                                        endAngle:rad2deg*atan2(p1.y - center.y,
                                                               p1.x - center.x)
                                       clockwise:YES];
        [slice closePath];
        [slice setLineWidth:3];
        [[NSColor blackColor] setStroke];
        [slice stroke];
        if (0) {
            [@"1" drawAtPoint:p1 withAttributes:nil];
            [@"2" drawAtPoint:p2 withAttributes:nil];
            [@"3" drawAtPoint:p3 withAttributes:nil];
            [@"4" drawAtPoint:p4 withAttributes:nil];
        }
        
#if 1
        Hershey * fontDev = [Hershey bundledFont:kHersheyDefaultFont];
        NSBezierPath * p = [fontDev copyOfPathForString:labels[ MIN(i,[labels count]-1)]
                                               withSize:100
                                          withTransform:nil];
#else
        NSBezierPath * p = [[NSBezierPath alloc] init];
        for(int x = 0; x < 10; x++)
            for(int y = 0; y < 4; y++)
                [p appendBezierPathWithOvalInRect:NSMakeRect(x, y, 1, 1)];
#endif
        NSRect pbounds = [p bounds];
        
        
        NSPoint (^map)(NSPoint)= ^NSPoint(NSPoint p){
            NSRect bbx = pbounds;
            double r1label = r1 + inset;
            double r2label = r2 - inset;
            
            if (
                ((angle + sectorAngle/2> 0.45 * M_PI) && (angle + sectorAngle/2 < 0.55 * M_PI)) ||
                ((angle + sectorAngle/2> 1.45 * M_PI) && (angle + sectorAngle/2 < 1.55 * M_PI))
            ){
                p = NSMakePoint(p.y, p.x);
                bbx = NSMakeRect(bbx.origin.y, bbx.origin.x, bbx.size.height, bbx.size.width);
                
                // special rule for the H texts - which cover about /2 of the hight 2/3's up.
                double rd = (r2label - r1label);
                double hh = 0.66;
                r1label = r1label + hh * rd - rd/4;
                r2label = r2label - (1-hh) * rd + rd/4;
            };
            
            double x = p.x - bbx.origin.x;
            double y = p.y - bbx.origin.y - bbx.size.height / 2;
            double height = bbx.size.height;
            double width = bbx.size.width;
            
            if (angle + sectorAngle/2> 0.45 * M_PI && angle + sectorAngle/2 < 1.45* M_PI){
                y = - y;
            }
            if (angle + sectorAngle/2> 0.55 * M_PI && angle + sectorAngle/2 < 1.55* M_PI) {
                x = width - x;
            }
            
            // map to r1 space
            y = y / height * ( sectorAngle * r1label - inset - gap) ; // <-- wrong - also gaps!
            x = r1label + (r2label-r1label) * x / width;
             
            // scale y out from r1 (scale 1) to r2.
            y *= x/r1label;
            
            double r = sqrt(x*x+y*y);
            double a = atan2(y,x);
            
            a += angle + sectorAngle/2;
            x = r * cos(a);
            y = r * sin(a);
    
            return NSMakePoint(x, y);
        };
        
        
        [Hershey transformBezierPath:p withTransform:map];
                
        NSAffineTransform * trans = [[NSAffineTransform alloc] init];
        [trans translateXBy:center.x yBy:center.y];
        [trans scaleBy:1];
        [p transformUsingAffineTransform:trans];
        
        [p setLineWidth: (r2-r1-gap-inset) * sectorAngle / 15];
        [p setLineJoinStyle:NSRoundLineJoinStyle];
        [p setLineCapStyle:NSRoundLineCapStyle];

        (i == steps/2) ?
        [[NSColor redColor] setStroke] :
        [[NSColor blackColor] setStroke];
        
        (i == steps/2) ?
        [[NSColor redColor] setFill] :
        [[NSColor blackColor] setFill];
        
        
        [p stroke];

    }
    
}

@end
