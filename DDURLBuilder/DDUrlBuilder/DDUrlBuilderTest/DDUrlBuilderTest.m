#import "DDUrlBuilderTest.h"
#import "DDURLBuilder.h"

@implementation DDUrlBuilderTest

-(void)testAuthorExample
{
    
    NSURL* expected_ = [ NSURL URLWithString: @"http://www.google.com/search?client=safari&rls=en&q=what+is+the+answer+to+the+ultimate+question+of+life+the+universe+and+everything&ie=UTF-8&oe=UTF-8" ];
    
    DDURLBuilder *builder = [DDURLBuilder URLBuilderWithURL:nil];
    [builder setHost:@"google.com"];
    [builder setScheme:@"http"];
    [builder setPath:@"search"];
    [builder addQueryValue:@"safari" forKey:@"client"];
    [builder addQueryValue:@"en" forKey:@"rls"];
    [builder addQueryValue:@"what is the answer to the ultimate question of life the universe and everything" forKey:@"q"];
    [builder addQueryValue:@"UTF-8" forKey:@"ie"];
    [builder addQueryValue:@"UTF-8" forKey:@"oe"];

    NSURL* received_ = [ builder URL ];
    
    STAssertTrue( [ expected_ isEqual: received_ ], @"result URL mismatch" );
}

@end
