//
//  ViewController.h
//  PeripheralModeTest
//
//  Created by Khaos Tian on 6/12/12.
//  Copyright (c) 2012 Oltica. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreBluetooth/CBPeripheral.h>

@interface ViewController : UIViewController<CBPeripheralManagerDelegate,CBCentralManagerDelegate,CBPeripheralDelegate,UITextFieldDelegate>{
    CBPeripheralManager *manager;
    CBCentralManager *centmanager;
    CBMutableCharacteristic *characteristic;
    CBMutableCharacteristic *characteristic1;
    CBMutableCharacteristic *characteristic2;
    CBMutableService *servicea;
    NSData *mainData;
    NSString *range;
    
    CBPeripheral *aCperipheral;
}
@property (weak, nonatomic) IBOutlet UILabel *Label;
@property (weak, nonatomic) IBOutlet UITextView *Log;
@property (strong, nonatomic) IBOutlet UITextField *WriteTextField;

@property (strong, nonatomic) IBOutlet UITextField *NOtifyTextField;

@property (strong, nonatomic) IBOutlet UIButton *clearButton;
@property (strong, nonatomic) IBOutlet UIButton *send_4K_DateButton;



- (void)willEnterBackgroud;
- (void)willBacktoForeground;

@end
