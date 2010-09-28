//
//  NSDate.m
//  DIYComic
//
//  Created by Andreas Wulf on 7/05/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSDate.h"


@implementation NSDate (DIYComic)

- (NSString*)formatRelativeTimeRevised {
	NSDate *currentDate = [NSDate date];
		
	NSDateComponents *components = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit 
									fromDate:self toDate:[NSDate date] options:0];
	
	NSString *format = @"%d %@%@";
	NSInteger compared = [currentDate compare:self];
	if (compared>0) {
		format = @"%d %@%@ ago";
	} else if (compared==0) {
		return @"Now";
	}
	
	NSInteger year = abs([components year]);
	NSInteger month = abs([components month]);
	NSInteger day = abs([components day]);
	NSInteger hour = abs([components hour]);
	NSInteger min = abs([components minute]);
	NSInteger second = abs([components second]);
	
	NSInteger number = 0;
	NSString *unit = @"";
	
	if (year) {
		number = year;
		unit = @"year";
		if (month>6) {
			number++;
		}
		
	} else if (month) {
		number = month;
		unit = @"month";
		if (day>3) {
			number++;
		}
		
	} else if (day) {
		number = day;
		unit = @"day";
		if (hour>12) {
			number++;
		}
		
	} else if (hour) {
		number = hour;
		unit = @"hour";
		if (min>30) {
			number++;
		}
		
	} else if (min) {
		number = min;
		unit = @"minute";
		if (second>30) {
			number++;
		}
		
	} else if (second) {
		number = second;
		unit = @"second";
	}
	
	NSString *plural = @"";
	if (number>1) {
		plural=@"s";
	}

	return [NSString stringWithFormat:format,number,unit,plural];
	
	
}

@end
