//
//  RBPopoverSelectControl.h
//
//  Created by Ryhor Burakou on 07/04/2014.
//

#import <UIKit/UIKit.h>

@class RBPopoverSelectControl;
@protocol RBPopoverSelectControlDelegate <NSObject>


@optional

/**
 Called when selection changes
 */
- (void) popoverSelectControlSelectionChanged:(RBPopoverSelectControl*)control;

@end

@interface RBPopoverSelectControl : UIControl

/**
 */
@property (weak, nonatomic) IBOutlet id<RBPopoverSelectControlDelegate>delegate;

/**
 NSString items that can be selected
 */
@property (nonatomic, strong) NSArray *items;

/**
 Specify YES if items can be de-selected, thus leaving the possibility of no selection
 */
@property (nonatomic, strong) NSNumber *allowDeselection;

/**
 Specify YES if popover is closed after selecting smth
 */
@property (nonatomic, strong) NSNumber *closeOnSelect;

/**
 Index of selected element in items Array
 */
@property (assign, readwrite) NSInteger selectedIndex;

/**
 Caption of the popover window. Pass nil, if you would like no title.
 */
@property (nonatomic, retain) NSString *caption;

/**
 Placeholder that will be shown when no selection has been made
 */
@property (nonatomic, retain) NSString *placeholder;

/**
 Returns YES if selectedIndex is > 0
 */
- (BOOL) isSomethingSelected;


- (void) presentFromBarButtonItem:(UIBarButtonItem*)control;
- (void) presentFromControl:(UIView*)control;
@end
