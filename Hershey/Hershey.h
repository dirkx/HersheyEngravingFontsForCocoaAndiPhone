//
//  Hershey.h
//  Hershey
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

#import <Foundation/Foundation.h>

@interface HersheyGlyphDefinition : NSDictionary;
@property (readonly,nonatomic) NSGlyph idx; // Hersey/US-Navy index number.
@property (readonly,nonatomic) int lx, rx; // left and rightmost extend.
@property (readonly,nonatomic) int baseY; // baseline
@property (readonly,nonatomic) int accentY; // height
@property (readonly,nonatomic) NSBezierPath *path;
@end

@interface Hershey : NSObject

@property (readonly,nonatomic) NSString *name;
@property (readonly,nonatomic) NSDictionary *glyphDefinitions;
@property (readonly,nonatomic) int baseY; // baseline
@property (readonly,nonatomic) int accentY; // height

extern NSString * const kHersheyDefaultFont;
extern NSString * const kHersheyDefaultFontExtension;

+(NSArray *)bundledFonts;

+(void)transformBezierPath:(NSBezierPath *)aPath withTransform:(NSPoint (^)(NSPoint p))transform;

-(id)initCachedWithFont:(NSString *)font;
-(id)initWithPath:(NSString *)path;

-(NSArray *)orderedArrayOfGlyps;
-(HersheyGlyphDefinition *)glyph:(NSGlyph)idx;

// We return a copy here - as to allow
// further transformations ofthe NSBezierPath
// without that damaging the original font
// definition.
//
-(NSBezierPath *)copyOfPathForString:(NSString *)txt
                      withSize:(double)pointSize;

-(NSBezierPath *)copyOfPathForString:(NSString *)txt
                      withSize:(double)pointSize
                 withTransform:(NSPoint (^)(NSPoint p))transformOrNil;
@end
