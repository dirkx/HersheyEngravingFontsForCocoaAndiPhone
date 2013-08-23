
Typical use:

<code>
  #include "Hershey.h"

  NSString * testStr = @"The quick brown fox jumps over the lazy dog.";
    
  NSBezierPath * p = [self.font copyOfPathForString:testStr
                                     withSize:fontSize*1.7];
  [[NSColor blackColor] setStroke];
    
  [p setLineWidth:s/25.];
  [p setLineJoinStyle:NSRoundLineJoinStyle];
  [p setLineCapStyle:NSRoundLineCapStyle];

  [p stroke];

</code>

