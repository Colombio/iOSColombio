//
//  LoginViewController.m
//  colombio
//
//  Created by Vlatko Šprem on 16/08/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "Messages.h"
#import "CryptoClass.h"
#import "Validation.h"

/*
#import "Countries.h"
#import "CreateAcc.h"
#import "ForgotPassword.h"
#import "GoogleLogin.h"
#import "Home.h"
*/

@interface LoginViewController ()

@end

@implementation LoginViewController

@synthesize txtEmail;
@synthesize txtPassword;
@synthesize scrollBox;
@synthesize imgInputEmail;
@synthesize imgInputPassword;
@synthesize imgPassEmail;
@synthesize imgFailEmail;
@synthesize imgFailPassword;
@synthesize imgPassPassword;
@synthesize btnLogin;
@synthesize scrollView;
@synthesize pageControl;
@synthesize pageImages;
@synthesize pageViews;

- (void)viewDidLoad
{
    [super viewDidLoad];
    lastPage=0;
    //Skrivanje slicica da li su pogresni inputi
    imgPassEmail.hidden = YES;
    imgFailEmail.hidden = YES;
    imgPassPassword.hidden = YES;
    imgFailPassword.hidden = YES;
    
    //Skrivanje inputa
    txtPassword.secureTextEntry = YES;
    
    //Provjeravanje tokena, ako je korisnik vec logiran u sustavu, proslijedi ga na home
    timer = [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(provjeriToken) userInfo:nil repeats:NO];
    
    //Testiranje lokalizacije
    [txtPassword setPlaceholder:NSLocalizedString(@"T", nil)];
    
    //Dodavanje sličica za swipe
    pageControlBeingUsed = NO;
    int xPosition=0;
    NSArray *colors;
    CGRect screenBounds = [[UIScreen mainScreen]bounds];
    if(screenBounds.size.height == 568.0f){
        colors = [NSArray arrayWithObjects:
                  @"swipelogin1_iphone5@2x.png",
                  @"swipelogin2_iphone5@2x.png",
                  @"swipelogin3_iphone5@2x.png", nil];
    }
    else{
        colors = [NSArray arrayWithObjects:
                  @"loginswipe1.png",
                  @"loginswipe2.png",
                  @"loginswipe3.png", nil];
    }
    for (int i = 0; i < colors.count; i++) {
        CGRect frame;
        frame.origin.x = xPosition;
        xPosition+=320;
        float imageSize;
        float headerOffset=0;
        frame.origin.y = 0;
        if(screenBounds.size.height == 568.0f){
            frame.size.height = 267;
            imageSize=267;
        }
        /*else{
         frame.size.height = 215;
         imageSize=215;
         }*/
        else{
            frame.size.height = 267;
            imageSize=187;
            headerOffset=80;
        }
        frame.size.width=320;
        
        UIGraphicsBeginImageContextWithOptions(self.view.frame.size, NO, 0.f);
        UIImage *targetImage = [UIImage imageNamed:[colors objectAtIndex:i]];
        [targetImage drawInRect:CGRectMake(0.f, headerOffset, self.view.frame.size.width, imageSize)];
        UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        UIView *subview = [[UIView alloc] initWithFrame:frame];
        subview.backgroundColor = [UIColor colorWithPatternImage:resultImage];
        [self.scrollView addSubview:subview];
    }
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * colors.count, self.scrollView.frame.size.height);
    
    self.pageControl.currentPage = 0;
    self.pageControl.numberOfPages = colors.count;
    
    [pageControl removeFromSuperview];
    
    //Manualno pozicioniranje pageControl kontrole
    if(screenBounds.size.height == 568.0f){
        pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(141, 226, 38, 36)];
    }
    /*else{
     pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(141, 157, 38, 36)];
     }*/
    else{
        pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(141, 226, 38, 36)];
    }
    [pageControl setNumberOfPages:3];
    [pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
    [self.scrollBox addSubview:pageControl];
    timer=nil;
    [scrollBox setDelegate:self];
    if(screenBounds.size.height == 568.0f){
        scrollBox.scrollEnabled=NO;
    }
    [scrollBox setContentOffset:CGPointMake(0,0) animated:NO];
}

