//
//  MPopoverSelectControl.h
//
//  Created by Ryhor Burakou on 07/04/2014.
//

#import <UIKit/UIKit.h>

@interface RBPopoverSelectControl : UIControl


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
 Returns YES if selectedIndex is > 0
 */
- (BOOL) isSomethingSelected;
@end
