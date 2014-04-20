//
//  EntryViewTableCell.m
//  RememberIt
//
//  Created by Sora Sung on 4/3/14.
//  Copyright (c) 2014 Sora Sung. All rights reserved.
//

#import "EntryViewTableCell.h"

@implementation EntryViewTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)listItemSwitchChanged:(id)sender {
    [self.delegate switchToggleCell:self];
}

- (IBAction)doneListItemEdit:(id)sender {
    [sender resignFirstResponder];
    
    [self.delegate textFieldChangedCell:self];
}

- (IBAction)editingBegin:(id)sender {
    [self.delegate textFieldEditingBeginCell:self];
}

- (IBAction)editingEnd:(id)sender {
    [self.delegate textFieldEditingEndCell:self];
}

@end