//Da se zastopa skrol ako otide lijevo ili desno
//Da se pomakne slicica ako se prijede polovicu
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(self.scrollView.contentOffset.x<0){
        [self.scrollView setScrollEnabled:NO];
        [self.scrollView setContentOffset:CGPointMake(0, 0)];
        [self.scrollView setScrollEnabled:YES];
        return;
    }
    
    else if(self.scrollView.contentOffset.x>640){
        [self.scrollView setScrollEnabled:NO];
        [self.scrollView setContentOffset:CGPointMake(640, 0)];
        [self.scrollView setScrollEnabled:YES];
        return;
    }
    
    CGRect screenBounds = [[UIScreen mainScreen]bounds];
    if(screenBounds.size.height != 568.0f){
        if(self.scrollBox.contentOffset.y<80){
            [self.scrollBox setScrollEnabled:NO];
            [self.scrollBox setContentOffset:CGPointMake(0, 80)];
            [self.scrollBox setScrollEnabled:YES];
            return;
        }
        
    }
    if([txtEmail isFirstResponder]||[txtPassword isFirstResponder]){
        
        if(self.scrollBox.contentOffset.y>300){
            [self.scrollBox setScrollEnabled:NO];
            [self.scrollBox setContentOffset:CGPointMake(0, 300)];
            [self.scrollBox setScrollEnabled:YES];
        }
        return;
    }
    if(self.scrollBox.contentOffset.y>80){
        [self.scrollBox setScrollEnabled:NO];
        [self.scrollBox setContentOffset:CGPointMake(0, 80)];
        [self.scrollBox setScrollEnabled:YES];
        return;
    }
    if (!pageControlBeingUsed) {
        // Switch the indicator when more than 50% of the previous/next page is visible
        CGFloat pageWidth = self.scrollView.frame.size.width;
        int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        self.pageControl.currentPage = page;
        lastPage=pageControl.currentPage;
    }
}

- (void)viewDidLayoutSubviews{
    CGRect screenBounds = [[UIScreen mainScreen]bounds];
    if(screenBounds.size.height != 568.0f){
        scrollBox.contentSize = CGSizeMake(scrollBox.frame.size.width, scrollBox.frame.size.height+300);
        [self.scrollBox setContentOffset:CGPointMake(0, 80)];
    }
    [scrollView setDelegate:self];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    pageControlBeingUsed = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    pageControlBeingUsed = NO;
}

//Disable longtouch itd
- (BOOL)canBecomeFirstResponder{
    return NO;
}


