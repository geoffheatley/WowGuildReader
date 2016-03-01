#import "WoWApiClient.h"
#import "AFJSONRequestOperation.h"
#import "Character.h"
#import "Guild.h"


#define kAPIKey = @"4dabm2d4336x9k3h6hppsyxhm3ghcxsd";


@implementation WoWApiClient




static dispatch_once_t oncePredicate;

+ (WoWApiClient *)sharedClient
{
    static WoWApiClient *_sharedClient;
    // per Apple doing this once via GCD protects against race conditions
    dispatch_once(&oncePredicate, ^{
        // initialize self with the baseURL for us region
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:@"https://eu.api.battle.net"]];        //[NSURL URLWithString:@"http://us.battle.net"]];   //https://us.api.battle.net/wow/realm/status?apikey=<key>
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
	[self setDefaultHeader:@"Accept" value:@"application/json"];

	return self;
}

-(void)guildWithName:(NSString *)guildName onRealm:(NSString *)realmName success:(GuildBlock)successBlock error:(ErrorBlock)errorBlock {
    
    NSString *url = [NSString stringWithFormat:@"/wow/guild/%@/%@",realmName,guildName];
    
    [self getPath:[url stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding] parameters:@{ @"apikey" : @"4dabm2d4336x9k3h6hppsyxhm3ghcxsd", @"fields" : @"members" } success:^(AFHTTPRequestOperation *operation, id responseObject) {
         
         Guild *guild = [[Guild alloc] initWithGuildData:responseObject];
         successBlock(guild);
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
         NSLog(@"guildWithName: - Error getting character detail: %@",[error localizedDescription]);
         errorBlock(error);
         
     }];
}

// http://us.battle.net
// /api/wow/character/borean-tundra/
// Hagrel
// fields=guild,items,professions,reputation,stats
-(void)characterWithName:(NSString *)characterName onRealm:(NSString *)realmName success:(CharacterBlock)successBlock error:(ErrorBlock)errorBlock {
    
    // get url and then encode it
    NSString *url = [NSString stringWithFormat:@"/wow/character/%@/%@",realmName,characterName];
    
    [self getPath:[url stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding] parameters:@{ @"apikey" : @"4dabm2d4336x9k3h6hppsyxhm3ghcxsd", @"fields" : @"guild,items,stats,talents,titles" } success:^(AFHTTPRequestOperation *operation, id responseObject) {
         
         Character *detailChar = [[Character alloc] initWithCharacterDetailData:responseObject];
         successBlock(detailChar);
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"characterWithName: - Error getting character detail: %@",[error localizedDescription]);
         errorBlock(error);
     }];
}

@end