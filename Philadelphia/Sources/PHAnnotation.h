//
//  CLAnnotation.h
//  California
//
//  Created by Igor Bogatchuk on 2/23/14.
//  Copyright (c) 2014 cogniance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface PHAnnotation : NSObject <MKAnnotation>

@property (nonatomic, assign, readonly) CLLocationDegrees latitude;
@property (nonatomic, assign, readonly) CLLocationDegrees longitude;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* subtitle;

//@property (nonatomic, assign) MKPinAnnotationColor pinColor;
@property (nonatomic, strong) NSString* stopId;

- (id)initWithLatitude:(CLLocationDegrees)latitude
				 longitude:(CLLocationDegrees)longitude
					  title:(NSString*)title
				  subtitle:(NSString*)subtitle;

@end

