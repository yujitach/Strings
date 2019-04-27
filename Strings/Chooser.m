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
        
        NSDictionary*foo=array[0];
        NSString*target=[foo valueForKey:@"target"];
        isMain=[target hasSuffix:@"plist"];
        if(isMain){
            allData=[[NSMutableArray alloc] init];
            for(NSDictionary*dic in array){
                NSString*target=[dic valueForKey:@"target"];
                NSMutableDictionary*dict=[NSMutableDictionary dictionaryWithContentsOfURL:[NSURL fileURLWithPath:[self localPathForPath:target]]];
                NSArray*a=[dict valueForKey:@"conferences"];
                [allData addObject:@{@"name":[dic valueForKey:@"name"],@"content":a}];
            }
        }
        name=[_dic valueForKey:@"name"];
        if(name){
            self.navigationItem.title=name;
        }
        sc=[[UISearchController alloc] initWithSearchResultsController:nil];
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Business logic
-(NSString*)localPathForPath:(NSString*)path
{
    NSString*lc=[path lastPathComponent];
    NSString*head=[lc stringByDeletingPathExtension];
    NSString*localPath=[[NSBundle mainBundle] pathForResource:head ofType:@"plist"];
    return localPath;
}
-(void)loadPlist:(NSString*)path withTitle:(NSString*)title;
{
    NSMutableDictionary*dict=[NSMutableDictionary dictionaryWithContentsOfURL:[NSURL fileURLWithPath:[self localPathForPath:path]]];
    if(!dict[@"name"]){
        dict[@"name"] = title;
    }
    Chooser*chooser=[[Chooser alloc] initWithDictionary:dict];
    [self.navigationController pushViewController:chooser animated:YES];
}
-(void)loadPDF:(NSDictionary*)entry
{
    NSMutableDictionary*e=[entry mutableCopy];
    e[@"parentName"]=name;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"openPDF" object:e];
}
#pragma mark - View lifecycle
- (BOOL)isFiltering
{
    return sc.isActive && ![sc.searchBar.text isEqualToString:@""];
}
-(NSArray*)filtArray:(NSArray*)array bySearch:(NSString*)search
{
    return [array filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"annotation contains[cd] %@ OR name contains[cd] %@",search,search]];
}
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString*search=searchController.searchBar.text;
    if(isMain){
        NSMutableArray*x=[[NSMutableArray alloc] init];
        for(NSDictionary* d in allData){
            NSArray*a=[d valueForKey:@"content"];
            NSArray*y=[self filtArray:a bySearch:search];
            if([y count]>0){
                [x addObject:@{@"name": [d valueForKey:@"name"],@"content":y}];
            }
        }
        filtArray=x;
    }else{
        filtArray=[self filtArray:array bySearch:search];
    }
    [self.tableView reloadData];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    self.navigationController.preferredContentSize=self.tableView.contentSize;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    sc.searchResultsUpdater=self;
    self.navigationItem.searchController=sc;
    sc.obscuresBackgroundDuringPresentation=NO;
    self.definesPresentationContext=YES;
    [self.tableView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self.tableView removeObserver:self forKeyPath:@"contentSize"];
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
    if([self isFiltering] && isMain){
        return [filtArray count];
    }
    return 1;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if([self isFiltering] && isMain){
        NSDictionary*d=filtArray[section];
        return [d valueForKey:@"name"];
    }
    return nil;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if([self isFiltering]){
        if(isMain){
            NSDictionary*d=filtArray[section];
            NSArray*a=[d valueForKey:@"content"];
            return [a count];
        }
        return [filtArray count];
    }
    return [array count];
}
- (NSArray*)arrayForIndexPath:(NSIndexPath*)indexPath
{
    NSArray*a=array;
    if([self isFiltering]){
        if(isMain){
            NSDictionary*d=filtArray[[indexPath section]];
            a=[d valueForKey:@"content"];
        }else{
            a=filtArray;
        }
    }
    return a;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    NSArray*a=[self arrayForIndexPath:indexPath];
    NSDictionary*entry=a[[indexPath row]];
    NSString*nname=entry[@"name"];
    NSString*annotation=entry[@"annotation"];
    NSRange r=[nname rangeOfString:@"("];
    if(r.location!=NSNotFound){
        nname=[nname substringWithRange:NSMakeRange(0,r.location)];
    }
    cell.textLabel.text=nname;
    cell.detailTextLabel.text=annotation;
    NSString*target=entry[@"target"];
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
    NSArray*a=[self arrayForIndexPath:indexPath];
    NSDictionary*entry=a[[indexPath row]];
    NSString*target=entry[@"target"];
    if([target hasSuffix:@"plist"]){
        [self loadPlist:target withTitle:entry[@"name"]];
    }else if([target hasSuffix:@"pdf"]){
        [self loadPDF:entry];        
    }
}

@end
