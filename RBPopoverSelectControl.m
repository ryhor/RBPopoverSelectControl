//
//  RBPopoverSelectControl.m
//
//  Created by Ryhor Burakou on 07/04/2014.
//

#import "RBPopoverSelectControl.h"

static const int TABLE_BASIC_ROW_HEIGHT = 44;
static const int TABLE_MIN_VISIBLE_ROWS = 3;
static const int TABLE_PADDING = 42;

@interface RBMarginlessInternalTableController : UITableViewController
@end

@implementation RBMarginlessInternalTableController
- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    //ios 8 margins
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)])
        self.tableView.layoutMargins = UIEdgeInsetsZero;
}

@end

@interface CenteredLabelCheckmarkCell : UITableViewCell
@property (nonatomic, strong) UILabel *centeredLabel;
@end

@implementation CenteredLabelCheckmarkCell
- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.centeredLabel = [UILabel new];
        [self addSubview:self.centeredLabel];
    }
    return self;
}

- (void) p_createCenteredLabel
{
    if (self.centeredLabel == nil)
    {
        self.centeredLabel = [UILabel new];
        [self.contentView addSubview:self.centeredLabel];
    }
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    [self p_createCenteredLabel];
    self.centeredLabel.frame = self.bounds;
    self.centeredLabel.font = self.textLabel.font;
}

@end


@interface RBPopoverSelectControl () <UITextFieldDelegate, UIPopoverControllerDelegate, UITableViewDelegate, UITableViewDataSource>

//ui
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) RBMarginlessInternalTableController *tableController;

//popover
@property (nonatomic, strong) UIPopoverController *popover;
@end

@implementation RBPopoverSelectControl
@synthesize selectedIndex = _selectedIndex;

- (instancetype) init
{
    self = [super init];
    if (self)
    {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initialize];
    }
    return self;
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self initialize];
    }
    return self;
}

- (void) initialize
{
    //arrows
    self.preferredArrowDirection = UIPopoverArrowDirectionAny;
    
    //style
    self.textAlignment = NSTextAlignmentLeft;
    
    //text field
    self.textField = [[UITextField alloc]initWithFrame:self.bounds];
    self.textField.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.textField.translatesAutoresizingMaskIntoConstraints = YES;
    self.textField.borderStyle = UITextBorderStyleRoundedRect;
    self.textField.inputView = [UIView new];
    self.textField.delegate = self;
    [self addSubview:self.textField];
    
    //icon
    UIImageView *iv = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"rbpopover-down.png"]];
    self.textField.rightView = iv;
    self.textField.rightViewMode = UITextFieldViewModeAlways;
    
    //table
    self.tableController = [[RBMarginlessInternalTableController alloc]initWithStyle:UITableViewStylePlain];
    self.tableController.tableView.allowsMultipleSelection = NO;
    if ([self.tableController.tableView respondsToSelector:@selector(setSeparatorInset:)]) self.tableController.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableController.tableView.delegate = self;
    self.tableController.tableView.dataSource = self;
    
    [self.tableController.tableView registerClass:[CenteredLabelCheckmarkCell class]
                           forCellReuseIdentifier:NSStringFromClass([CenteredLabelCheckmarkCell class])];
    
    //table separators unneeded
    self.tableController.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    //popover
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:self.tableController];
    nav.navigationBarHidden = YES;
    self.popover = [[UIPopoverController alloc]initWithContentViewController:nav];
    self.popover.delegate = self;
    
    //default is nothing selected
    self.selectedIndex = -1;
}

#pragma mark - TextField
- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    [self presentFromControl:textField];
}

#pragma mark - Popover
- (void) popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [self endEditing:YES];
    if ([self.delegate respondsToSelector:@selector(popoverSelectControlDismissed:)])
        [self.delegate popoverSelectControlDismissed:self];
}

- (void) presentFromBarButtonItem:(UIBarButtonItem*)control
{
    [self p_preparePopoverSize];
    [self.popover presentPopoverFromBarButtonItem:control permittedArrowDirections:self.preferredArrowDirection animated:YES];
}

