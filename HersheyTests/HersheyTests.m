//
//  HersheyTests.m
//  HersheyTests
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

#import "HersheyTests.h"
#import "Hershey.h"

@implementation HersheyTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testExample
{
    NSLog(@"Hersey lib: %@",[[Hershey class] description]);
    
    int count = 0;
    for(NSString * fontName in [Hershey bundledFonts]) {
        Hershey * font = [[Hershey alloc] initCachedWithFont:fontName];
        STAssertNotNil(font, @"All build in fonts should parse just fine.");

        count ++;

        NSArray * glyphs = [font orderedArrayOfGlyps];
        STAssertTrue([glyphs count] >= 96,
                     @"All build in fonts should have at le,ast 96 glyphs in them. Something off as font %@ has %d",
                     fontName, [glyphs count]);

        NSGlyph spaceIdx = (NSGlyph)[[glyphs objectAtIndex:0] integerValue];
        STAssertTrue(spaceIdx == 32,
                     @"First entry should be the empty space - acting as a scaler; but I got %d", spaceIdx);

        int pE = 0;
        if ([font.name isEqualToString:@"japanese"])
            pE = 5;
        
        HersheyGlyphDefinition * space = [font glyph:spaceIdx];
        
        STAssertTrue([space.path elementCount] == pE,
                     @"First entry should have %d path Elements; but has %d in font %@", pE,
                     [space.path elementCount], font.name);
        
    }
    
    // Make sure we can parse them all.
    //
    STAssertTrue(count == 32,
                 @"There should be exactly valid 32 fonts in the bundle; but found and checked %d", count);
    
    NSLog(@"All test completed just fine..");
}

@end
