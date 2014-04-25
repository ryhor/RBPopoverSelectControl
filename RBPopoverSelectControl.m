//
//  RBPopoverSelectControl.m
//
//  Created by Ryhor Burakou on 07/04/2014.
//

#import "RBPopoverSelectControl.h"

@interface RBPopoverSelectControl () <UITextFieldDelegate, UIPopoverControllerDelegate, UITableViewDelegate, UITableViewDataSource>

//ui
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UITableViewController *tableController;

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

- (void) awakeFromNib
{
    [super awakeFromNib];
    [self initialize];
}

- (void) initialize
{
    //text field
    self.textField = [[UITextField alloc]initWithFrame:self.bounds];
    self.textField.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.textField.translatesAutoresizingMaskIntoConstraints = YES;
    self.textField.borderStyle = UITextBorderStyleRoundedRect;
    self.textField.inputView = [UIView new];
    self.textField.delegate = self;
    [self addSubview:self.textField];
    
    //table
    self.tableController = [[UITableViewController alloc]initWithStyle:UITableViewStylePlain];
    self.tableController.tableView.allowsMultipleSelection = NO;
    if ([self.tableController.tableView respondsToSelector:@selector(setSeparatorInset:)]) self.tableController.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableController.tableView.delegate = self;
    self.tableController.tableView.dataSource = self;
    
    //popover
    self.popover = [[UIPopoverController alloc]initWithContentViewController:self.tableController];
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
    [self.textField resignFirstResponder];
}

- (void) presentFromBarButtonItem:(UIBarButtonItem*)control
{
    [self.popover presentPopoverFromBarButtonItem:control permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void) presentFromControl:(UIView*)control
{
    [self.popover presentPopoverFromRect:control.frame inView:control.superview permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
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
    NSString *cellId = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    //set text
    cell.textLabel.text = self.items[indexPath.row];
    
    //selection
    if (indexPath.row == self.selectedIndex)
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    
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
    return self.selectedIndex > 0;
}
@end
