
Typical use:

    #include "Hershey.h"

    NSString * testStr = @"The quick brown fox jumps over the lazy dog.";
       
    NSBezierPath * p = [self.font copyOfPathForString:testStr
                                             withSize:20];
    [[NSColor blackColor] setStroke];
    
    [p setLineWidth:s/25.];
    [p setLineJoinStyle:NSRoundLineJoinStyle];
    [p setLineCapStyle:NSRoundLineCapStyle];
    
    [p stroke];

``
