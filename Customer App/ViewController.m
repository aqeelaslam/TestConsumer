//
//  ViewController.m
//  Customer App
//
//  Created by Synergistics AE on 11/27/15.
//  Copyright © 2015 Synergistics AE. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    
    self.statusLabel.text = @"Inactive";
}



- (void)viewWillDisappear:(BOOL)animated
{
    [self.peripheralManager stopAdvertising];
    
    [super viewWillDisappear:animated];
}







#pragma mark - Peripheral Methods


- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    if (peripheral.state != CBPeripheralManagerStatePoweredOn)
    {
        return;
    }
    
    // We're in CBPeripheralManagerStatePoweredOn state...
    NSLog(@"self.peripheralManager powered on.");
    
    // ... so build our service.
    
    // Start with the CBMutableCharacteristic
    self.transferCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]
                                                                     properties:CBCharacteristicPropertyNotify
                                                                          value:nil
                                                                    permissions:CBAttributePermissionsReadable];
    
    // Then the service
    CBMutableService *transferService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]
                                                                       primary:YES];
    
    // Add the characteristic to the service
    transferService.characteristics = @[self.transferCharacteristic];
    
    // And add it to the peripheral manager
    [self.peripheralManager addService:transferService];
}













/** Catch when someone subscribes to our characteristic, then start sending them data
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"Central subscribed to characteristic");
    
    // Get the data
    
    self.dataToSend = [order dataUsingEncoding:NSUTF8StringEncoding];
    
    // Reset the index
    self.sendDataIndex = 0;
    
    // Start sending
    [self sendData];
}







/** Recognise when the central unsubscribes
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"Central unsubscribed from characteristic");
}










/** Sends the next amount of data to the connected central
 */
- (void)sendData
{
    // First up, check if we're meant to be sending an EOM
    static BOOL sendingEOM = NO;
    
    if (sendingEOM) {
        
        // send it
        BOOL didSend = [self.peripheralManager updateValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
        
        // Did it send?
        if (didSend) {
            
            // It did, so mark it as sent
            sendingEOM = NO;
            
            NSLog(@"Sent: EOM");
            
            self.statusLabel.text = @"Paid";
            
            [self.peripheralManager stopAdvertising];
        }
        
        // It didn't send, so we'll exit and wait for peripheralManagerIsReadyToUpdateSubscribers to call sendData again
        return;
    }
    
    // We're not sending an EOM, so we're sending data
    
    // Is there any left to send?
    
    if (self.sendDataIndex >= self.dataToSend.length) {
        
        // No data left.  Do nothing
        return;
    }
    
    // There's data left, so send until the callback fails, or we're done.
    
    BOOL didSend = YES;
    
    while (didSend) {
        
        // Make the next chunk
        
        // Work out how big it should be
        NSInteger amountToSend = self.dataToSend.length - self.sendDataIndex;
        
        // Can't be longer than 20 bytes
        if (amountToSend > NOTIFY_MTU) amountToSend = NOTIFY_MTU;
        
        // Copy out the data we want
        NSData *chunk = [NSData dataWithBytes:self.dataToSend.bytes+self.sendDataIndex length:amountToSend];
        
        // Send it
        didSend = [self.peripheralManager updateValue:chunk forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
        
        // If it didn't work, drop out and wait for the callback
        if (!didSend) {
            return;
        }
        
        NSString *stringFromData = [[NSString alloc] initWithData:chunk encoding:NSUTF8StringEncoding];
        NSLog(@"Sent: %@", stringFromData);
        
        // It did send, so update our index
        self.sendDataIndex += amountToSend;
        
        // Was it the last one?
        if (self.sendDataIndex >= self.dataToSend.length) {
            
            // It was - send an EOM
            
            // Set this so if the send fails, we'll send it next time
            sendingEOM = YES;
            
            // Send it
            BOOL eomSent = [self.peripheralManager updateValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
            
            if (eomSent) {
                // It sent, we're all done
                sendingEOM = NO;
                
                NSLog(@"Sent: EOM");
            }
            
            return;
        }
    }
}





- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
{
    [self sendData];
}











- (IBAction)coffeePressed:(UIButton *)sender
{
    [self.peripheralManager stopAdvertising];
    order = @"Coffee";
    
    self.statusLabel.text = @"Coffee";
    
//    _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];

    [self.peripheralManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]] }];
}


- (IBAction)sandwitchPressed:(UIButton *)sender
{
    [self.peripheralManager stopAdvertising];

    order = @"Sanwitch";
    
    self.statusLabel.text = @"Sanwitch";

//    _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];

    [self.peripheralManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]] }];
}


- (IBAction)juicePressed:(UIButton *)sender
{
    [self.peripheralManager stopAdvertising];

    order = @"Juice";
    
    self.statusLabel.text = @"Juice";

//    _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];

    [self.peripheralManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]] }];
}


- (IBAction)drinkPressed:(UIButton *)sender
{
    [self.peripheralManager stopAdvertising];

    order = @"Drink";
    
    self.statusLabel.text = @"Drink";

//    _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];

    [self.peripheralManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]] }];
}



@end
