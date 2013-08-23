//
//  CatalogueView.m
//  Hershey Demo
//
//  Created by Dirk-Willem van Gulik on 23-08-13.
//  Copyright (c) 2013 Dirk-Willem van Gulik. All rights reserved.
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
        fontView.font = [[Hershey alloc] initCachedWithFont:font];
        
        [self addSubview:fontView];
    }
    [self resizeSubviewsWithOldSize:self.superview.bounds.size];
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
