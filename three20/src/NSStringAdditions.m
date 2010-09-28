//
// Copyright 2009-2010 Facebook
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "Three20/NSStringAdditions.h"

#import "Three20/TTDebug.h"
#import "Three20/TTMarkupStripper.h"
#include <libxml/parserInternals.h>
#include <libxml/parser.h>


///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NSString (TTAdditions)


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isWhitespaceAndNewlines {
  NSCharacterSet* whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
  for (NSInteger i = 0; i < self.length; ++i) {
    unichar c = [self characterAtIndex:i];
    if (![whitespace characterIsMember:c]) {
      return NO;
    }
  }
  return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isWhitespace {
  return [self isWhitespaceAndNewlines];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isEmptyOrWhitespace {
  return !self.length || 
         ![self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)stringByRemovingHTMLTags {
  TTMarkupStripper* stripper = [[[TTMarkupStripper alloc] init] autorelease];
  return [stripper parse:self];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// Copied and pasted from http://www.mail-archive.com/cocoa-dev@lists.apple.com/msg28175.html
- (NSDictionary*)queryDictionaryUsingEncoding:(NSStringEncoding)encoding {
  NSCharacterSet* delimiterSet = [NSCharacterSet characterSetWithCharactersInString:@"&;"];
  NSMutableDictionary* pairs = [NSMutableDictionary dictionary];
  NSScanner* scanner = [[[NSScanner alloc] initWithString:self] autorelease];
  while (![scanner isAtEnd]) {
    NSString* pairString = nil;
    [scanner scanUpToCharactersFromSet:delimiterSet intoString:&pairString];
    [scanner scanCharactersFromSet:delimiterSet intoString:NULL];
    NSArray* kvPair = [pairString componentsSeparatedByString:@"="];
    if (kvPair.count == 2) {
      NSString* key = [[kvPair objectAtIndex:0]
                       stringByReplacingPercentEscapesUsingEncoding:encoding];
      NSString* value = [[kvPair objectAtIndex:1]
                         stringByReplacingPercentEscapesUsingEncoding:encoding];
      [pairs setObject:value forKey:key];
    }
  }

  return [NSDictionary dictionaryWithDictionary:pairs];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)stringByAddingQueryDictionary:(NSDictionary*)query {
  NSMutableArray* pairs = [NSMutableArray array];
  for (NSString* key in [query keyEnumerator]) {
    NSString* value = [query objectForKey:key];
    value = [value stringByReplacingOccurrencesOfString:@"?" withString:@"%3F"];
    value = [value stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"];
    NSString* pair = [NSString stringWithFormat:@"%@=%@", key, value];
    [pairs addObject:pair];
  }
  
  NSString* params = [pairs componentsJoinedByString:@"&"];
  if ([self rangeOfString:@"?"].location == NSNotFound) {
    return [self stringByAppendingFormat:@"?%@", params];
  } else {
    return [self stringByAppendingFormat:@"&%@", params];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSComparisonResult)versionStringCompare:(NSString *)other {
  NSArray *oneComponents = [self componentsSeparatedByString:@"a"];
  NSArray *twoComponents = [other componentsSeparatedByString:@"a"];

  // The parts before the "a"
  NSString *oneMain = [oneComponents objectAtIndex:0];
  NSString *twoMain = [twoComponents objectAtIndex:0];

  // If main parts are different, return that result, regardless of alpha part
  NSComparisonResult mainDiff;
  if ((mainDiff = [oneMain compare:twoMain]) != NSOrderedSame) {
    return mainDiff;
  }

  // At this point the main parts are the same; just deal with alpha stuff
  // If one has an alpha part and the other doesn't, the one without is newer
  if ([oneComponents count] < [twoComponents count]) {
    return NSOrderedDescending;
  } else if ([oneComponents count] > [twoComponents count]) {
    return NSOrderedAscending;
  } else if ([oneComponents count] == 1) {
    // Neither has an alpha part, and we know the main parts are the same
    return NSOrderedSame;
  }

  // At this point the main parts are the same and both have alpha parts. Compare the alpha parts
  // numerically. If it's not a valid number (including empty string) it's treated as zero.
  NSNumber *oneAlpha = [NSNumber numberWithInt:[[oneComponents objectAtIndex:1] intValue]];
  NSNumber *twoAlpha = [NSNumber numberWithInt:[[twoComponents objectAtIndex:1] intValue]];
  return [oneAlpha compare:twoAlpha];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)stringByURLEncodingStringParameter
{
	// NSURL's stringByAddingPercentEscapesUsingEncoding: does not escape
	// some characters that should be escaped in URL parameters, like / and ?; 
	// we'll use CFURL to force the encoding of those
	//
	// We'll explicitly leave spaces unescaped now, and replace them with +'s
	//
	// Reference: http://www.ietf.org/rfc/rfc3986.txt
	
	NSString *resultStr = self;
	
	CFStringRef originalString = (CFStringRef) self;
	CFStringRef leaveUnescaped = CFSTR(" ");
	CFStringRef forceEscaped = CFSTR("!*'();:@&=+$,/?%#[]");
	
	CFStringRef escapedStr;
	escapedStr = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
														 originalString,
														 leaveUnescaped, 
														 forceEscaped,
														 kCFStringEncodingUTF8);
	
	if( escapedStr )
	{
		NSMutableString *mutableStr = [NSMutableString stringWithString:(NSString *)escapedStr];
		CFRelease(escapedStr);
		
		// replace spaces with plusses
		[mutableStr replaceOccurrencesOfString:@" "
									withString:@"%20"
									   options:0
										 range:NSMakeRange(0, [mutableStr length])];
		resultStr = mutableStr;
	}
	return resultStr;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)stringByDecodingHTMLEntities
{
	 xmlParserCtxtPtr ctxt = xmlNewParserCtxt();
	 char *buffer = (char*)xmlStringDecodeEntities( ctxt, (const xmlChar *)[self UTF8String], XML_SUBSTITUTE_BOTH, 0, 0, 0 );
	 NSString *decoded = [[NSString alloc] initWithUTF8String:buffer];
	 
	 free( buffer );
	 xmlFreeParserCtxt( ctxt );
	 
	 return [decoded autorelease];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)stringByDecodingHTMLEntitiesManually
{
	NSRange ampRange = [self rangeOfString:@"&"];

	if( ampRange.location == NSNotFound )
	{
		return self;
	}
	else
	{
		
		NSMutableString *escaped = [NSMutableString stringWithString:self];
		
		NSArray *entities = [NSArray arrayWithObjects: 
							 @"&amp;", @"&lt;", @"&gt;", @"&quot;",
							 /* 160 = nbsp */
							 @"&nbsp;", @"&iexcl;", @"&cent;", @"&pound;", @"&curren;", @"&yen;", @"&brvbar;",
							 @"&sect;", @"&uml;", @"&copy;", @"&ordf;", @"&laquo;", @"&not;", @"&shy;", @"&reg;",
							 @"&macr;", @"&deg;", @"&plusmn;", @"&sup2;", @"&sup3;", @"&acute;", @"&micro;",
							 @"&para;", @"&middot;", @"&cedil;", @"&sup1;", @"&ordm;", @"&raquo;", @"&frac14;",
							 @"&frac12;", @"&frac34;", @"&iquest;", @"&Agrave;", @"&Aacute;", @"&Acirc;",
							 @"&Atilde;", @"&Auml;", @"&Aring;", @"&AElig;", @"&Ccedil;", @"&Egrave;",
							 @"&Eacute;", @"&Ecirc;", @"&Euml;", @"&Igrave;", @"&Iacute;", @"&Icirc;", @"&Iuml;",
							 @"&ETH;", @"&Ntilde;", @"&Ograve;", @"&Oacute;", @"&Ocirc;", @"&Otilde;", @"&Ouml;",
							 @"&times;", @"&Oslash;", @"&Ugrave;", @"&Uacute;", @"&Ucirc;", @"&Uuml;", @"&Yacute;",
							 @"&THORN;", @"&szlig;", @"&agrave;", @"&aacute;", @"&acirc;", @"&atilde;", @"&auml;",
							 @"&aring;", @"&aelig;", @"&ccedil;", @"&egrave;", @"&eacute;", @"&ecirc;", @"&euml;",
							 @"&igrave;", @"&iacute;", @"&icirc;", @"&iuml;", @"&eth;", @"&ntilde;", @"&ograve;",
							 @"&oacute;", @"&ocirc;", @"&otilde;", @"&ouml;", @"&divide;", @"&oslash;", @"&ugrave;",
							 @"&uacute;", @"&ucirc;", @"&uuml;", @"&yacute;", @"&thorn;", @"&yuml;", nil];
		
		NSArray *characters = [NSArray arrayWithObjects:@"&", @"<", @">", @"\"", nil];
		
		int i, count = [entities count], characterCount = [characters count];
		
		// Html
		for( i = 0; i < count; i++ )
		{
			NSRange range = [self rangeOfString: [entities objectAtIndex:i]];
			if( range.location != NSNotFound )
			{
				if( i < characterCount )
				{
					[escaped replaceOccurrencesOfString:[entities objectAtIndex: i] 
											 withString:[characters objectAtIndex:i] 
												options:NSLiteralSearch 
												  range:NSMakeRange(0, [escaped length])];
				}
				else
				{
					[escaped replaceOccurrencesOfString:[entities objectAtIndex: i] 
											 withString:[NSString stringWithFormat: @"%C", (160-characterCount) + i] 
												options:NSLiteralSearch 
												  range:NSMakeRange(0, [escaped length])];
				}
			}
		}
		
		// Decimal & Hex
		NSRange start, finish, searchRange = NSMakeRange(0, [escaped length]);
		i = 0;
		
		while( i < [escaped length] )
		{
			start = [escaped rangeOfString: @"&#" 
								   options: NSCaseInsensitiveSearch 
									 range: searchRange];
			
			finish = [escaped rangeOfString: @";" 
									options: NSCaseInsensitiveSearch 
									  range: searchRange];
			
			if( start.location != NSNotFound && finish.location != NSNotFound &&
			   finish.location > start.location )
			{
				NSRange entityRange = NSMakeRange(start.location, (finish.location - start.location) + 1);
				NSString *entity = [escaped substringWithRange: entityRange];     
				NSString *value = [entity substringWithRange: NSMakeRange(2, [entity length] - 2)];
				
				[escaped deleteCharactersInRange: entityRange];
				
				if( [value hasPrefix: @"x"] )
				{
					unsigned tempInt = 0;
					NSScanner *scanner = [NSScanner scannerWithString: [value substringFromIndex: 1]];
					[scanner scanHexInt: &tempInt];
					[escaped insertString: [NSString stringWithFormat: @"%C", tempInt] atIndex: entityRange.location];
				}
				else
				{
					[escaped insertString: [NSString stringWithFormat: @"%C", [value intValue]] atIndex: entityRange.location];
				}
				i = start.location;
			}
			else i++;
			searchRange = NSMakeRange( i, [escaped length] - i );
		}
		
		return escaped;    // Note this is autoreleased
	}
}

@end

