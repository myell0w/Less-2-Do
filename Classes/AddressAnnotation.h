//
//  AddressAnnotation.h
//  Less2Do
//
//  Created by Philip Messlehner on 04.01.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface AddressAnnotation : MKPlacemark {
	CLLocationCoordinate2D _coordinate;
	NSString *_title;
	NSString *_subtitle;
	Context *_context;
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subtitle;
@property (nonatomic, retain) Context *context;
@property (nonatomic) CLLocationCoordinate2D coordinate;

+ (MKPinAnnotationView *)viewForAnnotation:(AddressAnnotation *)annotation withColor:(MKPinAnnotationColor)color;
+ (MKPinAnnotationView *)viewForAnnotation:(AddressAnnotation *)annotation withColor:(MKPinAnnotationColor)color andContext:(Context *)context;


@end
