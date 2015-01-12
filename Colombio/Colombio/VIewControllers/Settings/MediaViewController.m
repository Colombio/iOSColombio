//
//  Home.m
//  Colombio
//
//  Created by Colombio on 6/20/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//
//  Kontroler za prikaz i odabir medija za korisnika

#import "MediaViewController.h"

@interface MediaViewController ()

@end

@implementation MediaViewController

@synthesize arSelectedRows;
@synthesize mediji;
@synthesize infobar;
@synthesize arrow;
@synthesize reusableView;
@synthesize arSelectedMedia;
@synthesize started;
@synthesize lbl;
@synthesize infoLabel;
@synthesize strelica;
@synthesize lastContentOffset;
@synthesize btnSearch;
@synthesize txtSearch;
@synthesize searchGradient;
@synthesize searchArrow;
@synthesize infoDescription;
@synthesize infoName;
@synthesize infoPanelDescription;
@synthesize infoArrow;
@synthesize infoPanel;
@synthesize reporterInfo;

//Pocetno ucitavanje pogleda, dohvacanje medija
- (void)viewDidLoad
{
    started=NO;
    hidden=YES;
    counter=0;
    reloadFirst=NO;
    offset=1;
    timerSearch=nil;
    searchHidden=YES;
 
    if(arSelectedMedia.count==0){
        arSelectedMedia = [[NSMutableArray alloc]init];
    }
}

#pragma mark LoadingData

//LoadingMedia
- (void)loadMedia{
    //pocetna konfiguracija za datoteke
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePathMediji =[documentsDirectory stringByAppendingPathComponent:@"medijiDohvaceni.out"];
    NSString *filePathTimeStamp = [documentsDirectory stringByAppendingPathComponent:@"timestamp_media.out"];
    
    //citanje posljednjeg timestampa za drzave
    NSString *lastTimestamp =[NSString stringWithContentsOfFile:filePathTimeStamp encoding:NSUTF8StringEncoding error:nil];
    
    //sinkrono dohvacanje podataka sa servera
    NSString *url_str = [NSString stringWithFormat:@"http://appforrest.com/colombio/api_config/get_media?sync_time=%@",lastTimestamp];
    NSURL * url = [NSURL URLWithString:url_str];
    NSError *err=nil;
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            Boolean mijenjano=true;
            NSMutableDictionary *odgovor=nil;
            
            //Ako su uspjesno dohvaceni podaci sa servera
            if(err==nil){
                odgovor =[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                NSArray *keys =[odgovor allKeys];
                for(NSString *key in keys){
                    //Nije mijenjan popis medija
                    if(!strcmp("s", key.UTF8String)){
                        mijenjano=false;
                        break;
                    }
                }
            }
            
            //Ako nije dobra konekcija
            else{
                [Messages showErrorMsg:@"This app requires internet connection. Please make sure that you are connected to the internet."];
            }
            //Ako je mijenjan popis medija
            if(mijenjano){
                //Spremanje zadnjeg timestampa u datoteku
                NSString *changeTimestamp=[odgovor objectForKey:@"change_timestamp"];
                [changeTimestamp writeToFile:filePathTimeStamp atomically:YES encoding:NSUTF8StringEncoding error:
                 nil];
                
                [odgovor writeToFile:filePathMediji atomically:YES];
            }
            
            //Ucitavanje medija iz datoteke
            NSDictionary *procitano=[NSDictionary dictionaryWithContentsOfFile:filePathMediji];
            self.mediji=[procitano objectForKey:@"data"];
            arMediaImages = mediji;
            
            [_collectionView reloadData];
            
            if(mijenjano==true){
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    [self loadImages];
                });
            }
        });
    }];
}

- (void)loadImages{
    NSDate *methodStart = [NSDate date];
    int i=0;
    for(NSDictionary *m in arMediaImages){
        if(exitingView==YES){
            return;
        }
        NSString *urlSlike=[m objectForKey:@"name"];
        NSString *link=[m objectForKey:@"media_icon"];
        NSString *documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
        
        NSDate *methodFinish2 = [NSDate date];
        NSTimeInterval executionTime2 = [methodFinish2 timeIntervalSinceDate:methodStart];
        NSLog(@"---------------DOWNLOADING STARTED---------------");
        NSLog(@"Time: =%f ",executionTime2);
        
        UIImage *imageFromURL = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:link]]];
        
        NSLog(@"---------------DOWNLOADING FINISHED---------------");
        NSDate *methodFinish = [NSDate date];
        NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
        NSLog(@"Time: =%f ",executionTime);
        
        NSLog(@"---------------IMAGE SAVED LOCALLY---------------");
        [UIImagePNGRepresentation(imageFromURL) writeToFile:[documentsDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",urlSlike,@"png"]] options:NSAtomicWrite error:nil];
        
        NSDate *methodFinish3 = [NSDate date];
        NSTimeInterval executionTime3 = [methodFinish3 timeIntervalSinceDate:methodStart];
        NSLog(@"Time: =%f ",executionTime3);
        NSLog(@">");
        NSLog(@">");
        NSLog(@"**************************************************");
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i+offset inSection:0];
        i++;
        NSArray *indexPaths = [[NSMutableArray alloc]initWithObjects:indexPath, nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_collectionView reloadItemsAtIndexPaths:indexPaths];
        });
    }
    if(exitingView==YES){
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [_collectionView reloadData];
    });
}

