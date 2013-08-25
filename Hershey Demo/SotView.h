//
//  SotView.h
//  Hershey Demo
//
//  Created by Dirk-Willem van Gulik on 25-08-13.
//  Copyright (c) 2013 Dirk-Willem van Gulik. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SotView : NSView <NSDrawerDelegate>

-(IBAction)setSteps:(NSSlider *)sender;
@end
