#include "Preferences/PSSpecifier.h"



@interface PSUIPrefsListController

@property (nonatomic, assign) BOOL performedActions;
-(id)specifiers;
-(void)reload;
-(void)substituteSpecifierNames;
@end


%hook PSUIPrefsListController


%property (nonatomic, assign) BOOL performedActions;


%new
-(void)substituteSpecifierNames
{
  // my favorite debugger, the UIAlertView
  // [[[UIAlertView alloc] initWithTitle:@"Performing Actions" message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
  NSMutableArray *specifiers = [self specifiers];
  // laod substitute strings from plist file
  // loading it from a file allows the tweak to use custom strings user puts in it
  NSDictionary* substituteStrings = [NSDictionary dictionaryWithContentsOfFile:@"/private/var/mobile/Library/Application Support/xyz.xninja.dopesettings.bundle/substitutes.plist"];
  // NSDictionary to capture all available specifier IDs

  NSMutableDictionary *referenceIDs = [[NSMutableDictionary alloc] init];
  for(PSSpecifier *specifier in specifiers)
  {
    if(specifier.identifier)
    {
      // add specifier ID to the dictionary
      [referenceIDs setValue:specifier.name forKey:specifier.identifier];

      // specifier name is what the cell uses as title. Replacing the name with substitute from the plist
      if(NSString *substitute = [substituteStrings objectForKey:specifier.identifier])
      {
        specifier.name = substitute;
      }
    }
  }

  // write available IDs to Documents so that user can use it as a reference when editing the substitutes.plist
  [referenceIDs writeToFile:@"/private/var/mobile/Library/Application Support/xyz.xninja.dopesettings.bundle/referenceIDs.plist" atomically:TRUE];
}

- (int)numberOfSectionsInTableView:(id)arg1
{
  //this method is called before view is loaded but more than once. Names need to be substituted only once
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
