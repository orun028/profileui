//
//  FIRAuthDataResult.h
//  profileui
//
//  Created by Admin on 09/04/2023.
//

#import "FIRAuthDataResult.h"
@class FIROAuthCredential;
@interface FIRAuthDataResult (Unreleased)
@property(nonatomic, readonly, nullable) FIROAuthCredential *credential;
@end
