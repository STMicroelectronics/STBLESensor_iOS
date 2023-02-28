/*******************************************************************************
 * COPYRIGHT(c) 2015 STMicroelectronics
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *   1. Redistributions of source code must retain the above copyright notice,
 *      this list of conditions and the following disclaimer.
 *   2. Redistributions in binary form must reproduce the above copyright notice,
 *      this list of conditions and the following disclaimer in the documentation
 *      and/or other materials provided with the distribution.
 *   3. Neither the name of STMicroelectronics nor the names of its contributors
 *      may be used to endorse or promote products derived from this software
 *      without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 ******************************************************************************/

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CBAdvertisementData.h>
#import "BlueSTSDK/BlueSTSDK-Swift.h"
#import "BlueSTSDKBleAdvertiseParser.h"
#import "NSData+NumberConversion.h"
#import "BlueSTSDK_LocalizeUtil.h"


#define PROTOCOL_VERSION_CURRENT 0x01
#define PROTOCOL_VERSION_CURRENT_MIN 0x01
#define PROTOCOL_VERSION_NOT_AVAILABLE 0xFF

#define NODE_ID_GENERIC 0x00
#define NODE_ID_STEVAL_WESU1 0x01
#define NODE_ID_SENSOR_TILE 0x02
#define NODE_ID_BLUE_COIN 0x03
#define NODE_ID_STEVAL_IDB008VX 0x04
#define NODE_ID_STEVAL_BCN002V1 0x05
#define NODE_ID_SENSOR_TILE_101 0x06
#define NODE_ID_DISCOVERY_IOT01A 0x07
#define NODE_ID_STEVAL_STWINKIT1 0x08
#define NODE_ID_STEVAL_STWINKIT1B 0x09
#define NODE_ID_B_L475E_IOT01A 0x0A
#define NODE_ID_B_U585I_IOT02A 0x0B
#define NODE_ID_POLARIS 0x0C
#define NODE_ID_SENSOR_TILE_BOX_PRO 0x0D
#define NODE_ID_STWIN_BOX 0x0E
#define NODE_ID_PROTEUS 0x0F
#define NODE_ID_STSYS_SBU06 0x10
#define NODE_ID_NUCLEO_F401RE 0x7F
#define NODE_ID_NUCLEO_L476RG 0x7E
#define NODE_ID_NUCLEO_L053R8 0x7D
#define NODE_ID_NUCLEO_F446RE 0x7C

#define NODE_ID_NUCLEO_BIT 0x80

#define NODE_ID_WB_INIT 0x81
#define NODE_ID_WB_INIT 0x8A

#define NODE_ID_WBA_INIT 0x8B
#define NODE_ID_WBA_INIT 0x8C

#define NODE_ID_IS_SLEEPING_BIT 0x40
#define NODE_ID_HAS_EXTENSION_BIT 0x20

#define ADVERTISE_SIZE_COMPACT 6
#define ADVERTISE_SIZE_FULL 12
#define ADVERTISE_MAX_SIZE 20

#define ADVERTISE_FIELD_POS_PROTOCOL 0
#define ADVERTISE_FIELD_POS_NODE_ID 1
#define ADVERTISE_FIELD_POS_FEATURE_MAP 2
#define ADVERTISE_FIELD_POS_ADDRESS 6

#define ADVERTISE_FIELD_SIZE_ADDRESS 6

static uint8_t extractNodeType(uint8_t type){
    if(type & NODE_ID_NUCLEO_BIT)
        return type;
    else
        return type &(0x1F);
}

static BOOL extractIsSleepingBit(uint8_t type){
    if(type & NODE_ID_NUCLEO_BIT)
        return false;
    else
        return (type & NODE_ID_IS_SLEEPING_BIT)!=0;
}

static BOOL extractHasExtensionBit(uint8_t type){
    if(type & NODE_ID_NUCLEO_BIT)
        return false;
    else
        return (type & NODE_ID_HAS_EXTENSION_BIT)!=0;
}

@implementation BlueSTSDKBleAdvertiseParser

/**
 *  convert an uint8_t into a BlueSTSDKNodeType value
 *
 *  @param type board type number
 *
 *  @return equivalent type in the BlueSTSDKNodeType or an exception is the input is
 *  a valid type
 */
