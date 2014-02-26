//
//  ViewController.m
//  PeripheralModeTest
//
//  Created by Khaos Tian on 6/12/12.
//  Copyright (c) 2012 Oltica. All rights reserved.
//

#import "ViewController.h"
#import "ServiceFunUUID.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize Label;
@synthesize Log;
@synthesize WriteTextField;
@synthesize NOtifyTextField;

CBPeripheralManager * NOtifyperipheralManager;
//CGPoint center;// 表示二维坐标中的一个点。

- (void)viewDidLoad
{
    [super viewDidLoad];
    manager = [[CBPeripheralManager alloc]initWithDelegate:self queue:nil];
    centmanager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
    
    WriteTextField.delegate = self;
    NOtifyTextField.delegate = self;
    Log.editable = NO;
	// Do any additional setup after loading the view, typically from a nib.
}


-(IBAction)cleraTextView
{
    Log.text = @"";
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            [centmanager scanForPeripheralsWithServices:nil options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : [NSNumber numberWithBool:YES] }];
            break;
            
        default:
            NSLog(@"%i",central.state);
            break;
    }
}

- (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)aPeripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    if ([RSSI floatValue]>=-45.f) {
    NSLog(@"Greater than 45");
        [central stopScan];
        aCperipheral = aPeripheral;
        [central connectPeripheral:aCperipheral options:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"Failed:%@",error);
}

- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)aPeripheral
{
    NSLog(@"Connected:%@",aPeripheral.UUID);
    [aCperipheral setDelegate:self];
    [aCperipheral discoverServices:nil];
}

- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error {
    for (CBService *aService in aPeripheral.services){
        if ([aService.UUID isEqual:[CBUUID UUIDWithString:BLETRANSFER_TEST_SERVICE_UUID]]) {
            [aPeripheral discoverCharacteristics:nil forService:aService];
        }
    }
}

- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    for (CBCharacteristic *aChar in service.characteristics){
        NSLog(@"%@",aChar.UUID);
        
        if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLETRABSFER_TEST_CHARARCTERRISTIC_WRITE_UUID]]) {

            [aPeripheral readValueForCharacteristic:aChar];
        }
        
        
//        if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLETRABSFER_TEST_CHARARCTERRISTIC_READ_UUID]])
//        {
//            NSString *mainString = self.WriteTextField.text;
//            NSData *mainData1= [mainString dataUsingEncoding:NSUTF8StringEncoding];
//            [aPeripheral writeValue:mainData1 forCharacteristic:aChar type:CBCharacteristicWriteWithoutResponse];
//        }

    }
}

- (void)peripheral:(CBPeripheral *)aPeripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    [centmanager cancelPeripheralConnection:aPeripheral];
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral{
    NSLog(@"Done");
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOn:{
            CBUUID *cUDID = [CBUUID UUIDWithString:BLETRABSFER_TEST_CHARARCTERRISTIC_NOYIFY_UUID];
            CBUUID *cUDID1 = [CBUUID UUIDWithString:BLETRABSFER_TEST_CHARARCTERRISTIC_WRITE_UUID];
            //CBUUID *cUDID2 = [CBUUID UUIDWithString:BLETRABSFER_TEST_CHARARCTERRISTIC_READ_UUID];
            
            
            CBUUID *sUDID = [CBUUID UUIDWithString:BLETRANSFER_TEST_SERVICE_UUID];
            characteristic = [[CBMutableCharacteristic alloc]initWithType:cUDID properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsWriteable];
            characteristic1 = [[CBMutableCharacteristic alloc]initWithType:cUDID1 properties:CBCharacteristicPropertyWrite value:nil permissions:CBAttributePermissionsWriteable];
            //characteristic2 = [[CBMutableCharacteristic alloc]initWithType:cUDID2 properties:CBCharacteristicPropertyRead value:nil permissions:CBAttributePermissionsReadable];
            NSLog(@"%u",characteristic2.properties);
            servicea = [[CBMutableService alloc]initWithType:sUDID primary:YES];
            //servicea.characteristics = @[characteristic,characteristic1,characteristic2];
            servicea.characteristics = @[characteristic,characteristic1];
            [peripheral addService:servicea];
        }
            break;
            
        default:
            NSLog(@"%i",peripheral.state);
            break;
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error{
    NSLog(@"Added");
    NSDictionary *advertisingData = @{CBAdvertisementDataLocalNameKey : @"fenda_peripheral", CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:BLETRANSFER_TEST_SERVICE_UUID]]};
    [peripheral startAdvertising:advertisingData];
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
    NSLog(@"Hahah");
}
//Invoked when a remote central device subscribes to a characteristic’s value.
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic12
{
    NSLog(@"Core:%@",characteristic12.UUID);
    NSLog(@"Connected");
    NOtifyperipheralManager = peripheral;
    
//    NSString *str = @"F1F2F3F4F5F6F7F8F9";
//    NSData *FristData = [str dataUsingEncoding:NSUTF8StringEncoding];
//    
//    [NOtifyperipheralManager updateValue:FristData forCharacteristic:characteristic onSubscribedCentrals:nil];
    //[self writeData:peripheral];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self writeData:NOtifyperipheralManager sendDate:self.NOtifyTextField.text];
    return YES;
}



