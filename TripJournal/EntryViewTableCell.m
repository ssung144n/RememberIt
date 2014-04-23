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
    [self.listItemDoneButton setBackgroundImage: [UIImage imageNamed:@"greencheckhollow1_56x56.png"] forState:(UIControlStateSelected)];
    [self.listItemDoneButton setBackgroundImage: [UIImage imageNamed:@"greencheckhollowempty1_56x56.png"] forState:(UIControlStateNormal)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (IBAction)editingBegin:(id)sender {
    [self.delegate textFieldEditingBeginCell:self];
}

- (IBAction)editingEnd:(id)sender {
    [self.delegate textFieldEditingEndCell:self];
}

- (IBAction)listItemDoneChanged:(id)sender {
    //NSLog(@"..EVTCell:listItemDoneChanged- checkbox:%d", self.listItemDoneButton.selected);

    self.listItemDoneButton.selected=!self.listItemDoneButton.selected;
    [self.delegate buttonListItemCell:self];
}

@end
