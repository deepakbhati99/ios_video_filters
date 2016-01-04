//
//  filterViewController.m
//  filterVideo
//
//  Created by bd 001 on 12/18/15.
//  Copyright © 2015 bd 001. All rights reserved.
//

#import "filterViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "GPUImage.h"
#import "AppDelegate.h"

//@import MobileCoreServices;
@import Foundation;
@import CoreMedia;
@import CoreAudio;
@import AVFoundation;
@import AssetsLibrary;
@import MediaPlayer;
@import MobileCoreServices;

@import AVFoundation;
@import AssetsLibrary;
@import MediaPlayer;
@import CoreImage;
@interface filterViewController (){
    NSArray *filterNameArray;
    UIImage *originalImage;
    IBOutlet UIImageView *imageViewFiltered;
    NSURL *originalFileUrl;
    MPMoviePlayerController *videoPlayer;
    
    NSURL *outputVideoURL;
    CALayer *filterLayer;
    NSURL *audioFileURL;
}
@property (nonatomic,retain)    GPUImageMovie *movieFile;
@property (nonatomic,retain)    GPUImageOutput<GPUImageInput> *videoFilter;
@property (nonatomic,retain)    GPUImageMovieWriter *movieWriter;
@end

@implementation filterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"login_video"
                                                         ofType:@"MOV"];
    originalFileUrl = [NSURL fileURLWithPath:filePath];
    originalImage=[self videoThumbnail:originalFileUrl fromsec:0.1];
    imageViewFiltered.image=originalImage;
     outputVideoURL = [self dataFilePath:@"tempPost.mp4"];
    
    videoPlayer = [[MPMoviePlayerController alloc] initWithContentURL:originalFileUrl];
    
    //  Here is where you set the control Style like fullscreen or embedded
    videoPlayer.movieSourceType = MPMovieSourceTypeFile;
    videoPlayer.controlStyle = MPMovieControlStyleNone;

    videoPlayer.scalingMode = MPMovieScalingModeAspectFill;
    
    [imageViewFiltered layoutIfNeeded];
    
    [self playTheVideo:originalFileUrl];
    [self prepareAllFilter];
    
//    [self getAudioFromVideo:originalFileUrl];
}
-(void)viewWillAppear:(BOOL)animated{
    
    // registering mpmovieplayer state change notification
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinished) name:MPMoviePlayerPlaybackDidFinishNotification object:videoPlayer];
    
    [videoPlayer play];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    
    // unregistering mpmovieplayer state change notification
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:videoPlayer];
    
    [videoPlayer stop];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSURL *) dataFilePath:(NSString *)path{
    //creating a path for file and checking if it already exist if exist then delete it
    
    NSString *outputPath = [[NSString alloc] initWithFormat:@"%@%@", NSTemporaryDirectory(), path];
    
    BOOL success;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    success = [fileManager fileExistsAtPath:outputPath];
    
    if (success) {
        success=[fileManager removeItemAtPath:outputPath error:nil];
    }
    
    return [NSURL fileURLWithPath:outputPath];

}
- (UIImage*) videoThumbnail:(NSURL *) video fromsec:(NSInteger)fromsec{
    
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:video options:nil];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;
    CMTime time = [asset duration];
    time.value = fromsec*time.timescale;
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [generator copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *thumbnail = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return thumbnail;
}

#pragma mark- Video Initialize
#pragma mark

-(void) playTheVideo:(NSURL *)videoURL{
    NSTimeInterval time= videoPlayer.currentPlaybackTime;

    UIView *parentView = imageViewFiltered; // adjust as needed
    CGRect bounds = parentView.bounds; // get bounds of parent view
    CGRect subviewFrame = CGRectInset(bounds, 0, 0); // left and right margin of 0
    videoPlayer.view.frame = subviewFrame;
    videoPlayer.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    
    [parentView addSubview:videoPlayer.view];
    videoPlayer.contentURL = videoURL;
    [videoPlayer setCurrentPlaybackTime:time];
    
    
    [videoPlayer stop];
    [videoPlayer play];
    self.showLoading=NO;
    

}


-(void)movieFinished{
    //notification occured with moviedidfinish., restarting it.
    [videoPlayer play];
}

