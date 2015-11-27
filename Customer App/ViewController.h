//
//  ViewController.h
//  Customer App
//
//  Created by Synergistics AE on 11/27/15.
//  Copyright © 2015 Synergistics AE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "TransferService.h"



@interface ViewController : UIViewController <CBPeripheralManagerDelegate, CBPeripheralDelegate>
{
    NSString * order;
}
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;




- (IBAction)coffeePressed:(UIButton *)sender;

- (IBAction)sandwitchPressed:(UIButton *)sender;

- (IBAction)juicePressed:(UIButton *)sender;

- (IBAction)drinkPressed:(UIButton *)sender;




@property (strong, nonatomic) CBPeripheralManager       *peripheralManager;
@property (strong, nonatomic) CBMutableCharacteristic   *transferCharacteristic;
@property (strong, nonatomic) NSData                    *dataToSend;
@property (nonatomic, readwrite) NSInteger              sendDataIndex;
@property (strong, nonatomic) CBCentralManager      *centralManager;
@property (strong, nonatomic) CBPeripheral          *discoveredPeripheral;
@property (strong, nonatomic) NSMutableData         *data;



@end

