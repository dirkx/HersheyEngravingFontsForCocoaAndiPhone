//
//  PrintableWindow.m
//  Hershey Demo
//
//  Created by Dirk-Willem van Gulik on 25-08-13.
//  Copyright (c) 2013 Dirk-Willem van Gulik. All rights reserved.
//

#import "PrintableWindow.h"

@implementation PrintableWindow

-(IBAction)print:(id)sender {
    
    if ([self.printableView respondsToSelector:@selector(print:)]) {
        [self.printableView performSelector:@selector(print:) withObject:sender];
        return;
    }
    
    NSPrintInfo *printInfo;
    NSPrintOperation *printOp;
    printInfo = [NSPrintInfo sharedPrintInfo];
    
    [printInfo setHorizontalPagination: NSFitPagination];
    [printInfo setVerticalPagination: NSFitPagination];
    
    // obnoxious or useful ?
    // [printInfo setOrientation:  NSLandscapeOrientation];
    // [printInfo setScalingFactor:1.0]; - or do we give the user control or max it to page-printborders and a few percent ?
    
    [printInfo setVerticallyCentered:YES];
    [printInfo setHorizontallyCentered:YES];
    
    printOp = [NSPrintOperation printOperationWithView:self.printableView printInfo:printInfo];
    
    [printOp setShowsPrintPanel:YES];
    [printOp setShowsProgressPanel:YES];
    
    [printOp runOperation];
}
@end
