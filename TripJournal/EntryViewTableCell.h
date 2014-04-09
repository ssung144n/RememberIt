//
//  EntryViewTableCell.h
//  RememberIt
//
//  Created by Sora Sung on 4/3/14.
//  Copyright (c) 2014 Sora Sung. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TableCellDelegate
@optional
- (void)textFieldChangedCell:(id)sender;
- (void)textFieldEditingBeginCell:(id)sender;
- (void)textFieldEditingEndCell:(id)sender;
- (void)switchToggleCell:(id)sender;
@end

@interface EntryViewTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextField *listItem;
@property (weak, nonatomic) IBOutlet UISwitch *listItemSwitch;

- (IBAction)listItemSwitchChanged:(id)sender;
- (IBAction)doneListItemEdit:(id)sender;
- (IBAction)editingBegin:(id)sender;
- (IBAction)editingEnd:(id)sender;


@property (nonatomic, strong) id delegate;

@end
