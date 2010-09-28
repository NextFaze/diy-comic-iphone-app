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

#import "Three20/TTTableViewDelegate.h"

#import "Three20/TTGlobalCore.h"

#import "Three20/TTTableViewDataSource.h"
#import "Three20/TTTableViewController.h"
#import "Three20/TTTableItem.h"
#import "Three20/TTTableItemCell.h"
#import "Three20/TTTableHeaderView.h"
#import "Three20/TTTableView.h"
#import "Three20/TTStyledTextLabel.h"
#import "Three20/TTNavigator.h"
#import "Three20/TTDefaultStyleSheet.h"
#import "Three20/TTURLRequestQueue.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTTableViewDelegate

@synthesize controller = _controller;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSObject


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithController:(TTTableViewController*)controller {
  if (self = [super init]) {
    _controller = controller;
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_headers);
  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * If tableHeaderTintColor has been specified in the global style sheet and this is a plain table
 * (i.e. not a grouped one), then we create header view objects for each header and handle the
 * drawing ourselves.
 */
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  if (tableView.style == UITableViewStylePlain && TTSTYLEVAR(tableHeaderTintColor)) {
    if ([tableView.dataSource respondsToSelector:@selector(tableView:titleForHeaderInSection:)]) {
      NSString* title = [tableView.dataSource tableView:tableView titleForHeaderInSection:section];
      if (title.length > 0) {
        TTTableHeaderView* header = [_headers objectForKey:title];
        if (nil == header) {
          if (nil == _headers) {
            _headers = [[NSMutableDictionary alloc] init];
          }
          header = [[[TTTableHeaderView alloc] initWithTitle:title] autorelease];
          [_headers setObject:header forKey:title];
        }
        return header;
      }
    }
  }
  return nil;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	id<TTTableViewDataSource> dataSource = (id<TTTableViewDataSource>)tableView.dataSource;
	id object = [dataSource tableView:tableView objectForRowAtIndexPath:indexPath];
	
	if( [object isKindOfClass:[TTTableLinkedItem class]] )
	{
		TTTableLinkedItem* item = object;
			
		if( item.URL && [_controller shouldOpenURL:item.URL] )
		{
			// If the TTTableItem has userInfo, wrap it up and send it along to the URL
			if( item.userInfo )
			{
				NSDictionary *userInfoDict;
				
				// If userInfo is a dictionary, pass it along else create a dictionary
				if( [item.userInfo isKindOfClass:[NSDictionary class]] )
				{
					userInfoDict = item.userInfo;
				}
				else
				{
					userInfoDict = [NSDictionary dictionaryWithObject:item.userInfo forKey:@"__userInfo__"];
				}

				[[TTNavigator navigator] openURLAction:[[[TTURLAction actionWithURLPath:item.URL]
														 applyQuery:userInfoDict]
														applyAnimated:YES]];
			}
			else
			{
				TTOpenURL( item.URL );
			}
		}


		if ([object isKindOfClass:[TTTableButton class]])
		{
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
		}
		else if ([object isKindOfClass:[TTTableMoreButton class]])
		{
			TTTableMoreButton* moreLink = (TTTableMoreButton*)object;
			moreLink.isLoading = YES;
			TTTableMoreButtonCell* cell	= (TTTableMoreButtonCell*)[tableView cellForRowAtIndexPath:indexPath];
			cell.animating = YES;
			[tableView deselectRowAtIndexPath:indexPath animated:YES];

			[_controller.model load:TTURLRequestCachePolicyDefault more:YES];
		}
	}

  [_controller didSelectObject:object atIndexPath:indexPath];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Similar logic to the above. If the user taps an accessory item and there is an associated URL,
 * we navigate to that URL.
 */
- (void)tableView:(UITableView*)tableView
        accessoryButtonTappedForRowWithIndexPath:(NSIndexPath*)indexPath {
  id<TTTableViewDataSource> dataSource = (id<TTTableViewDataSource>)tableView.dataSource;
  id object = [dataSource tableView:tableView objectForRowAtIndexPath:indexPath];
  if ([object isKindOfClass:[TTTableLinkedItem class]]) {
    TTTableLinkedItem* item = object;
    if (item.accessoryURL && [_controller shouldOpenURL:item.accessoryURL]) {
      TTOpenURL(item.accessoryURL);
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIScrollViewDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
  [TTURLRequestQueue mainQueue].suspended = YES;
  return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
  [TTURLRequestQueue mainQueue].suspended = NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  if (_controller.menuView) {
    [_controller hideMenu:YES];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
  [TTURLRequestQueue mainQueue].suspended = YES;

  [_controller didBeginDragging];
  
  if ([scrollView isKindOfClass:[TTTableView class]]) {
    TTTableView* tableView = (TTTableView*)scrollView;
    tableView.highlightedLabel.highlightedNode = nil;
    tableView.highlightedLabel = nil;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
  if (!decelerate) {
    [TTURLRequestQueue mainQueue].suspended = NO;
  }

  [_controller didEndDragging];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  [TTURLRequestQueue mainQueue].suspended = NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTTableViewDelegate

- (void)tableView:(UITableView*)tableView touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
	// If we have a menuView up we dismiss it ONLY if the touch was not on the menuView
	if( _controller.menuView )
	{
		UITouch *touch = [touches anyObject];
		CGPoint point = [touch locationInView:_controller.menuView];
		if( point.y < 0 || point.y > _controller.menuView.frame.size.height )
		{
		      [_controller hideMenu:YES];
		}
	}
}


@end
