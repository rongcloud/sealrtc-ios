//
//  STCountryTableViewController.m
//  SealRTC
//
//  Created by birney on 2019/4/2.
//  Copyright © 2019 BridgeMind. All rights reserved.
//

#import "STCountryTableViewController.h"
#import "RCDCountry.h"
#import "RCCCpinyin.h"

@interface STCountryTableViewController ()

@property(nonatomic, strong) NSMutableArray *countryArray;
@property(nonatomic, strong) NSMutableArray *searchListArry;

@property(nonatomic, strong) NSMutableDictionary *resultDic;
@property(nonatomic, strong) NSMutableDictionary *searchResultDic;
@property(nonatomic, strong) NSDictionary *allCountryDic;
@property(nonatomic, strong) NSDictionary *allSearchCountryDic;
@end

@implementation STCountryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.title = NSLocalizedString(@"select_country", nil);
    //[self.navigationController setNavigationBarHidden:NO animated:YES];
    [self configCountryData];
    //设置右侧索引
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.tableView.sectionIndexColor = [UIColor redColor];
    // 添加 searchbar 到 headerview
    self.definesPresentationContext = YES;
    //self.tableView.tableHeaderView = self.searchController.searchBar;
    [self.tableView setTableFooterView:[UIView new]];
    self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
}

- (void)configCountryData {
    self.countryArray = [[NSMutableArray alloc] init];
    self.allCountryDic = [[NSDictionary alloc] init];
    self.allSearchCountryDic = [[NSDictionary alloc] init];
    __weak typeof(self) weakSelf = self;
    NSURL* urlPost = [NSURL URLWithString:@"http://api.sealtalk.im/user/regionlist"];
    NSMutableURLRequest *request  = [NSMutableURLRequest requestWithURL:urlPost];
    request.HTTPMethod = @"GET";

    NSURLSession* session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];

    [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {

        }
        else{
            NSDictionary* responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSDictionary* result = responseObject[@"result"];
            for (NSDictionary *regionJson in result) {
                RCDCountry *country = [[RCDCountry alloc] initWithDict:regionJson];
                [weakSelf.countryArray addObject:country];
            }
            weakSelf.resultDic = [weakSelf sortedArrayWithPinYinDic:self.countryArray];
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.allCountryDic = weakSelf.resultDic[@"infoDic"];
                [weakSelf.tableView reloadData];
            });
            //NSString* token = result[@"token"];
        }

    }] resume];
//    [AFHttpTool getRegionlist:^(id response) {
//        if([response[@"code"] intValue] == 200){
//            NSDictionary *dic = response[@"result"];
//            for (NSDictionary *regionJson in dic) {
//                RCDCountry *country = [[RCDCountry alloc] initWithDict:regionJson];
//                [weakSelf.countryArray addObject:country];
//            }
//            weakSelf.resultDic = [weakSelf sortedArrayWithPinYinDic:self.countryArray];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                weakSelf.allCountryDic = weakSelf.resultDic[@"infoDic"];
//                [weakSelf.tableView reloadData];
//            });
//        }
//    } failure:^(NSError *err) {
//        
//    }];
}


- (NSArray *)sectionCountryTitles {
        return self.resultDic[@"allKeys"];

}

- (NSArray *)countriesInSection:(NSInteger)section {
    NSString *letter = [self sectionCountryTitles][section];
    
    NSArray *countries;

    countries = self.allCountryDic[letter];

    return countries;
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55.5;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [self sectionCountryTitles];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 21.f;
}


- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.frame = CGRectMake(0, 0, self.view.frame.size.width, 19);
    //view.backgroundColor = HEXCOLOR(0xF5F5F5);
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectZero];
    title.frame = CGRectMake(13, 3, 15, 15);
    title.font = [UIFont systemFontOfSize:15.f];
    //title.textColor = HEXCOLOR(0x808080);
    [view addSubview:title];
    
    NSArray *sectionTitles = [self sectionCountryTitles];
    title.text = sectionTitles[section];
    
    return view;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self sectionCountryTitles].count;;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
     return [self countriesInSection:section].count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *flag = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:flag];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:flag];
    }
    
    NSArray *sectionUserInfoList = [self countriesInSection:indexPath.section];
    
    RCDCountry *countryInfo = sectionUserInfoList[indexPath.row];
    if (countryInfo) {
        [cell.textLabel setText:countryInfo.countryName];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"+%@",countryInfo.phoneCode];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *sectionUserInfoList = [self countriesInSection:indexPath.section];
    RCDCountry *countryInfo = sectionUserInfoList[indexPath.row];
    
    if ([self.delegate respondsToSelector:@selector(fetchCountryPhoneCode:)]) {
        //[[NSUserDefaults standardUserDefaults] setObject:[countryInfo getModelJson] forKey:@"currentCountry"];
        [self.delegate fetchCountryPhoneCode:countryInfo];
    }
    [self.navigationController popViewControllerAnimated:NO];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

BOOL isChinese(NSString * text) {
    NSString *match = @"(^[\u4e00-\u9fa5]+$)";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];
    return [predicate evaluateWithObject:text];
}

NSString * hanZiToPinYinWithString(NSString *hanZi) {
    if (!hanZi) {
        return nil;
    }
    NSString *pinYinResult = [NSString string];
    for (int j = 0; j < hanZi.length; j++) {
        NSString *singlePinyinLetter = nil;
        if (isChinese([hanZi substringWithRange:NSMakeRange(j, 1)])) {
            singlePinyinLetter =
            [[NSString stringWithFormat:@"%c", pinyinFirstLetter([hanZi characterAtIndex:j])] uppercaseString];
        } else {
            singlePinyinLetter = [hanZi substringWithRange:NSMakeRange(j, 1)];
        }

        pinYinResult = [pinYinResult stringByAppendingString:singlePinyinLetter];
    }
    return pinYinResult;
}

NSString * getFirstUpperLetter(NSString *hanzi) {
    NSString *pinyin =  hanZiToPinYinWithString(hanzi);
    NSString *firstUpperLetter = [[pinyin substringToIndex:1] uppercaseString];
    if ([firstUpperLetter compare:@"A"] != NSOrderedAscending &&
        [firstUpperLetter compare:@"Z"] != NSOrderedDescending) {
        return firstUpperLetter;
    } else {
        return @"#";
    }
}


- (NSMutableDictionary *)sortedArrayWithPinYinDic:(NSArray *)countryList {
    if (!countryList)
        return nil;
    NSArray *_keys = @[
                       @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N",
                       @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", @"#"
                       ];
    NSMutableArray *mutableList = [countryList mutableCopy];

    NSMutableDictionary *infoDic = [NSMutableDictionary new];

    for (RCDCountry *model in mutableList) {
        NSString *firstLetter;
        if (model.countryName.length > 0 && ![model.countryName isEqualToString:@""]) {
            firstLetter = getFirstUpperLetter(model.countryName);
        } else {
            firstLetter = getFirstUpperLetter(model.countryName);
        }
        if ([_keys containsObject:firstLetter]) {
            NSMutableArray *array = infoDic[firstLetter];
            if (array) {
                [array addObject:model];
                [infoDic setObject:array forKey:firstLetter];
            }else{
                [infoDic setObject:@[model].mutableCopy forKey:firstLetter];
            }
        }else{
            NSMutableArray *array = infoDic[@"#"];
            if (array) {
                [array addObject:model];
                [infoDic setObject:array forKey:@"#"];
            }else{
                [infoDic setObject:@[model].mutableCopy forKey:@"#"];
            }
        }
    }
    NSArray *keys = [[infoDic allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    NSMutableArray *allKeys = [[NSMutableArray alloc] initWithArray:keys];

    NSMutableDictionary *resultDic = [NSMutableDictionary new];
    [resultDic setObject:infoDic forKey:@"infoDic"];
    [resultDic setObject:allKeys forKey:@"allKeys"];
    return resultDic;
}

@end
