//
//  TestPhidgetSingleDCMotorController.m
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-06-09.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import "TestPhidgetSingleDCMotorController.h"

@implementation TestPhidgetSingleDCMotorController

static id motor = NULL;

+(void) velocityTesting
{
    float actualVelocity = 0;
    float expectedVelocity = 100.0f;
    
    phidgetSingleDCMotorSetVelocity((phidgetSingleDCMotorController_t*)motor, expectedVelocity);
    [NSThread sleepForTimeInterval: 5];
    actualVelocity = phidgetSingleDCMotorGetVelocity((phidgetSingleDCMotorController_t*)motor);
    NSAssert(actualVelocity - expectedVelocity <= 0.5f, @"Wrong vel\n");
    
    expectedVelocity = 50.0f;
    phidgetSingleDCMotorSetVelocity((phidgetSingleDCMotorController_t*)motor, expectedVelocity);
    [NSThread sleepForTimeInterval: 5];
    actualVelocity = phidgetSingleDCMotorGetVelocity((phidgetSingleDCMotorController_t*)motor);
    NSAssert(actualVelocity - expectedVelocity <= 0.5f, @"Wrong vel");
    
    expectedVelocity = 0.0f;
    phidgetSingleDCMotorSetVelocity((phidgetSingleDCMotorController_t*)motor, expectedVelocity);
    [NSThread sleepForTimeInterval: 5];
    actualVelocity = phidgetSingleDCMotorGetVelocity((phidgetSingleDCMotorController_t*)motor);
    NSAssert(actualVelocity - expectedVelocity <= 0.5f, @"Wrong vel\n");
}

+ (void)accelerationTesting
{
    float testAcceleration = 10.0f;
    float actualAcceleration = 0.0f;
    float expectedAcceleration = 24.51f;
    
    // Test out acceleration that is BELOW the hardwares acceptable value
    // and verify the class properly handles it.
    phidgetSingleDCMotorSetAcceleration((phidgetSingleDCMotorController_t*)motor, testAcceleration);
    actualAcceleration = phidgetSingleDCMotorGetAcceleration((phidgetSingleDCMotorController_t*)motor);
    NSAssert(actualAcceleration - expectedAcceleration <= 0.5f, @"Wrong min value\n");
    
    // Test out acceleration that is ABOVE the hardwares acceptable range.
    testAcceleration = 100000.0f;
    expectedAcceleration = 6250.0f;
    phidgetSingleDCMotorSetAcceleration((phidgetSingleDCMotorController_t*)motor, testAcceleration);
    actualAcceleration = phidgetSingleDCMotorGetAcceleration((phidgetSingleDCMotorController_t*)motor);
    NSAssert(actualAcceleration - expectedAcceleration <= 0.5f, @"Wrong max value\n");
    
    // Test out our acceleration that is WITHIN the hardware acceptable range.
    testAcceleration = 100.0f;
    expectedAcceleration = 100.0f;
    phidgetSingleDCMotorSetAcceleration((phidgetSingleDCMotorController_t*)motor, testAcceleration);
    actualAcceleration = phidgetSingleDCMotorGetAcceleration((phidgetSingleDCMotorController_t*)motor);
    NSAssert(actualAcceleration - expectedAcceleration <= 0.0f, @"Wrong within value\n");
}

+ (void)currentTesting
{
    // Verify no current has been received while the motor is not running.
    float current = phidgetSingleDCMotorGetCurrent((phidgetSingleDCMotorController_t*)motor);
    if (current != 0) {
        NSAssert(NO, @"Wrong current - must be zero!\n");
    }
    
    // Turn on the motor
    phidgetSingleDCMotorSetVelocity((phidgetSingleDCMotorController_t*)motor, 25.0f);
    
    [NSThread sleepForTimeInterval: 10]; // Give time for the motor to work
    
    // Verify the current is different now that the motor is running.
    current = phidgetSingleDCMotorGetCurrent((phidgetSingleDCMotorController_t*)motor);
    if (current == 0) {
        NSAssert(NO, @"Wrong current - must not be zero!\n");
    }
    // Turn ff the motor
    phidgetSingleDCMotorSetVelocity((phidgetSingleDCMotorController_t*)motor, 0.0f);
}

+ (void) testSupplyVoltage
{
    float supplyVoltage = phidgetSingleDCMotorGetSupplyVoltage((phidgetSingleDCMotorController_t*)motor);
    if (supplyVoltage == 0) {
        NSAssert(NO, @"Wrong supply voltage - cannot be zero!\n");
    }
}


+ (void)setUp
{    
    // Set-up code here.
    motor = (id)phidgetSingleDCMotorInit();
    NSAssert(motor, @"Failed alloc + init\n");
    
    // Set default acceleration.
    phidgetSingleDCMotorSetAcceleration((phidgetSingleDCMotorController_t*)motor, 100.0f);
}

+ (void)tearDown
{
    // Tear-down code here.
    phidgetSingleDCMotorDealloc((phidgetSingleDCMotorController_t*)motor);
    motor = NULL;
}

+(void) performUnitTests {
    [self setUp];
    // Test hardware interface
    [self velocityTesting];
    [self accelerationTesting];
    [self currentTesting];
    [self tearDown];
}

@end