/*
//Provjeravanje da li je pohranjeni token još uvijek aktivan na serveru
- (void)provjeriToken{
    @try {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *filePathUser =[documentsDirectory stringByAppendingPathComponent:@"korisnik.out"];
        NSString *filePathToken =[documentsDirectory stringByAppendingPathComponent:@"token.out"];
        NSString *token = [NSString stringWithContentsOfFile:filePathToken encoding:NSUTF8StringEncoding error:nil];
        NSString *userId = [NSString stringWithContentsOfFile:filePathUser encoding:NSUTF8StringEncoding error:nil];
        
        NSDictionary *provjera = @{@"usr" : userId,@"token" : token};
        NSError *err;
        NSData *data = [NSJSONSerialization dataWithJSONObject:provjera options:0 error:&err];
        
        if(!data){
            [Messages showErrorMsg:@"Pogreška prilikom slanja zahtjeva!"];
            return;
        }
        else{
            //Napravi base64 encoding
            NSMutableString *result= [CryptoClass base64Encoding:data];
            
            //URL sa signed req
            NSString *url_str = [NSString stringWithFormat:@"https://appforrest.com/colombio/api_user_managment/mau_check_status?signed_req=%@",result];
            NSURL * url = [NSURL URLWithString:url_str];
            NSError *err=nil;
            NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:url];
            NSURLResponse *response = nil;
            NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
            NSDictionary *odgovor=nil;
            
            //Ako su uspjesno dohvaceni podaci sa servera
            if(err==nil){
                odgovor =[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                NSString *test= [odgovor objectForKey:@"s"];
                if(!strcmp("1", test.UTF8String)){
                    NSString *firstLogin = [odgovor objectForKey:@"first_login"];
                    //Ako korisnik nije popunio pocetne postavke prikazi popis drzava
                    if(!strcmp("1", firstLogin.UTF8String)){
                        Countries *states = [[Countries alloc]init];
                        [self presentViewController:states animated:YES completion:nil];
                        return;
                    }
                    //Ako je korisnik vec popunio pocetne podatke prikazi home
                    else{
                        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
                        Home *home = (Home*)[storyboard instantiateViewControllerWithIdentifier:@"home"];
                        [self presentViewController:home animated:YES completion:nil];
                        return;
                    }
                }
            }
            //Nije uspješna komunikacija sa serverom
            else{
                [Messages showErrorMsg:@"Pogreška prilikom slanja zahtjeva11"];
            }
        }
    }
    //Token ne postoji ili se dogodila greska prilikom pristupa
    @catch(NSException *ex){
        
    }
}

 
//Google login gumb
- (IBAction)setGoogle:(id)sender{
    [txtPassword resignFirstResponder];
    [txtEmail resignFirstResponder];
    GoogleLogin *gg = [[GoogleLogin alloc]init];
    [self presentViewController:gg animated:YES completion:nil];
}
*/

//Ako je pritisnuo korisnik na background, makni tipkovnicu
//odnosno scrollaj view
- (IBAction)goAwayKeyboard:(id)sender{
    UITextField *gumb = (UITextField *)sender;
    if(gumb.tag==1){
        [txtPassword becomeFirstResponder];
    }
    else
    {
        [sender resignFirstResponder];
        
        CGRect screenBounds = [[UIScreen mainScreen]bounds];
        if(screenBounds.size.height == 568.0f){
            [scrollBox setContentOffset:CGPointMake(0,135) animated:YES];
            return;
        }
        [scrollBox setContentOffset:CGPointMake(0,0) animated:YES];
    }
}

//Da se makne keyboard
- (IBAction)tapBackground:(id)sender{
    [txtEmail resignFirstResponder];
    [txtPassword resignFirstResponder];
}

-(void)toggleLoginOn{
    [btnLogin setTitle:@"Please wait..." forState:UIControlStateNormal];
}

-(void)toggleLoginOff{
    [btnLogin setTitle:@"Log In" forState:UIControlStateNormal];
}

