//
//  BGAnnotationView.m
//  BusGnosis
//
//  Created by Michael Rockhold on 7/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "BGAnnotationView.h"
#import "BusInfo.h"
#import <math.h>

static NSString* bGAnnotationViewReuseIdentifier = @"BusGnosticAnnotation";

static CGMutablePathRef s_ellipsePath;
static CGMutablePathRef s_arrowPath;
static UIFont*		s_textFont;
static CGRect		s_textRect;
static CGSize		s_frameSize;

@implementation BGAnnotationView

+(void)initialize
{
	if (self == [BGAnnotationView class])
	{
		s_textFont =  [UIFont boldSystemFontOfSize:10];
				
		CGSize textSize = [@"888" sizeWithFont:s_textFont];
		s_textRect = CGRectMake(-textSize.width/2, -textSize.width/2, textSize.width, textSize.width);
		CGRect ellipseRect = UIEdgeInsetsInsetRect(s_textRect, UIEdgeInsetsMake (-2, -2, -2, -2));
		s_frameSize = CGSizeMake(ellipseRect.size.width * 1.5, ellipseRect.size.height * 1.5);
				
		s_textRect.origin.y += 2;
		
		s_ellipsePath = CGPathCreateMutable();
		CGPathAddEllipseInRect(s_ellipsePath, nil, ellipseRect);
		
		s_arrowPath = CGPathCreateMutable();
		float x = -s_frameSize.width/2;
		float y = -s_frameSize.height/2;
		
		CGPoint points[] = { 
			{0, y},
			{-x, 0},
			{x, 0}
		};
		CGPathAddLines (s_arrowPath, nil, points, 3);
	}
}

+ (BGAnnotationView*)reuseExistingView:(MKMapView *)mv Annotation:(id <MKAnnotation>)ann
{	
	BGAnnotationView* bgv = (BGAnnotationView*)[mv dequeueReusableAnnotationViewWithIdentifier:bGAnnotationViewReuseIdentifier];
	
	return bgv;
}

+ (BGAnnotationView*)newOrUsed:(MKMapView *)mv Annotation:(id <MKAnnotation>)ann
{
	BGAnnotationView* oldView = [BGAnnotationView reuseExistingView:mv Annotation:ann];
    
	return (oldView != nil) ? oldView : [(BGAnnotationView*)[[BGAnnotationView alloc] initWithMapView:mv Annotation:ann] retain];
}

- (id)initWithMapView:(MKMapView *)mv Annotation:(id <MKAnnotation>)ann
{
	id this = [super initWithAnnotation:ann reuseIdentifier:bGAnnotationViewReuseIdentifier];
	
	if (this != nil)
	{
		[self setFrame:CGRectMake(0, 0, s_frameSize.width, s_frameSize.height)];
		self.opaque = NO;
	}
	
	return this;
}

- (void)dealloc
{
	//CGPathRelease(m_arrowPath);
	//CGPathRelease(m_ellipsePath);
	[super dealloc];
}

CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};
CGFloat RadiansToDegrees(CGFloat radians) {return radians * 180 / M_PI;};

- (void)drawRect:(CGRect)rect
{	
	NSString* tag = [NSString stringWithFormat:@"%@", ((BusInfo*)self.annotation).route];
	double heading = [((BusInfo*)self.annotation).heading doubleValue];
	if ( heading < 0 || heading >= 360 ) heading = 0;

	CGContextRef myContext = UIGraphicsGetCurrentContext();
	[[UIColor blackColor] setStroke];
	
	CGContextTranslateCTM(myContext, s_frameSize.width/2, s_frameSize.height/2);
	
	CGContextSaveGState(myContext);

	[[UIColor redColor] set];
	CGContextRotateCTM(myContext, DegreesToRadians(heading));
	CGContextAddPath(myContext, s_arrowPath);
	CGContextDrawPath(myContext, kCGPathFillStroke);

	[[UIColor blueColor] set];
	CGContextAddPath(myContext, s_ellipsePath);
	CGContextDrawPath(myContext, kCGPathFillStroke);
	
	CGContextRestoreGState(myContext);
	
	[[UIColor whiteColor] set];		
	[tag drawInRect:s_textRect withFont:s_textFont lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
}

@end
