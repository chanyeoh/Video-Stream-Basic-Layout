//
//  SimpleTableCell.m
//  stream
//
//  Created by Avik Bag on 8/22/14.
//  Copyright (c) 2014 drexel. All rights reserved.
//

#import "SimpleTableCell.h"

@implementation SimpleTableCell

@synthesize videoLabel = _videoLabel;
@synthesize valueLabel = _valueLabel;

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

@end