- (void) presentFromControl:(UIView*)control
{
    [self p_preparePopoverSize];
    [self.popover presentPopoverFromRect:control.frame inView:control.superview permittedArrowDirections:self.preferredArrowDirection animated:YES];
}

- (void) p_preparePopoverSize
{
    NSInteger count = [self tableView:self.tableController.tableView numberOfRowsInSection:0];
    CGFloat height = TABLE_BASIC_ROW_HEIGHT;
    CGFloat fullHeight = MAX(height * count, height * TABLE_MIN_VISIBLE_ROWS);
    CGSize preferredSize = CGSizeMake(self.tableController.preferredContentSize.width, fullHeight);
    self.popover.contentViewController.preferredContentSize = preferredSize;
    self.popover.popoverContentSize = preferredSize;
}

#pragma mark - Table
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CenteredLabelCheckmarkCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CenteredLabelCheckmarkCell class])];
    
    //set text
    cell.centeredLabel.text = self.items[indexPath.row];
    cell.centeredLabel.textAlignment = self.textAlignment;
    
    //color
    cell.tintColor = self.tintColor;
    
    //selection
    if (indexPath.row == self.selectedIndex)
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    //ios 8 margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
        cell.layoutMargins = UIEdgeInsetsZero;
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)])
        tableView.layoutMargins = UIEdgeInsetsZero;
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //deselect row
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //deselect if allowed
    if (self.allowDeselection.boolValue && self.selectedIndex == indexPath.row)
        self.selectedIndex = -1;
    else
        self.selectedIndex = indexPath.row;
    
    //reload other visible cells
    NSArray *visible = [tableView indexPathsForVisibleRows];
    [self.tableController.tableView reloadRowsAtIndexPaths:visible withRowAnimation:UITableViewRowAnimationAutomatic];
    
    //dismiss on select
    if (self.closeOnSelect.boolValue)
    {
        [self.popover dismissPopoverAnimated:YES];
        [self popoverControllerDidDismissPopover:self.popover];
    }
    
    //call delegate
    if ([self.delegate respondsToSelector:@selector(popoverSelectControlSelectionChanged:)])
    {
        [self.delegate popoverSelectControlSelectionChanged:self];
    }
}

#pragma mark - Item setting
- (void) setItems:(NSArray *)items
{
    _items = items;
    [self.tableController.tableView reloadData];
    
    //clear textfield
    self.textField.text = @"";
    
    //unselect everything
    self.selectedIndex = -1;
    
    //find the most 'fat' item and set the sizes
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    CGFloat fatWidth = 0;
    for (NSString *item in items)
    {
        cell.textLabel.text = item;
        [cell.textLabel sizeToFit];
        CGFloat width1 = cell.textLabel.frame.size.width;
        if (width1 > fatWidth) fatWidth = width1;
    }
    
    self.tableController.preferredContentSize = CGSizeMake(TABLE_PADDING * 2 + fatWidth, 0);
}

- (void) setSelectedIndex:(NSInteger)selectedIndex
{
    _selectedIndex = selectedIndex;
    self.textField.text = self.selectedIndex >= 0 ? self.items[self.selectedIndex] : @"";
}

- (NSInteger)selectedIndex
{
    return _selectedIndex;
}

- (void) setTextAlignment:(NSTextAlignment)textAlignment
{
    if (_textAlignment == textAlignment)
        return;
    
    _textAlignment = textAlignment;
    [self.tableController.tableView reloadData];
}

#pragma mark - Textfield posing
- (NSString *)text
{
    return self.textField.text;
}

- (void)setPlaceholder:(NSString *)ph
{
    self.textField.placeholder = ph;
}

- (NSString *)placeholder
{
    return self.textField.placeholder;
}

#pragma mark - Info
- (BOOL) isSomethingSelected
{
    return self.selectedIndex >= 0;
}

- (void) setCaption:(NSString *)caption
{
    //nav bar hidden if no caption
    self.tableController.navigationController.navigationBarHidden = !caption;
    self.tableController.title = caption;
}

- (NSString*)caption
{
    return self.tableController.title;
}
@end
