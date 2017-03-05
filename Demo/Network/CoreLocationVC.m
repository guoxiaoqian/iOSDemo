//
//  CoreLocationVC.m
//  Demo
//
//  Created by 郭晓倩 on 2017/3/5.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import "CoreLocationVC.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface CoreLocationVC () <CLLocationManagerDelegate,MKMapViewDelegate>

@property (strong,nonatomic) CLLocationManager* locationManager;
@property (assign,nonatomic) BOOL allowBackgroundLocate;
@property (assign,nonatomic) BOOL onlyLocateOnce;


@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation CoreLocationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self startUpdatingLocation];
    
    [self initMapView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(CLLocationManager*)locationManager{
    if (_locationManager == nil) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = 100;
        _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
            [_locationManager requestWhenInUseAuthorization];
            
            if (self.allowBackgroundLocate) {
                [_locationManager requestAlwaysAuthorization];
            }
        }
        if ([UIDevice currentDevice].systemVersion.floatValue >= 9.0) {
            if (self.allowBackgroundLocate) {
                _locationManager.allowsBackgroundLocationUpdates = YES;
            }
        }
    }
    return _locationManager;
}

-(void)startUpdatingLocation{
    [self.locationManager startUpdatingLocation];
}

-(void)stopUpdatingLocation{
    [self.locationManager stopUpdatingLocation];
}

- (BOOL)isLocationServiceEnabled{
#if TARGET_IPHONE_SIMULATOR
    NSLog(@"定位服务.模拟器环境下定位不可用");
    return NO;
#else
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied
        || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted){
        NSLog(@"定位服务.未开启定位服务");
        return NO;
    }
    return YES;
#endif
}

#pragma mark - CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"定位失败 error = %@",error);
    
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    CLLocation* currentLocation = [locations lastObject];
    if (currentLocation) {
        
        CLGeocoder* geoCoder = [[CLGeocoder alloc] init];
        [geoCoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
            CLPlacemark* placeMark = [placemarks lastObject];
            if (placeMark) {
                NSString* city = placeMark.locality;
                if (!city) {
                    city = placeMark.administrativeArea; //直辖市
                }
                NSLog(@"逆编码成功 city = %@ placeMark= %@",city,placeMark);
            }else if(error){
                NSLog(@"逆编码错误 error=%@",error);
            }else {
                NSLog(@"逆编码结果为空");
            }
        }];
        
        NSLog(@"定位成功 location = %@",currentLocation);
    }else{
        NSLog(@"定位结果为空");
    }
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    switch (status) {
            // 用户还未决定
        case kCLAuthorizationStatusNotDetermined:
        {
            NSLog(@"用户还未决定");
            break;
        }
            // 问受限
        case kCLAuthorizationStatusRestricted:
        {
            NSLog(@"访问受限");
            break;
        }
            // 定位关闭时和对此APP授权为never时调用
        case kCLAuthorizationStatusDenied:
        {
            // 定位是否可用（是否支持定位或者定位是否开启）
            if([CLLocationManager locationServicesEnabled])
            {
                NSLog(@"定位开启，但被拒");
            }else
            {
                NSLog(@"定位关闭，不可用");
            }
            break;
        }
            // 获取前后台定位授权
        case kCLAuthorizationStatusAuthorizedAlways:
            // case kCLAuthorizationStatusAuthorized: // 失效，不建议使用
        {
            NSLog(@"获取前后台定位授权");
            break;
        }
            // 获得前台定位授权
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        {
            NSLog(@"获得前台定位授权");
            break;
        }
        default:
            break;
    }
}

#pragma mark - MKMapView

-(void)initMapView{
    self.mapView.userTrackingMode = MKUserTrackingModeNone;
    self.mapView.mapType = MKMapTypeStandard;
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    self.mapView.showsScale = YES;
    self.mapView.showsCompass = YES;
    self.mapView.showsBuildings = YES;
    if ([self.mapView respondsToSelector:@selector(setShowsTraffic:)]) {
        self.mapView.showsTraffic = YES;
    }
    
    //    //北京市市中心经纬度:(116.41667,39.91667)
    //    //上海市区经纬度:(121.43333,34.50000)
    //    //广州经纬度:(113.23333,23.16667)
    float latitude = 39.5;
    float longitude = 116;
    CLLocation *location= [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    MKPointAnnotation* annotation = [MKPointAnnotation new];
    annotation.coordinate = location.coordinate;
    [self.mapView addAnnotation:annotation];
    
    self.mapView.centerCoordinate = location.coordinate;
}

#pragma mark MKMapViewDelegate

-(void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error{
    NSLog(@"加载地图失败,ERROR %@",error);
}

-(void)mapViewDidFinishLoadingMap:(MKMapView *)mapView{
    NSLog(@"加载地图成功");
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    if ([annotation isKindOfClass:[MKPointAnnotation class]]) {
        
        MKPinAnnotationView* view = (MKPinAnnotationView* )[mapView dequeueReusableAnnotationViewWithIdentifier:@"pin"];
        if (!view) {
            view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pin"];
            view.pinTintColor = [UIColor blueColor];
        }
        return view;
    }
    return nil;
}

@end
