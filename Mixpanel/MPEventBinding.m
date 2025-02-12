//
//  MPEventBinding.m
//  HelloMixpanel
//
//  Created by Amanda Canyon on 7/22/14.
//  Copyright (c) 2014 Mixpanel. All rights reserved.
//

#import "Mixpanel.h"
#import "MPEventBinding.h"
#import "MPUIControlBinding.h"
#import "MPUITableViewBinding.h"

@implementation MPEventBinding

+ (MPEventBinding *)bindingWithJSONObject:(NSDictionary *)object
{
    if (object == nil) {
        NSLog(@"must supply an JSON object to initialize from");
        return nil;
    }

    NSString *bindingType = object[@"event_type"];
    Class klass = [self subclassFromString:bindingType];
    return [klass bindingWithJSONObject:object];
}

+ (MPEventBinding *)bindngWithJSONObject:(NSDictionary *)object
{
    return [self bindingWithJSONObject:object];
}

+ (Class)subclassFromString:(NSString *)bindingType
{
    NSDictionary *classTypeMap = @{
                                   [MPUIControlBinding typeName]: [MPUIControlBinding class],
                                   [MPUITableViewBinding typeName]: [MPUITableViewBinding class]
                                   };
    return[classTypeMap valueForKey:bindingType] ?: [MPUIControlBinding class];
}

+ (void)track:(NSString *)event properties:(NSDictionary *)properties
{
    NSMutableDictionary *bindingProperties = [NSMutableDictionary dictionaryWithObjectsAndKeys: @YES, @"$from_binding", nil];
    [bindingProperties addEntriesFromDictionary:properties];
    [[Mixpanel sharedInstance] track:event properties:bindingProperties];
}

- (instancetype)initWithEventName:(NSString *)eventName onPath:(NSString *)path
{
    if (self = [super init]) {
        self.eventName = eventName;
        self.path = [[MPObjectSelector alloc] initWithString:path];
        self.name = [[NSUUID UUID] UUIDString];
        self.running = NO;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Event Binding base class: '%@' for '%@'", [self eventName], [self path]];
}

#pragma mark -- Method stubs

+ (NSString *)typeName
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)execute
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)stop
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

#pragma mark -- NSCoder

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    NSString *path = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"path"];
    NSString *eventName = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"eventName"];
    if (self = [self initWithEventName:eventName onPath:path]) {
        self.ID = [[aDecoder decodeObjectOfClass:[NSNumber class] forKey:@"ID"] unsignedLongValue];
        self.name = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"name"];
        self.swizzleClass = NSClassFromString([aDecoder decodeObjectOfClass:[NSString class] forKey:@"swizzleClass"]);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:@(_ID) forKey:@"ID"];
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_path.string forKey:@"path"];
    [aCoder encodeObject:_eventName forKey:@"eventName"];
    [aCoder encodeObject:NSStringFromClass(_swizzleClass) forKey:@"swizzleClass"];
}

- (BOOL)isEqual:(id)other {
    if (other == self) {
        return YES;
    } else if (![other isKindOfClass:[MPEventBinding class]]) {
        return NO;
    } else {
        return [self.eventName isEqual:((MPEventBinding *)other).eventName] && [self.path isEqual:((MPEventBinding *)other).path];
    }
}

- (NSUInteger)hash {
    return [self.eventName hash] ^ [self.path hash];
}

@end