#pragma mark- ChooseVideo
- (IBAction)selectNewImage:(id)sender {

    UIAlertController *alertController=[UIAlertController alertControllerWithTitle:@"select your prefered method" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"Cancel action");
                                   }];

    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"Camera", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   NSLog(@"OK action");
                                   
                                   UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                                   if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
                                   {
                                       imagePicker.delegate = (id)self;
                                       imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                                       imagePicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];

                                       imagePicker.allowsEditing=NO;
                                       [self.navigationController presentViewController:imagePicker animated:YES completion:^{
                                           self.navigationController.navigationBarHidden=NO;
                                       }];

                                   }else{
                                   }
                               }];
    UIAlertAction *LibraryAction = [UIAlertAction
                                    actionWithTitle:NSLocalizedString(@"Library", @"OK action")
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction *action)
                                    {
                                        NSLog(@"OK action");
                                        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                                        imagePicker.delegate = (id)self;
                                        imagePicker.allowsEditing = NO;
                                        
                                        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                        imagePicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];

                                        [self.navigationController presentViewController:imagePicker animated:YES completion:^{
                                            self.navigationController.navigationBarHidden=NO;
                                        }];
                                        
                                    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [alertController addAction:LibraryAction];
    [self presentViewController:alertController animated:YES completion:nil];

}
#pragma mark -
#pragma mark UIImagePickerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    

    // 1 - Get media type
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    // 2 - Dismiss image picker
    [self dismissViewControllerAnimated:YES completion:^{
    }];
    // Handle a movie capture
    if (CFStringCompare ((__bridge_retained CFStringRef)mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo)
    {
        // 3 - Play the video
        
        originalFileUrl=[info objectForKey:UIImagePickerControllerMediaURL];
        originalImage=[self videoThumbnail:originalFileUrl fromsec:0.1];
        imageViewFiltered.image=originalImage;
        [imageViewFiltered layoutIfNeeded];
        [self playTheVideo:originalFileUrl];
        
        // 4 - Register for the playback finished notification
        
    }
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}




#pragma mark- GPUFilters
-(void)prepareAllFilter{
    
    filterNameArray=@[@"orignal",@"Sepia",@"Blur",@"Color Space",@"Color Invert",@"Sobel Edge",@"Emboss",@"Errosion",@"Exposure",@"Gamma",@"Laplacian",@"Luminance",@"Posterize",@"Prewitt Edge",@"Saturation"];
}
-(GPUImageOutput<GPUImageInput> *)filter:(NSInteger)indez
{
    GPUImageOutput<GPUImageInput> *filter;
    
    switch (indez)
    {
        case 1:
        {
            filter = [[GPUImageSepiaFilter alloc] init];
            break;
        }
            
        case 2:
        {
            filter = [[GPUImageBoxBlurFilter alloc] init];
            break;
        }
            
        case 3:
        {
            filter = [[GPUImageCGAColorspaceFilter alloc] init];
            break;
        }
            
        case 4:
        {
            filter = [[GPUImageColorInvertFilter alloc] init];
            break;
        }
        case 5:
        {
            filter = [[GPUImageDirectionalSobelEdgeDetectionFilter alloc] init];
            break;
        }
        case 6:
        {
            filter = [[GPUImageEmbossFilter alloc]init];
            ((GPUImageEmbossFilter *)filter).intensity = 2.5f;
            break;
        }
        case 7:
        {
            filter = [[GPUImageErosionFilter alloc]initWithRadius:0.2f];
            break;
        }
            
        case 8:
        {
            filter = [[GPUImageExposureFilter alloc]init];
            ((GPUImageExposureFilter *)filter).exposure = 1.5f;
            break;
        }
        case 9:
        {
            filter = [[GPUImageGammaFilter alloc]init];
            ((GPUImageGammaFilter *)filter).gamma = 2.5f;
            break;
        }
            
        case 10:
        {
            filter = [[GPUImageLaplacianFilter alloc]init];
            break;
        }
            
        case 11:
        {
            filter = [[GPUImageLuminanceRangeFilter alloc]init];
            ((GPUImageLuminanceRangeFilter *)filter).rangeReductionFactor = 5.0f;
            break;
        }
            
        case 12:
        {
            filter = [[GPUImagePosterizeFilter alloc]init];
            ((GPUImagePosterizeFilter *)filter).colorLevels = 4.0f;
            break;
        }
            
        case 13:
        {
            filter = [[GPUImagePrewittEdgeDetectionFilter alloc]init];
            break;
        }
            
        case 14:
        {
            filter = [[GPUImageSaturationFilter alloc]init];
            ((GPUImageSaturationFilter *)filter).saturation = 4.0f;
            break;
        }
            
        default:
            break;
    }
    
    return filter;
}