/*
//Provjera ako se korisnik odlucio na normalni login
-(void)checkLoginNormal{
    imgFailEmail.hidden=YES;
    imgInputPassword.hidden=YES;
    
    imgFailPassword.hidden=YES;
    imgInputPassword.hidden=YES;
    
    //Provjera da li su email i lozinka prazni
    Boolean wrong = false;
    UIColor *color = [UIColor redColor];
    if(![_Validation validateEmail:txtEmail.text]){
        wrong=true;
        txtEmail.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Check your email" attributes:@{NSForegroundColorAttributeName:color}];
        imgFailEmail.hidden=NO;
        imgInputEmail.hidden=YES;
        txtEmail.text=@"";
    }
    
    //Lozinka je prazna
    if(txtPassword.text.length<8){
        wrong=true;
        txtPassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Check your password" attributes:@{NSForegroundColorAttributeName:color}];
        imgFailPassword.hidden=NO;
        imgInputPassword.hidden=YES;
        txtPassword.text=@"";
    }
    
    //pocetna konfiguracija za datoteke
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePathUser =[documentsDirectory stringByAppendingPathComponent:@"korisnik.out"];
    NSString *filePathToken =[documentsDirectory stringByAppendingPathComponent:@"token.out"];
    
    //Slanje podataka za prijavu i dohvacanje odgovora
    NSString *url_str = [NSString stringWithFormat:@"https://appforrest.com/colombio/api_user_managment/mau_login/"];
    NSURL * url = [NSURL URLWithString:url_str];
    NSError *err=nil;
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:url];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[[NSString stringWithFormat:@"login_string=%@&login_pass=%@",txtEmail.text,txtPassword.text]dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPMethod:@"POST"];
    NSURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    
    //Dogodila se pogreska prilikom dohvacanja zahtjeva
    if(err){
        [Messages showErrorMsg:@"Pogreska prilikom slanja zahtjeva12"];
    }
    
    //Uspjesno je poslan zahtjev
    else{
        Boolean pogreska=false;
        NSDictionary *odgovor=nil;
        odgovor =[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        NSArray *keys =[odgovor allKeys];
        
        for(NSString *key in keys){
            //Provjera za ispravnost prijave
            if(!strcmp("s", key.UTF8String)){
                txtEmail.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Check your email" attributes:@{NSForegroundColorAttributeName:color}];
                txtPassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Check your password" attributes:@{NSForegroundColorAttributeName:color}];
                pogreska=true;
                imgInputPassword.hidden=YES;
                imgInputEmail.hidden=YES;
                imgFailEmail.hidden=NO;
                imgFailPassword.hidden=NO;
                txtPassword.text=@"";
                txtEmail.text=@"";
                break;
            }
        }
        //Ako je uspjesna prijava, spremi user id i token u datoteke
        // i preusmjeri korisnika na drugi view
        if(!pogreska){
            NSString *token = [odgovor objectForKey:@"token"];
            NSDictionary *korisnik =[odgovor objectForKey:@"usr"];
            NSString *userId=[korisnik objectForKey:@"user_id"];
            [userId writeToFile:filePathUser atomically:YES encoding:NSUTF8StringEncoding error:nil];
            [token writeToFile:filePathToken atomically:YES encoding:NSUTF8StringEncoding error:nil];
            Countries *states = [[Countries alloc]init];
            [self presentViewController:states animated:YES completion:nil];
        }
    }
    timer = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(toggleLoginOff) userInfo:nil repeats:NO];
    timer=nil;
}


//Login gumb
- (IBAction)setLogin:(id)sender {
    if(timer!=nil){
        return;
    }
    timer = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(toggleLoginOn) userInfo:nil repeats:NO];
    timer = [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(checkLoginNormal) userInfo:nil repeats:NO];
}

//Kreiranje racuna
- (IBAction)setSign:(id)sender {
    CreateAcc *createAccount = [[CreateAcc alloc]init];
    [self presentViewController:createAccount animated:YES completion:nil];
}

//Zaboravljena lozinka
- (IBAction)setForgot:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    ForgotPassword *log = (ForgotPassword*)[storyboard instantiateViewControllerWithIdentifier:@"forgot"];
    [self presentViewController:log animated:YES completion:nil];
}

//Kada korisnik stisne na email, scrollaj view
- (IBAction)setEmail:(id)sender{
    imgInputEmail.hidden=YES;
    [txtEmail setPlaceholder:@"Email"];
    CGRect screenBounds = [[UIScreen mainScreen]bounds];
    if(screenBounds.size.height == 568.0f){
        [scrollBox setContentOffset:CGPointMake(0,215) animated:YES];
    }
    else{
        [scrollBox setContentOffset:CGPointMake(0,300) animated:YES];
    }
    imgFailEmail.hidden=YES;
}

//Kada korisnik stisne na loyinku, scrollaj view
- (IBAction)setPassword:(id)sender{
    imgInputPassword.hidden=YES;
    imgFailPassword.hidden=YES;
    [txtPassword setPlaceholder:@"Password"];
    CGRect screenBounds = [[UIScreen mainScreen]bounds];
    if(screenBounds.size.height == 568.0f){
        [scrollBox setContentOffset:CGPointMake(0,215) animated:YES];
    }
    else{
        [scrollBox setContentOffset:CGPointMake(0,300) animated:YES];
    }
}

//Facebook login
- (IBAction)setFacebook:(id)sender {
    [txtEmail resignFirstResponder];
    [txtPassword resignFirstResponder];
    if(timer!=nil){
        return;
    }
    timer = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(toggleLoginOn) userInfo:nil repeats:NO];
    timer = [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(checkLoginFacebook) userInfo:nil repeats:NO];
}

//Ako se klikne na facebook button
-(void)checkLoginFacebook{
    if([FBSession activeSession].state == FBSessionStateOpen  || [FBSession activeSession].state==FBSessionStateOpenTokenExtended){
        [[FBSession activeSession] closeAndClearTokenInformation];
    }
    else{
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile",@"email"] allowLoginUI:YES completionHandler:^(FBSession *session,FBSessionState status,NSError *error) {
            NSString *token =[[[FBSession activeSession]accessTokenData]accessToken];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *filePathUser =[documentsDirectory stringByAppendingPathComponent:@"korisnik.out"];
            NSString *filePathToken =[documentsDirectory stringByAppendingPathComponent:@"token.out"];
            
            //Slanje podataka za prijavu i dohvacanje odgovora
            NSString *url_str = [NSString stringWithFormat:@"https://appforrest.com/colombio/api_user_managment/mau_social_login?type=fb&token=%@",token];
            NSURL * url = [NSURL URLWithString:url_str];
            NSError *err=nil;
            NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:url];
            NSURLResponse *response = nil;
            NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
            //Dogodila se pogreska prilikom dohvacanja zahtjeva
            if(err){
                [Messages showErrorMsg:@"Pogreska prilikom slanja zahtjeva15"];
            }
            
            //Uspjesno je poslan zahtjev
            else{
                Boolean pogreska=false;
                NSDictionary *odgovor=nil;
                odgovor =[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                NSArray *keys =[odgovor allKeys];
                for(NSString *key in keys){
                    //Provjera za ispravnost prijave
                    if(!strcmp("s", key.UTF8String)){
                        pogreska=true;
                        break;
                    }
                }
                
                //Ako je uspjesna prijava, spremi user id i token u datoteke
                // i preusmjeri korisnika na drugi view
                if(!pogreska){
                    NSString *token = [odgovor objectForKey:@"token"];
                    NSDictionary *korisnik =[odgovor objectForKey:@"usr"];
                    NSString *userId=[korisnik objectForKey:@"user_id"];
                    [userId writeToFile:filePathUser atomically:YES encoding:NSUTF8StringEncoding error:nil];
                    [token writeToFile:filePathToken atomically:YES encoding:NSUTF8StringEncoding error:nil];
                    Countries *states = [[Countries alloc]init];
                    states.arSelectedRows = [[NSMutableArray alloc] init];
                    [self presentViewController:states animated:YES completion:nil];
                }
            }
        }];
    }
    timer = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(toggleLoginOff) userInfo:nil repeats:NO];
    timer=nil;
}

- (void)scrollHappened{
    // Update the scroll view to he appropriate page
    CGRect frame;
    frame.origin.x = self.scrollView.frame.size.width * self.pageControl.currentPage;
    lastPage=pageControl.currentPage;
    frame.origin.x = 420;
    frame.origin.y = 0;
    frame.size = self.scrollView.frame.size;
    [self.scrollView scrollRectToVisible:frame animated:YES];
    pageControlBeingUsed = YES;
}

- (IBAction)changePage:(id)sender {
    pageControl.currentPage=lastPage;
}
*/
@end