-(BlueSTSDKNodeType) getNodeType:(uint8_t) type {
    BlueSTSDKNodeType nodetype = BlueSTSDKNodeTypeGeneric;
    if (type == NODE_ID_STEVAL_WESU1)
        nodetype =  BlueSTSDKNodeTypeSTEVAL_WESU1;
    else if(type == NODE_ID_SENSOR_TILE)
        nodetype = BlueSTSDKNodeTypeSensor_Tile;
    else if(type == NODE_ID_BLUE_COIN)
        nodetype = BlueSTSDKNodeTypeBlue_Coin;
    else if(type == NODE_ID_STEVAL_IDB008VX)
        nodetype = BlueSTSDKNodeTypeSTEVAL_IDB008VX;
    else if(type == NODE_ID_STEVAL_BCN002V1)
        nodetype = BlueSTSDKNodeTypeSTEVAL_BCN002V1;
    else if(type == NODE_ID_SENSOR_TILE_101)
        nodetype = BlueSTSDKNodeTypeSensor_Tile_Box;
    else if(type == NODE_ID_DISCOVERY_IOT01A)
        nodetype = BlueSTSDKNodeTypeDiscovery_IOT01A;
    else if(type == NODE_ID_STEVAL_STWINKIT1)
        nodetype = BlueSTSDKNodeTypeSTEVAL_STWINKIT1;
    else if(type == NODE_ID_STEVAL_STWINKIT1B)
        nodetype = BlueSTSDKNodeTypeSTEVAL_STWINKT1B;
    else if(type == NODE_ID_B_L475E_IOT01A)
        nodetype = BlueSTSDKNodeTypeB_L475E_IOT01A;
    else if(type == NODE_ID_B_U585I_IOT02A)
        nodetype = BlueSTSDKNodeTypeB_U585I_IOT02A;
    else if(type == NODE_ID_POLARIS)
        nodetype = BlueSTSDKNodeTypePOLARIS;
    else if(type == NODE_ID_SENSOR_TILE_BOX_PRO)
        nodetype = BlueSTSDKNodeTypeSENSOR_TILE_BOX_PRO;
    else if(type == NODE_ID_STWIN_BOX)
        nodetype = BlueSTSDKNodeTypeSTWIN_BOX;
    else if(type == NODE_ID_PROTEUS)
        nodetype = BlueSTSDKNodeTypePROTEUS;
    else if(type == NODE_ID_STSYS_SBU06)
        nodetype = BlueSTSDKNodeTypeSTSYS_SBU06;
    else if(type == NODE_ID_NUCLEO_F401RE)
        nodetype = BlueSTSDKNodeTypeNUCLEO_F401RE;
    else if(type == NODE_ID_NUCLEO_L053R8)
        nodetype = BlueSTSDKNodeTypeNUCLEO_L053R8;
    else if(type == NODE_ID_NUCLEO_L476RG)
        nodetype = BlueSTSDKNodeTypeNUCLEO_L476RG;
    else if(type == NODE_ID_NUCLEO_F446RE)
        nodetype = BlueSTSDKNodeTypeNUCLEO_F446RE;
    else if(NODE_ID_WB_INIT <= type <= NODE_ID_WB_INIT)
            nodetype = BlueSTSDKNodeTypeWB_BOARD;
    else if(NODE_ID_WBA_INIT <= type <= NODE_ID_WBA_INIT)
            nodetype = BlueSTSDKNodeTypeWBA_BOARD;
    return nodetype;
}

+(instancetype)advertiseParserWithAdvertise:(NSDictionary *)advertisementData {
    return [[BlueSTSDKBleAdvertiseParser alloc] initWithAdvertise:advertisementData];
}


-(instancetype)initWithAdvertise:(NSDictionary *)advertisementData{
    _name = advertisementData[CBAdvertisementDataLocalNameKey];
    _txPower = advertisementData[CBAdvertisementDataTxPowerLevelKey];
    NSData *rawData = advertisementData[CBAdvertisementDataManufacturerDataKey];
    const NSInteger len = [rawData length];
    
    if(len != ADVERTISE_SIZE_COMPACT && len != ADVERTISE_SIZE_FULL)
        @throw [NSException
                exceptionWithName:BLUESTSDK_LOCALIZE(@"Invalid Manufactured data",nil)
                reason:[NSString stringWithFormat:
                        BLUESTSDK_LOCALIZE(@"Manufactured data must be %d bytes or %d byte",nil),
                            ADVERTISE_SIZE_COMPACT, ADVERTISE_SIZE_FULL]
                userInfo:nil];

    //set the default value
    _featureMap = 0x00;
    _protocolVersion = PROTOCOL_VERSION_NOT_AVAILABLE;
    _address = nil;
    _nodeId = NODE_ID_GENERIC;
    _nodeType = [self getNodeType: _nodeId];
    
    //start to fill the value with the extracted values
    
    _protocolVersion = [rawData extractUInt8FromOffset:ADVERTISE_FIELD_POS_PROTOCOL];
    
    if(!(_protocolVersion >= PROTOCOL_VERSION_CURRENT_MIN && _protocolVersion <= PROTOCOL_VERSION_CURRENT))
        @throw [NSException
                exceptionWithName:BLUESTSDK_LOCALIZE(@"Invalid Protocol version",nil)
                reason:[NSString stringWithFormat:
                        BLUESTSDK_LOCALIZE(@"Supported protocol version are from %d to %d",nil),
                        PROTOCOL_VERSION_CURRENT_MIN, PROTOCOL_VERSION_CURRENT]
                userInfo:nil];
    
    uint8_t typeId =[rawData extractUInt8FromOffset:ADVERTISE_FIELD_POS_NODE_ID];
    _nodeId = extractNodeType(typeId);
    _isSleeping = extractIsSleepingBit(typeId);
    _hasExtension = extractHasExtensionBit(typeId);
    
    _nodeType = [self getNodeType: _nodeId];
    _featureMap = [rawData extractBeUInt32FromOffset:ADVERTISE_FIELD_POS_FEATURE_MAP];
    
    
    if (len == ADVERTISE_SIZE_FULL) {
        _address = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                    [rawData extractUInt8FromOffset:ADVERTISE_FIELD_SIZE_ADDRESS+0],
                    [rawData extractUInt8FromOffset:ADVERTISE_FIELD_SIZE_ADDRESS+1],
                    [rawData extractUInt8FromOffset:ADVERTISE_FIELD_SIZE_ADDRESS+2],
                    [rawData extractUInt8FromOffset:ADVERTISE_FIELD_SIZE_ADDRESS+3],
                    [rawData extractUInt8FromOffset:ADVERTISE_FIELD_SIZE_ADDRESS+4],
                    [rawData extractUInt8FromOffset:ADVERTISE_FIELD_SIZE_ADDRESS+5]
                    ];
    }//if len check
    
    return self;
}

@end
