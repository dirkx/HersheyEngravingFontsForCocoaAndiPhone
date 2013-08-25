//
//  CatalogueView.m
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

#import "CatalogueView.h"
#import "HersheyView.h"
#import "Hershey.h"

@implementation CatalogueView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self completeInit];
    }
    
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self completeInit];
    }
    
    return self;
}

-(void)completeInit {
    for(NSString * font in [Hershey bundledFonts]) {
        HersheyView * fontView = [[HersheyView alloc] initWithFrame:NSMakeRect(0,0,50,50)];
        fontView.font = [Hershey bundledFont:font];
        
        [self addSubview:fontView];
    }
    [self resizeSubviewsWithOldSize:self.superview.bounds.size];
}

-(BOOL)knowsPageRange:(NSRangePointer)range {
    range->location = 1;
    range->length = [self.subviews count];
    return YES;
}

- (NSRect)rectForPage:(int)page {
    return [[self.subviews objectAtIndex:page-1] frame];
}

- (void)resizeSubviewsWithOldSize:(NSSize)oldBoundsSize
{
    NSInteger N = [self.subviews count];

    double ratio = 0.85;
    double margin = 16;
    double w = self.frame.size.width - margin * 2;
    double h = MAX(100,w * ratio);

    // w = MAX(300,h / ratio);
    // h = w * ratio;
    
    self.frame = NSMakeRect(0,0,
                             w + 2 * margin,
                             margin + N * (margin + h));
    [self setNeedsDisplay:YES];
    
    int i = 0;
    for(NSView * view in self.subviews)
    {
        // only count/resize our type of views; ignore buttons and what not.
        //
        if (![view isKindOfClass:[HersheyView class]])
            continue;
        
        double x = margin;
        double y = margin + i * (margin + h);
        
        [view setFrame:NSMakeRect(x,y, w, h)];
        [view setNeedsDisplay:YES];
        
        i++;
    }

    [super resizeSubviewsWithOldSize:oldBoundsSize];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor whiteColor] set];
    NSRectFill(self.bounds);
}
@end