#pragma mark CollectionView

/*
 infoDescription.text = [[mediji objectAtIndex:pozicija-offset]objectForKey:@"description"];
 
 infoName.text=[[mediji objectAtIndex:pozicija-offset]objectForKey:@"name"];
 
- (void)nextView{
    exitingView=YES;
    UIView *fromView = self.view;
    ReporterInfo *yourInfo = [[ReporterInfo alloc]init];
    yourInfo.arSelectedRows=self.arSelectedRows;
    yourInfo.arSelectedMedia = self.arSelectedMedia;
    yourInfo.reporterInfo=self.reporterInfo;
    UIView *toView = yourInfo.view;
    
    CGRect viewSize = fromView.frame;
    
    [fromView.superview addSubview:toView];
    
    toView.frame = CGRectMake(320, viewSize.origin.y, 320, viewSize.size.height);
    
    [UIView animateWithDuration:0.4 animations:
     ^{
         fromView.frame = CGRectMake(-320, viewSize.origin.y, 320, viewSize.size.height);
         toView.frame = CGRectMake(0, viewSize.origin.y, 320, viewSize.size.height);
     }
                     completion:^(BOOL finished)
     {
         if(finished){
             [self presentViewController:yourInfo animated:NO completion:nil];
         }
     }
     ];
}

- (void)previousView{
    exitingView=YES;
    UIView *fromView = self.view;
    CountriesViewController *states = [[CountriesViewController alloc]init];
    states.arSelectedRows = self.arSelectedRows;
    states.arSelectedMedia = self.arSelectedMedia;
    states.reporterInfo=self.reporterInfo;
    UIView *toView = states.view;
    
    CGRect viewSize = fromView.frame;
    
    [fromView.superview addSubview:toView];
    
    toView.frame = CGRectMake(-320, viewSize.origin.y, 320, viewSize.size.height);
    
    [UIView animateWithDuration:0.4 animations:
     ^{
         fromView.frame = CGRectMake(320, viewSize.origin.y, 320, viewSize.size.height);
         toView.frame = CGRectMake(0, viewSize.origin.y, 320, viewSize.size.height);
     }
                     completion:^(BOOL finished)
     {
         if(finished){
             [self presentViewController:states animated:NO completion:nil];
         }
     }
     ];
}
*/

//Pocetno dodavanje celija u collection view
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary*m = [mediji objectAtIndex:pozicija];
    NSString *urlSlike=[m objectForKey:@"name"];
    cell.tag=pozicija;
    
    NSString *documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    
    cell.img.image=[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.%@",documentsDirectoryPath,urlSlike,@"png"]];
    [cell.img setHidden:NO];
    //Provjeravanje da li je medij vec selektiran, jer se refreshanjem celija gube podaci
    if([arSelectedMedia containsObject:[[mediji objectAtIndex:pozicija-offset] objectForKey:@"id"]]){
        [cell.notSelected setHidden:YES];
        [cell.select setHidden:NO];
    }
    else{
        [cell.notSelected setHidden:NO];
        [cell.select setHidden:YES];
    }
    return cell;
}

//Odabrana je neka celija
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    //Ako je odabrani medij selektiran, izbrisi ga iz polja selektiranih i refreshaj pogled
    if([arSelectedMedia containsObject:[[mediji objectAtIndex:pozicija-offset] objectForKey:@"id"]]){
        NSString *poz = [[mediji objectAtIndex:pozicija-offset]objectForKey:@"id"];
        [arSelectedMedia removeObject:poz];
    }
    //Ako odabrani medij nije selektiran, dodaj ga u polje selektiranih i refreshaj pogled
    else{
        NSString *poz = [[mediji objectAtIndex:pozicija-offset]objectForKey:@"id"];
        [arSelectedMedia addObject:poz];
        }
}

//Ukupan broj celija, + 10 zato da ima viska prostora na dnu kako bi mogao biti scrollabilan view
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [mediji count]+offset+4;
}

@end