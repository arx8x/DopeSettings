#include "Preferences/PSSpecifier.h"




@interface PSUIPrefsListController

@property (nonatomic, assign) BOOL performedActions;
-(id)specifiers;
-(void)reload;
-(void)substituteSpecifierNames;
@end

static bool isAprilFools = false;
const PSSpecifier *appleAccountSpecifier = NULL;



%hook PSUIPrefsListController


%property (nonatomic, assign) BOOL performedActions;



-(id) specifiers
{
  NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit fromDate:[NSDate date]];
  if([components month] == 4 && [components day] == 1)
  {
    isAprilFools = true;
  }
  NSMutableArray *specifiers = %orig;
  for(PSSpecifier *specifier in specifiers)
  {
    if(specifier.identifier)
    {
      // April fools'
      if([specifier.identifier isEqualToString:@"APPLE_ACCOUNT"] && isAprilFools)
      {
        appleAccountSpecifier = specifier;
      }
    }
  }

  return specifiers;
}
- (void)reloadSpecifierAtIndex:(long long)arg1 animated:(bool)arg2
{
  %orig;
  // fix the specifier changing back after tapping the cell
  if(appleAccountSpecifier && isAprilFools)
  {
    [appleAccountSpecifier setProperty:@"Ian Beer" forKey:@"label"];
    UIImage *iconImage = [UIImage imageWithContentsOfFile:@"/Library/Application Support/TimApple.png"];
    [appleAccountSpecifier setProperty:iconImage forKey:@"iconImage"];
  }
  [self reload];
}



%new
-(void)substituteSpecifierNames
{

  NSMutableArray *specifiers = [self specifiers];
  // laod substitute strings from plist file
  // loading it from a file allows the tweak to use custom strings user puts in it


  // NSDictionary *substituteStrings =
  // @{
  //   @"AIRPLANE_MODE" : @"no NSA mode",
  //   @"Bluetooth" : @"Are your teeth blue yet?",
  //   @"CASTLE" : @"Nude leak center",
  //   @"COMPASS" : @"Fancy useless shit",
  //   @"CONTACTS" : @"Telephone Directory",
  //   @"Carrier" : @"Radiation provider",
  //   @"ControlCenter" : @"Control my Centre ( ͡° ͜ʖ ͡°)",
  //   @"DISPLAY" : @"Display & Blindness",
  //   @"DO_NOT_DISTURB" : @"Shut the fuck up plz",
  //   @"General" : @"Actual settings you're looking for",
  //   @"INTERNET_TETHERING" : @"Magical ability to give out internet",
  //   @"MAPS" : @"To the ocean",
  //   @"MOBILE_DATA_SETTINGS_ID" : @"Heating mode",
  //   @"NOTES" : @"Scribblings",
  //   @"NOTIFICATIONS_ID" : @"Attention grabbing options",
  //   @"Phone" : @"Telephone",
  //   @"Privacy" : @"High five brah",
  //   @"REMINDERS" : @"Procasturbator",
  //   @"SIRI" : @"Dumbass",
  //   @"Sounds" : @"Noises n' shit",
  //   @"VPN" : @"Alternate Spy Network",
  //   @"WIFI" : @"Internet from thin air"
  // };

  // NSDictionary *substituteStrings = [NSDictionary dictionaryWithContentsOfFile:@"/Library/Application Support/DopeSettings/defaults.bundle/defaults.plist"];
  NSMutableDictionary *substituteStrings = [NSMutableDictionary dictionaryWithContentsOfFile:@"/private/var/mobile/Library/Preferences/xyz.xninja.dopesettings.plist"];
  if(!substituteStrings)
  {
    substituteStrings = [[NSMutableDictionary alloc] initWithDictionary:
    @{
      @"AIRPLANE_MODE" : @"no NSA mode",
      @"Bluetooth" : @"Are your teeth blue yet?",
      @"CASTLE" : @"Nude leak center",
      @"COMPASS" : @"Fancy useless shit",
      @"CONTACTS" : @"Telephone Directory",
      @"Carrier" : @"Radiation provider",
      @"ControlCenter" : @"Control my Centre ( ͡° ͜ʖ ͡°)",
      @"DISPLAY" : @"Display & Blindness",
      @"DO_NOT_DISTURB" : @"Shut the fuck up plz",
      @"General" : @"Actual settings you're looking for",
      @"INTERNET_TETHERING" : @"Magical ability to give out internet",
      @"MAPS" : @"To the ocean",
      @"MOBILE_DATA_SETTINGS_ID" : @"Heating mode",
      @"NOTES" : @"Scribblings",
      @"NOTIFICATIONS_ID" : @"Attention grabbing options",
      @"Phone" : @"Telephone",
      @"Privacy" : @"High five brah",
      @"REMINDERS" : @"Procasturbator",
      @"SIRI" : @"Dumbass",
      @"Sounds" : @"Noises n' shit",
      @"VPN" : @"Alternate Spy Network",
      @"SCREEN_TIME" : @"OCD reports",
      @"MAIL" : @"Carrier Pigeons",
      @"SAFARI" : @"Chrome.exe",
      @"BATTERY_USAGE" : @"Jailbreaker OCD Center",
      @"WIFI" : @"Internet from thin air"
    }];
  }
  // NSDictionary to capture all available specifier IDs
  for(PSSpecifier *specifier in specifiers)
  {
    if(specifier.identifier)
    {
      if(specifier.identifier)
      {
        // April fools'
        if(isAprilFools)
        {
          if([specifier.identifier isEqualToString:@"APPLE_ACCOUNT"] )
          {
            [specifier setProperty:@"Ian Beer" forKey:@"label"];
            UIImage *iconImage = [UIImage imageWithContentsOfFile:@"/Library/Application Support/TimApple.png"];
            [specifier setProperty:iconImage forKey:@"iconImage"];
          }
          else
          {
            [specifier setProperty:[UIImage imageWithContentsOfFile:@"/Library/Application Support/ico.png"] forKey:@"iconImage"];
          }
        }
      }

      NSString *substitute = [substituteStrings objectForKey:specifier.identifier];

      // if user has set a substitute that's not any default value, use it
      if(![substitute isEqualToString:specifier.name] && [substitute length])
      {
        specifier.name = substitute;
      }
      if(specifier.name)
      {
        // if user substitute is not used, add the system default value to dictionary
        [substituteStrings setObject:specifier.name forKey:specifier.identifier];
      }
    }
  }

  // write available IDs and names so that user can use set their own values
  [substituteStrings writeToFile:@"/private/var/mobile/Library/Preferences/xyz.xninja.dopesettings.plist" atomically:TRUE];
}

// - (int)numberOfSectionsInTableView:(id)arg1
-(void)viewWillLayoutSubviews
{
  if(!self.performedActions)
  {
    [self substituteSpecifierNames];
    self.performedActions = TRUE;
  }
  return %orig;
}

- (void)_reallyLoadThirdPartySpecifiersForApps:(id)arg1 withCompletion:(id)arg2
{
  %orig;
  // at this point, all extra specifiers will be loaded. So we run the code again and grab/substitue all the spcifiers IDs and names
  [self substituteSpecifierNames];
  [self reload];
}


%end
