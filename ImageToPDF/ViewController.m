//
//  ViewController.m
//  ImageToPDF
//
//  Created by 柳玉峰 on 2019/5/6.
//  Copyright © 2019 柳玉峰. All rights reserved.
//

#import "ViewController.h"
#import "CollectionViewCell.h"
@interface ViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) NSMutableArray * images;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_collectionView registerNib:[UINib nibWithNibName:@"CollectionViewCell" bundle:nil]
      forCellWithReuseIdentifier:@"CollectionViewCellID"];
    
    UIBarButtonItem * item = [[UIBarButtonItem alloc]initWithTitle:@"share" style:UIBarButtonItemStylePlain target:self action:@selector(shareClick)];
    item.tintColor = [UIColor darkGrayColor];
    self.navigationItem.rightBarButtonItem = item;
}


#pragma mark ========================================Click=====================================


#pragma mark - 创建PDF

- (NSString *)createPDF {
    NSString * pdfPath = [self createPDFPathWithName:@"test.pdf"];
 
    // CGRectZero 表示默认尺寸，参数可修改，设置自己需要的尺寸
    UIGraphicsBeginPDFContextToFile(pdfPath, CGRectZero, NULL);
    
    CGRect  pdfBounds = UIGraphicsGetPDFContextBounds();
    CGFloat pdfWidth  = pdfBounds.size.width;
    CGFloat pdfHeight = pdfBounds.size.height;
    
    [self.images enumerateObjectsUsingBlock:^(UIImage * _Nonnull image, NSUInteger idx, BOOL * _Nonnull stop) {
        // 绘制PDF
        UIGraphicsBeginPDFPage();
        
        CGFloat imageW = image.size.width;
        CGFloat imageH = image.size.height;
        
        if (imageW <= pdfWidth && imageH <= pdfHeight)
        {
            CGFloat originX = (pdfWidth - imageW) / 2;
            CGFloat originY = (pdfHeight - imageH) / 2;
            [image drawInRect:CGRectMake(originX, originY, imageW, imageH)];
        }
        else
        {
            CGFloat width,height;

            if ((imageW / imageH) > (pdfWidth / pdfHeight))
            {
                width  = pdfWidth;
                height = width * imageH / imageW;
            }
            else
            {
                height = pdfHeight;
                width = height * imageW / imageH;
            }
            [image drawInRect:CGRectMake((pdfWidth - width) / 2, (pdfHeight - height) / 2, width, height)];
        }
    }];
    
    UIGraphicsEndPDFContext();

    
    return pdfPath;
}

#pragma mark - 创建PDF储存路径

- (NSString *)createPDFPathWithName:(NSString *)pdfName {
    NSFileManager * fileManager = [NSFileManager defaultManager];

    NSString * finderPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                                  NSUserDomainMask, YES) lastObject]
                             stringByAppendingPathComponent:@"PDF"];
    
    if (![fileManager fileExistsAtPath:finderPath])
    {
        [fileManager createDirectoryAtPath:finderPath withIntermediateDirectories:YES
                                attributes:nil
                                     error:NULL];
    }
    return [finderPath stringByAppendingPathComponent:pdfName];
}

#pragma mark - 分享

- (void)shareClick {
    NSString * path = [self createPDF];
    
    NSURL *  file = [NSURL fileURLWithPath:path];
    NSData * data = [NSData dataWithContentsOfFile:path];
    
    UIActivityViewController * activity = [[UIActivityViewController alloc]initWithActivityItems:@[data,file]
                                                                           applicationActivities:nil];
    [self presentViewController:activity animated:YES completion:nil];
    
}


#pragma mark ========================================Delegate=====================================

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.collectionView.frame.size.height * 0.56, self.collectionView.frame.size.height);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.f;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionViewCellID"
                                                                          forIndexPath:indexPath];
    dispatch_async(dispatch_get_main_queue(), ^{
        [cell.imageVIew setImage:self.images[indexPath.row]];
    });
    return cell;
}

#pragma mark ========================================Set=====================================


- (NSMutableArray *)images {
    if (!_images)
    {
        _images = [NSMutableArray array];
        for (int i = 1; i <= 3; i++)
        {
            NSString * imageName = [NSString stringWithFormat:@"img_index_%02dbg",i];
            NSString * path = [[NSBundle mainBundle] pathForResource:imageName ofType:@"png"];
            UIImage * image = [UIImage imageWithContentsOfFile:path];
            [self.images addObject:image];
        }
    }
    return _images;
}
@end
