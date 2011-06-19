//
//  Chooser.m
//  Strings
//
//  Created by Yuji on 6/18/11.
//  Copyright 2011 東京大学. All rights reserved.
//

#import "Chooser.h"


@implementation Chooser

- (id)initWithDictionary:(NSDictionary*)_dic
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        // Custom initialization
        array=[_dic valueForKey:@"conferences"];
        if(!array){
            array=[_dic valueForKey:@"entries"];   
        }
        [array retain];
        NSString*name=[_dic valueForKey:@"name"];
        if(name){
            self.navigationItem.title=name;
        }
    }
    return self;
}

- (void)dealloc
{
    [array release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Business logic
-(void)loadPlist:(NSString*)path withTitle:(NSString*)title;
{
    NSString*cachesFolder=[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"];
    NSString*fpath=[path stringByReplacingOccurrencesOfString:@"/" withString:@"@"];
    fpath=[fpath stringByReplacingOccurrencesOfString:@":" withString:@"_"];
    NSString*cachePath=[cachesFolder stringByAppendingPathComponent:fpath];
    NSFileManager*fm=[[NSFileManager alloc] init];
    if(![fm fileExistsAtPath:cachePath]){
	[fm createDirectoryAtPath:cachesFolder withIntermediateDirectories:YES attributes:nil error:NULL];
        NSData*plist=[NSData dataWithContentsOfURL:[NSURL URLWithString:path]];
        if(plist && [plist length]>0){
            [plist writeToFile:cachePath atomically:YES];
        }
    }
    [fm release];
    NSMutableDictionary*dict=[NSMutableDictionary dictionaryWithContentsOfURL:[NSURL fileURLWithPath:cachePath]];
    if(![dict objectForKey:@"name"]){
        [dict setObject:title forKey:@"name"];
    }
    Chooser*chooser=[[Chooser alloc] initWithDictionary:dict];
    [self.navigationController pushViewController:chooser animated:YES];
    [chooser release];
}
-(void)loadPDF:(NSDictionary*)entry
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"openPDF" object:entry];
}
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [array count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    NSDictionary*entry=[array objectAtIndex:[indexPath row]];
    NSString*name=[entry objectForKey:@"name"];
    NSString*annotation=[entry objectForKey:@"annotation"];
    NSRange r=[name rangeOfString:@"("];
    if(r.location!=NSNotFound){
        name=[name substringWithRange:NSMakeRange(0,r.location)];
    }
    cell.textLabel.text=name;
    cell.detailTextLabel.text=annotation;
    NSString*target=[entry objectForKey:@"target"];
    if([target hasSuffix:@"plist"]){
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    NSDictionary*entry=[array objectAtIndex:[indexPath row]];
    NSString*target=[entry objectForKey:@"target"];
    if([target hasSuffix:@"plist"]){
        [self loadPlist:target withTitle:[entry objectForKey:@"name"]];
    }else if([target hasSuffix:@"pdf"]){
        [self loadPDF:entry];        
    }
}

@end