#pragma mark- processingVideo
-(void)applyFilterToVideo:(NSInteger)filterNumber{
    @autoreleasepool
    {
        self.showLoading=YES;
        _movieFile = [[GPUImageMovie alloc] initWithURL:originalFileUrl];
        
        self.videoFilter=[self filter:filterNumber];
        _movieFile.runBenchmark = YES;
        _movieFile.playAtActualSpeed = YES;
        [_movieFile addTarget:_videoFilter];
        
        //Setting path for temporary storing the video in document directory
        NSURL *movieURL = [self dataFilePath:@"tempVideo.mp4"];
        //getting 
        CGSize size =[self getVideoResolution:originalFileUrl];
        
        self.movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:size];
        
        [_videoFilter addTarget:_movieWriter];
        _movieWriter.shouldPassthroughAudio = YES;
        
        
        
        _movieFile.audioEncodingTarget = _movieWriter;
        
        [_movieFile enableSynchronizedEncodingUsingMovieWriter:_movieWriter];
        
        [self.movieWriter startRecording];
        [_movieFile startProcessing];
        
        __block BOOL completeRec = NO;
        __unsafe_unretained typeof(self) weakSelf = self;
        [self.movieWriter setCompletionBlock:^{
            
            [weakSelf.videoFilter removeTarget:weakSelf.movieWriter];
            [weakSelf.movieWriter finishRecording];
            [weakSelf.movieFile removeTarget:weakSelf.videoFilter];
            if (!completeRec)
            {
                [weakSelf performSelectorOnMainThread:@selector(playTheVideo:) withObject:movieURL waitUntilDone:NO];
                completeRec = YES;
            }
        }];
    }
}

-(CGSize)getVideoResolution:(NSURL *)fileURL{
    
    AVAssetTrack *videoTrack = nil;
    AVURLAsset *asset = [AVURLAsset assetWithURL:fileURL];
    NSArray *videoTracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    
    CMFormatDescriptionRef formatDescription = NULL;
    NSArray *formatDescriptions = [videoTrack formatDescriptions];
    if ([formatDescriptions count] > 0)
        formatDescription = (__bridge CMFormatDescriptionRef)[formatDescriptions objectAtIndex:0];
    
    if ([videoTracks count] > 0)
        videoTrack = [videoTracks objectAtIndex:0];
    
    CGSize trackDimensions = {
        .width = 0.0,
        .height = 0.0,
    };

    trackDimensions = [videoTrack naturalSize];
    return trackDimensions;
}


#pragma mark- UICollectionViewDatasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return filterNameArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"filterCell" forIndexPath:indexPath];
    UIImageView *imageView=[cell.contentView viewWithTag:1];
    UILabel *label=[cell.contentView viewWithTag:2];
    
    if (indexPath.row == 0){
        imageView.image = originalImage;
        label.text=@"original";
        return cell;
    }
    imageView.image=[[self filter:indexPath.row] imageByFilteringImage:originalImage];
    label.text=filterNameArray[indexPath.row];
    
    return cell;
    
}

#pragma mark- UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0){ //if is original selected we'll delete the previous
        imageViewFiltered.image = originalImage;
        [self playTheVideo:originalFileUrl];
        return;
    }
    imageViewFiltered.image = [[self filter:indexPath.row] imageByFilteringImage:originalImage];
    
    [self applyFilterToVideo:indexPath.item];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
@end

#pragma mark- Category

@implementation UIViewController (filter)
-(void) setShowLoading:(BOOL)showLoading
{
    if (showLoading) {
        [((AppDelegate*)[UIApplication sharedApplication].delegate) ShowLoading];
    }else{
        [((AppDelegate*)[UIApplication sharedApplication].delegate) HideLoading];

    }
    
}
-(BOOL)showLoading{
    return self.showLoading;
}

@end