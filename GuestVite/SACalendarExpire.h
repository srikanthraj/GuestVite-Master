//
//  SACalendarExpire.h
//  SACalendarExpireExample
//
//  Created by Nop Shusang on 7/10/14.
//  Copyright (c) 2014 SyncoApp. All rights reserved.
//
//  Distributed under MIT License

#import <UIKit/UIKit.h>
#import "SACalendarConstants.h"

@protocol SACalendarExpireDelegate;
@interface SACalendarExpire : UIView

@property (nonatomic, weak) id<SACalendarExpireDelegate> delegate;

/**
 *  Default constructor. Calendar will begin at current month
 *
 *  @param frame of the calendar
 *
 *  @return initialized calendar
 */
- (id)initWithFrame:(CGRect)frame;

/**
 *  Begin calendar at specific month and year
 *
 *  @param frame of the calendar
 *  @param m     month to begin calendar
 *  @param y     year to begin calendar
 *
 *  @return initialized calendar starting at mm/yyyy
 */
- (id)initWithFrame:(CGRect)frame month:(int)m year:(int)y;

/**
 *  Calendar will begin at current month. The user can also specify other properties
 *
 *  @param frame     of the calendar
 *  @param direction scroll direction, default to horizontal
 *  @param paging    paging enabled, default to yes
 *
 *  @return initialized calendar
 */
-(id)initWithFrame:(CGRect)frame
   scrollDirection:(scrollDirection)direction
     pagingEnabled:(BOOL)paging;

/**
 *  The complete constructor
 *
 *  @param frame     of the calendar
 *  @param m         month to begin calendar
 *  @param y         year to begin calendar
 *  @param direction scroll direction, default to horizontal
 *  @param paging    paging enabled, default to yes
 *
 *  @return initialized calendar
 */
-(id)initWithFrame:(CGRect)frame
             month:(int)m year:(int)y
   scrollDirection:(scrollDirection)direction
     pagingEnabled:(BOOL)paging;
@end

@protocol SACalendarExpireExpireDelegate <NSObject>
@optional

/**
 *  A delegate function that get called once the calendar changed to display a different month.
 *  This is caused by swiping left or right
 *
 *  @param calendar The calendar object that get changed
 *  @param month    The new month displayed
 *  @param year     The new year displayed
 */
-(void) SACalendarExpire:(SACalendarExpire*)calendar didDisplayCalendarForMonth:(int)month year:(int)year;

/**
 *  This function get called when a specific date is selected
 *
 *  @param calendar The calendar object that the selected date is on
 *  @param day      The date selected
 *  @param month    The month selected
 *  @param year     The year selected
 */

//Test
-(void) SACalendarExpire:(SACalendarExpire*)calendar1 didSelectDateExpire:(int)day month:(int)month year:(int)year;

@end