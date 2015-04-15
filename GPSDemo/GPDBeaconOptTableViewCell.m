//
//  GPDBeaconOptTableViewCell.m
//  GPShopper-iOS
//
//  Created by Donna on 4/13/15.
//  Copyright (c) 2015 James Lee. All rights reserved.
//

#import "GPDBeaconOptTableViewCell.h"
#import "GPDBeaconOptViewController.h"

@implementation GPDBeaconOptTableViewCell

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    [[NSNotificationCenter defaultCenter] addObserverForName:GPDBeaconDidOptInNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification* notification){
                                                      self.detailTextLabel.text = @"On";
                                                  }];
    [[NSNotificationCenter defaultCenter] addObserverForName:GPDBeaconDidOptOutNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification* notification){
                                                      self.detailTextLabel.text = @"Off";
                                                  }];
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
