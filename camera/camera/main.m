//
//  main.m
//  camera
//
//  Created by Cody Thomas on 5/19/21.
//
// mostly pulled from https://guides.codepath.com/ios/Creating-a-Custom-Camera-View
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface MyCapture : NSObject <AVCapturePhotoCaptureDelegate>
// ...
@end
@implementation MyCapture
- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(nullable NSError *)error {
    //printf("called MyCapture delegate\n");
    NSData *imageData = photo.fileDataRepresentation;
    if (imageData) {
        //printf("writing data to file\n");
        NSDate * now = [NSDate date];
        NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
        [outputFormatter setDateFormat:@"YYYY:MM:DD:HH:mm:ss"];
        NSString *newDateString = [outputFormatter stringFromDate:now];
        NSString *filename = [newDateString stringByAppendingString:@".jpg"];
        [imageData writeToFile:filename atomically:true];
    }else {
        //printf("No image data\n");
    }
}
- (void)captureOutput:(AVCapturePhotoOutput *)output willBeginCaptureForResolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings {
    //printf("delegate - capture output has resolved settings and will soon begin its capture process\n");
}
- (void)captureOutput:(AVCapturePhotoOutput *)output willCapturePhotoForResolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings{
    //printf("delegate - photo capture is about to occur\n");
}
- (void)captureOutput:(AVCapturePhotoOutput *)output didCapturePhotoForResolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings {
    //printf("delegate - photo has been taken\n");
}
- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishCaptureForResolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings
                error:(NSError *)error {
   // printf("delegate - capture process is complete\n");
}
@end

int main(int argc, const char * argv[]) {
    
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    NSError *error;
    for(int i = 0; i < [devices count]; i++){
        AVCaptureSession *captureSession = [AVCaptureSession new];
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:[devices objectAtIndex:i] error:&error];
        if (!error) {
            AVCapturePhotoOutput *stillImageOutput = [AVCapturePhotoOutput new];
            if ([captureSession canAddInput:input] && [captureSession canAddOutput:stillImageOutput]){
                [captureSession beginConfiguration];
                captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
                [captureSession addInput:input];
                [captureSession addOutput:stillImageOutput];
                [captureSession commitConfiguration];
                AVCapturePhotoSettings *settings = [AVCapturePhotoSettings photoSettingsWithFormat:@{AVVideoCodecKey: AVVideoCodecTypeJPEG}];
                MyCapture *getMyPhoto = [[MyCapture alloc] init];
                [captureSession startRunning];
                [[NSRunLoop currentRunLoop] runUntilDate:[[[NSDate alloc] init] dateByAddingTimeInterval: 5]];
                [stillImageOutput capturePhotoWithSettings:settings delegate:getMyPhoto];
                [[NSRunLoop currentRunLoop] runUntilDate:[[[NSDate alloc] init] dateByAddingTimeInterval: 5]];
                [captureSession stopRunning];
            }else{
                printf("can't add input or can't add output");
            }
        }
        else {
            printf("Error Unable to initialize back camera: %s", error.localizedDescription.UTF8String);
        }
    }
    return 0;
}
