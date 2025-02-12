//
//  MPVariant.h
//  HelloMixpanel
//
//  Created by Alex Hofsteede on 28/4/14.
//  Copyright (c) 2014 Mixpanel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MPVariant : NSObject <NSSecureCoding>

@property (nonatomic) NSUInteger ID;
@property (nonatomic) NSUInteger experimentID;

/*!
 Whether this specific variant is currently running on the device.

 This property will not be restored on unarchive, as the variant will need
 to be run again once the app is restarted.
 */
@property (nonatomic, readonly) BOOL running;

/*!
 Whether the variant should not run anymore.

 Variants are marked as finished when we no longer see them in a decide response.
 They will continue running (ie their changes will be visible) until the next
 time the app starts.
*/
@property (nonatomic, readonly) BOOL finished;

+ (MPVariant *)variantWithJSONObject:(NSDictionary *)object;

- (void)addActionsFromJSONObject:(NSArray *)actions andExecute:(BOOL)exec;
- (void)addActionFromJSONObject:(NSDictionary *)object andExecute:(BOOL)exec;
- (void)addTweaksFromJSONObject:(NSArray *)tweaks andExecute:(BOOL)exec;
- (void)addTweakFromJSONObject:(NSDictionary *)object andExecute:(BOOL)exec;
- (void)removeActionWithName:(NSString *)name;

/*!
 Executes the variant, including all of its actions and tweaks.

 This immediately applies the changes associated with this variant.
 */
- (void)execute;

/*!
 Stops the variant, including all of its actions and tweaks.

 This immediately applies the reverse of this variant. including
 reversing all actions and tweaks to their original values.
 */
- (void)stop;

/*!
 Sets the finished flag on this variant, does not take any actions.

 The finished flag marks this variant as one that should not be run
 anymore the next time the app opens, but we leave it running so that
 the UI doesn't change during the user session.
 */
- (void)finish;

/*!
 Unsets the finished flag on this variant, does not take any actions.

 If the finished flag is unset, the variant will continue to run the
 next time the app starts.
 */
- (void)restart;

@end

@interface MPVariantAction : NSObject <NSSecureCoding>

@end

@interface MPVariantTweak : NSObject <NSSecureCoding>

@end