-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect frame = textField.frame;
    int offset = frame.origin.y + 52 - (self.view.frame.size.height - 216.0);//键盘高度216
    
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    //将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
    if(offset > 0)
        self.view.frame = CGRectMake(0.0f, -offset, self.view.frame.size.width, self.view.frame.size.height);
    
    [UIView commitAnimations];
}

//输入框编辑完成以后，将视图恢复到原始状态
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    self.view.frame =CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [UIView commitAnimations];
}

-(IBAction)send_4K_Date
{
#define STRESS_TEST_BYTE_COUNT 4000
    
    NSString *str;
    char data[STRESS_TEST_BYTE_COUNT];
    for (int x=0;x<STRESS_TEST_BYTE_COUNT;data[x++] = (char)('A' + (arc4random_uniform(26))));
    str = [[NSString alloc] initWithBytes:data length:STRESS_TEST_BYTE_COUNT encoding:NSUTF8StringEncoding];
    NSLog(@"%@",str);
    
    [self writeData:NOtifyperipheralManager sendDate:str];
    
    
}

- (void)writeData:(CBPeripheralManager *)peripheral sendDate:(NSString *)date
{
    
    NSString *str = date;
    // NSArray  *array = [[NSArray alloc]initWithObjects:NOtifyCentral, nil];
    mainData = [str dataUsingEncoding:NSUTF8StringEncoding];
    
    while ([self hasData])
    {
        if ([peripheral updateValue:[self getNextData] forCharacteristic:characteristic onSubscribedCentrals:nil])
        {
            [self ridData];
        }
        else
        {
            return;
        }
    }
    //[peripheral updateValue:mainData forCharacteristic:characteristic onSubscribedCentrals:array];

}
//Invoked when a local peripheral device is again ready to send characteristic value updates. (required)
- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
{
    
    while ([self hasData])
    {
        if([peripheral updateValue:[self getNextData] forCharacteristic:characteristic onSubscribedCentrals:nil])
        {
            [self ridData];
        }
        else
        {
            return;
        }
    }

}


- (BOOL)hasData{
    if ([mainData length]>0) {
        return YES;
    }else{
        return NO;
    }
}

- (void)ridData{
    if ([mainData length]>19) {
        mainData = [mainData subdataWithRange:NSRangeFromString(range)];
    }else{
        mainData = nil;
    }
}

- (NSData *)getNextData
{
    NSData *data;
    if ([mainData length]>19) {
        int datarest = [mainData length]-20;
        data = [mainData subdataWithRange:NSRangeFromString(@"{0,20}")];
        range = [NSString stringWithFormat:@"{20,%i}",datarest];
    }else{
        int datarest = [mainData length];
        range = [NSString stringWithFormat:@"{0,%i}",datarest];
        data = [mainData subdataWithRange:NSRangeFromString(range)];
    }
    NSLog(@"%@",data);
    return data;
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request
{
    NSString *mainString = self.WriteTextField.text;
    NSData *cmainData= [mainString dataUsingEncoding:NSUTF8StringEncoding];
    mainData = [mainString dataUsingEncoding:NSUTF8StringEncoding];
    //用requst.offset来把大的chunks分成小的chunks来进行发送。
    NSRange chunkRange = NSMakeRange(request.offset, [mainData length] -
                                     request.offset);
    NSLog(@"%lu",(unsigned long)request.offset);
    request.value = [cmainData  subdataWithRange:chunkRange];
    
    [peripheral respondToRequest:request withResult:CBATTErrorSuccess];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests{
    for (CBATTRequest *aReq in requests)
    {
        //NSLog(@"%@",[[NSString alloc]initWithData:aReq.value encoding:NSUTF8StringEncoding]);
        Log.text = [Log.text stringByAppendingString:[[NSString alloc]initWithData:aReq.value encoding:NSUTF8StringEncoding]];
        Log.text = [Log.text stringByAppendingString:@"\n"];
        [peripheral respondToRequest:aReq withResult:CBATTErrorSuccess];
        
        NOtifyperipheralManager = peripheral;
        
        NSString *str = @"F1F2F3F4F5F6F7F8F9";
        NSData *FristData = [str dataUsingEncoding:NSUTF8StringEncoding];
        //接受到数据后不回复数据
        [NOtifyperipheralManager updateValue:FristData forCharacteristic:characteristic onSubscribedCentrals:nil];
    }
}

- (void)willEnterBackgroud
{
    [manager stopAdvertising];
    [centmanager stopScan];
}

- (void)willBacktoForeground{
    NSDictionary *advertisingData = @{CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:BLETRANSFER_TEST_SERVICE_UUID]]};
    [manager startAdvertising:advertisingData];
    [centmanager scanForPeripheralsWithServices:nil options:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
