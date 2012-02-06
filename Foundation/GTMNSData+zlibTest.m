//
//  GTMNSData+zlibTest.m
//
//  Copyright 2007-2008 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not
//  use this file except in compliance with the License.  You may obtain a copy
//  of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
//  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
//  License for the specific language governing permissions and limitations under
//  the License.
//

#import "GTMSenTestCase.h"
#import "GTMUnitTestDevLog.h"
#import "GTMNSData+zlib.h"
#import <stdlib.h> // for randiom/srandomdev
#import <zlib.h>

@interface GTMNSData_zlibTest : GTMTestCase
@end

// NOTE: we don't need to test the actually compressor/inflation (we're using
// zlib, it works), we just need to test our wrapper.  So we can use canned
// data, etc. (and yes, when using random data, things once failed because
// we generated a random block of data that was valid compressed data?!)

static unsigned char randomDataLarge[] = {
  // openssl rand -rand /dev/random 512 | xxd -i
  0xe1, 0xa6, 0xe2, 0xa2, 0x0b, 0xf7, 0x8d, 0x6b, 0x31, 0xfe, 0xaa, 0x64,
  0x50, 0xbe, 0x52, 0x7e, 0x83, 0x74, 0x00, 0x8f, 0x62, 0x96, 0xc7, 0xe9,
  0x20, 0x59, 0x78, 0xc6, 0xea, 0x10, 0xd5, 0xdb, 0x3f, 0x6b, 0x13, 0xd9,
  0x44, 0x18, 0x24, 0x17, 0x63, 0xc8, 0x74, 0xa5, 0x37, 0x6c, 0x9c, 0x00,
  0xe5, 0xcf, 0x0a, 0xdf, 0xb9, 0x66, 0xb1, 0xbd, 0x04, 0x8f, 0x55, 0x9e,
  0xb0, 0x24, 0x4e, 0xf0, 0xc4, 0x69, 0x2c, 0x1f, 0x63, 0x9f, 0x41, 0xa8,
  0x89, 0x9b, 0x98, 0x00, 0xb6, 0x78, 0xf7, 0xe4, 0x4c, 0x72, 0x14, 0x84,
  0xaa, 0x3d, 0xc1, 0x42, 0x9f, 0x12, 0x85, 0xdd, 0x16, 0x8b, 0x8f, 0x67,
  0xe0, 0x26, 0x5b, 0x5e, 0xaa, 0xe7, 0xd3, 0x67, 0xfe, 0x21, 0x77, 0xa6,
  0x52, 0xde, 0x33, 0x8b, 0x96, 0x49, 0x6a, 0xd6, 0x58, 0x58, 0x36, 0x00,
  0x23, 0xd2, 0x45, 0x13, 0x9f, 0xd9, 0xc7, 0x2d, 0x55, 0x12, 0xb4, 0xfe,
  0x53, 0x27, 0x1f, 0x14, 0x71, 0x9b, 0x7e, 0xcc, 0x5e, 0x8c, 0x59, 0xef,
  0x80, 0xac, 0x89, 0xf4, 0x45, 0x8d, 0x98, 0x6d, 0x97, 0xfd, 0x53, 0x5f,
  0x19, 0xd6, 0x11, 0xf7, 0xcb, 0x5d, 0xca, 0xab, 0xe1, 0x01, 0xf1, 0xe9,
  0x1f, 0x1f, 0xf3, 0x53, 0x76, 0xa2, 0x59, 0x8e, 0xb3, 0x91, 0xff, 0xe8,
  0x1b, 0xc0, 0xc0, 0xda, 0xdd, 0x93, 0xb5, 0x9d, 0x62, 0x13, 0xb8, 0x07,
  0xf2, 0xf5, 0xb9, 0x4b, 0xe1, 0x09, 0xed, 0xdb, 0xe6, 0xd9, 0x2d, 0xc4,
  0x0d, 0xb6, 0xbd, 0xfc, 0xdb, 0x5c, 0xcc, 0xf6, 0x53, 0x4e, 0x01, 0xa4,
  0x03, 0x95, 0x4a, 0xa4, 0xaa, 0x4f, 0x45, 0xaf, 0xbf, 0xf1, 0x7e, 0x60,
  0x1d, 0x86, 0x93, 0x65, 0x7b, 0x24, 0x0c, 0x09, 0xe0, 0xd1, 0xd8, 0x60,
  0xd9, 0xd9, 0x55, 0x2a, 0xec, 0xd5, 0xdc, 0xd0, 0xc6, 0x5e, 0x2c, 0x22,
  0xf5, 0x19, 0x0b, 0xc3, 0xa1, 0x38, 0x11, 0x67, 0x6f, 0x6c, 0x0e, 0x34,
  0x44, 0x83, 0xee, 0xd3, 0xf2, 0x4b, 0x7b, 0x03, 0x68, 0xfe, 0xc5, 0x76,
  0xb2, 0x2e, 0x26, 0xeb, 0x1f, 0x66, 0x02, 0xa4, 0xd9, 0xda, 0x28, 0x3a,
  0xc3, 0x94, 0x03, 0xe8, 0x29, 0x7e, 0xfe, 0x3d, 0xc8, 0xc1, 0x0a, 0x74,
  0xc7, 0xaf, 0xa6, 0x84, 0x86, 0x85, 0xc3, 0x8c, 0x00, 0x38, 0xd4, 0xb5,
  0xb2, 0xe0, 0xf0, 0xc4, 0x8d, 0x10, 0x0d, 0xf1, 0xcd, 0x05, 0xdb, 0xd0,
  0xcf, 0x17, 0x4f, 0xa8, 0xe5, 0xf0, 0x53, 0x55, 0x62, 0xc7, 0x55, 0xe5,
  0xbe, 0x18, 0x2f, 0xda, 0x48, 0xf1, 0xaa, 0x85, 0x46, 0x80, 0x15, 0x70,
  0x82, 0xd2, 0xa6, 0xb0, 0x3d, 0x31, 0xb5, 0xcc, 0x23, 0x95, 0x5e, 0x15,
  0x35, 0x32, 0xd0, 0x86, 0xd1, 0x6e, 0x2d, 0xc0, 0xfe, 0x45, 0xae, 0x28,
  0x24, 0xa7, 0x14, 0xf4, 0xe9, 0xb5, 0x6f, 0xac, 0x25, 0xf9, 0x88, 0xf6,
  0x60, 0x5d, 0x6b, 0x5c, 0xf2, 0x38, 0xe8, 0xdc, 0xbd, 0xa6, 0x13, 0xc0,
  0xa4, 0xc8, 0xe9, 0x7a, 0xc6, 0xb6, 0x88, 0x26, 0x98, 0x9f, 0xe3, 0x9a,
  0xd9, 0x5b, 0xd4, 0xd0, 0x02, 0x1f, 0x55, 0x30, 0xbe, 0xde, 0x9c, 0xd1,
  0x53, 0x93, 0x72, 0xe6, 0x19, 0x79, 0xe9, 0xf1, 0x70, 0x78, 0x92, 0x31,
  0xf6, 0x17, 0xc0, 0xdd, 0x99, 0xc8, 0x97, 0x67, 0xdc, 0xf6, 0x67, 0x6b,
  0x9b, 0x1c, 0x90, 0xea, 0x1a, 0x9e, 0x26, 0x68, 0xc2, 0x13, 0x94, 0x3a,
  0x3e, 0x73, 0x61, 0x4e, 0x37, 0xa8, 0xa1, 0xfa, 0xf8, 0x22, 0xdd, 0x20,
  0x40, 0xc6, 0x52, 0x27, 0x47, 0x1a, 0x79, 0xfa, 0x40, 0xa6, 0x62, 0x6b,
  0xe6, 0xc7, 0x67, 0xb7, 0xa8, 0x2d, 0xd1, 0x9f, 0x17, 0xb8, 0x77, 0x5e,
  0x97, 0x1e, 0x92, 0xd7, 0xd2, 0x25, 0x04, 0x92, 0xf9, 0x41, 0x70, 0x93,
  0xe1, 0x13, 0x07, 0x94, 0x8e, 0x0b, 0x82, 0x98
};

static unsigned char randomDataSmall[] = {
  // openssl rand -rand /dev/random 24 | xxd -i
  0xd1, 0xec, 0x35, 0xc3, 0xa0, 0x4c, 0x73, 0x37, 0x2f, 0x5a, 0x12, 0x44,
  0xee, 0xe4, 0x22, 0x07, 0x29, 0xa8, 0x4a, 0xde, 0xc8, 0xbb, 0xe7, 0xdb
};


static BOOL HasGzipHeader(NSData *data) {
  // very simple check
  const unsigned char *bytes = [data bytes];
  return ([data length] > 2) &&
         ((bytes[0] == 0x1f) && (bytes[1] == 0x8b));
}


@implementation GTMNSData_zlibTest

- (void)testBoundryValues {
  // build some test data
  NSData *data = [NSData dataWithBytes:randomDataLarge
                                length:sizeof(randomDataLarge)];
  STAssertNotNil(data, @"failed to alloc data block");

  // bogus args to start
  STAssertNil([NSData gtm_dataByDeflatingData:nil], nil);
  STAssertNil([NSData gtm_dataByDeflatingBytes:nil length:666], nil);
  STAssertNil([NSData gtm_dataByDeflatingBytes:[data bytes] length:0], nil);
  STAssertNil([NSData gtm_dataByGzippingData:nil], nil);
  STAssertNil([NSData gtm_dataByGzippingBytes:nil length:666], nil);
  STAssertNil([NSData gtm_dataByGzippingBytes:[data bytes] length:0], nil);
  STAssertNil([NSData gtm_dataByInflatingData:nil], nil);
  STAssertNil([NSData gtm_dataByInflatingBytes:nil length:666], nil);
  STAssertNil([NSData gtm_dataByInflatingBytes:[data bytes] length:0], nil);

  // test deflate w/ compression levels out of range
  NSData *deflated = [NSData gtm_dataByDeflatingData:data
                                    compressionLevel:-4];
  STAssertNotNil(deflated, nil);
  STAssertFalse(HasGzipHeader(deflated), nil);
  NSData *dataPrime = [NSData gtm_dataByInflatingData:deflated];
  STAssertNotNil(dataPrime, nil);
  STAssertEqualObjects(data, dataPrime, nil);
  deflated = [NSData gtm_dataByDeflatingData:data
                             compressionLevel:20];
  STAssertNotNil(deflated, nil);
  STAssertFalse(HasGzipHeader(deflated), nil);
  dataPrime = [NSData gtm_dataByInflatingData:deflated];
  STAssertNotNil(dataPrime, nil);
  STAssertEqualObjects(data, dataPrime, nil);

  // test gzip w/ compression levels out of range
  NSData *gzipped = [NSData gtm_dataByGzippingData:data
                                   compressionLevel:-4];
  STAssertNotNil(gzipped, nil);
  STAssertTrue(HasGzipHeader(gzipped), nil);
  dataPrime = [NSData gtm_dataByInflatingData:gzipped];
  STAssertNotNil(dataPrime, nil);
  STAssertEqualObjects(data, dataPrime, nil);
  gzipped = [NSData gtm_dataByGzippingData:data
                           compressionLevel:20];
  STAssertNotNil(gzipped, nil);
  STAssertTrue(HasGzipHeader(gzipped), nil);
  dataPrime = [NSData gtm_dataByInflatingData:gzipped];
  STAssertNotNil(dataPrime, nil);
  STAssertEqualObjects(data, dataPrime, nil);

  // test non-compressed data data itself
  [GTMUnitTestDevLog expectString:@"Error trying to inflate some of the "
   "payload, error -3"];
  STAssertNil([NSData gtm_dataByInflatingData:data], nil);

  // test deflated data runs that end before they are done
  [GTMUnitTestDevLog expect:([deflated length] / 11) + 1
              casesOfString:@"Error trying to inflate some of the payload, "
   "error -5"];
  for (NSUInteger x = 1 ; x < [deflated length] ; x += 11) {
    STAssertNil([NSData gtm_dataByInflatingBytes:[deflated bytes]
                                          length:x], nil);
  }

  // test gzipped data runs that end before they are done
  [GTMUnitTestDevLog expect:([gzipped length] / 11) + 1
              casesOfString:@"Error trying to inflate some of the payload, "
   "error -5"];
  for (NSUInteger x = 1 ; x < [gzipped length] ; x += 11) {
    STAssertNil([NSData gtm_dataByInflatingBytes:[gzipped bytes]
                                          length:x], nil);
  }

  // test extra data before the deflated/gzipped data (just to make sure we
  // don't seek to the "real" data)
  NSMutableData *prefixedDeflated =
    [NSMutableData dataWithBytes:randomDataSmall length:sizeof(randomDataSmall)];
  STAssertNotNil(prefixedDeflated, @"failed to alloc data block");
  [prefixedDeflated appendData:deflated];
  [GTMUnitTestDevLog expectString:@"Error trying to inflate some of the "
   "payload, error -3"];
  STAssertNil([NSData gtm_dataByInflatingData:prefixedDeflated], nil);
  [GTMUnitTestDevLog expectString:@"Error trying to inflate some of the "
   "payload, error -3"];
  STAssertNil([NSData gtm_dataByInflatingBytes:[prefixedDeflated bytes]
                                        length:[prefixedDeflated length]],
              nil);
  NSMutableData *prefixedGzipped =
    [NSMutableData dataWithBytes:randomDataSmall length:sizeof(randomDataSmall)];
  STAssertNotNil(prefixedDeflated, @"failed to alloc data block");
  [prefixedGzipped appendData:gzipped];
  [GTMUnitTestDevLog expectString:@"Error trying to inflate some of the "
   "payload, error -3"];
  STAssertNil([NSData gtm_dataByInflatingData:prefixedGzipped], nil);
  [GTMUnitTestDevLog expectString:@"Error trying to inflate some of the "
   "payload, error -3"];
  STAssertNil([NSData gtm_dataByInflatingBytes:[prefixedGzipped bytes]
                                        length:[prefixedGzipped length]],
              nil);

  // test extra data after the deflated/gzipped data (just to make sure we
  // don't ignore some of the data)
  NSMutableData *suffixedDeflated = [NSMutableData data];
  STAssertNotNil(suffixedDeflated, @"failed to alloc data block");
  [suffixedDeflated appendData:deflated];
  [suffixedDeflated appendBytes:[data bytes] length:20];
  [GTMUnitTestDevLog expectString:@"thought we finished inflate w/o using "
   "all input, 20 bytes left"];
  STAssertNil([NSData gtm_dataByInflatingData:suffixedDeflated], nil);
  [GTMUnitTestDevLog expectString:@"thought we finished inflate w/o using "
   "all input, 20 bytes left"];
  STAssertNil([NSData gtm_dataByInflatingBytes:[suffixedDeflated bytes]
                                        length:[suffixedDeflated length]],
              nil);
  NSMutableData *suffixedGZipped = [NSMutableData data];
  STAssertNotNil(suffixedGZipped, @"failed to alloc data block");
  [suffixedGZipped appendData:gzipped];
  [suffixedGZipped appendBytes:[data bytes] length:20];
  [GTMUnitTestDevLog expectString:@"thought we finished inflate w/o using "
   "all input, 20 bytes left"];
  STAssertNil([NSData gtm_dataByInflatingData:suffixedGZipped], nil);
  [GTMUnitTestDevLog expectString:@"thought we finished inflate w/o using "
   "all input, 20 bytes left"];
  STAssertNil([NSData gtm_dataByInflatingBytes:[suffixedGZipped bytes]
                                        length:[suffixedGZipped length]],
              nil);
}

- (void)testInflateDeflate {
  NSData *data = [NSData dataWithBytes:randomDataLarge
                                length:sizeof(randomDataLarge)];
  STAssertNotNil(data, @"failed to alloc data block");

  // w/ *Bytes apis, default level
  NSData *deflated = [NSData gtm_dataByDeflatingBytes:[data bytes]
                                               length:[data length]];
  STAssertNotNil(deflated, @"failed to deflate data block");
  STAssertGreaterThan([deflated length],
                      (NSUInteger)0, @"failed to deflate data block");
  STAssertFalse(HasGzipHeader(deflated), @"has gzip header on zlib data");
  NSData *dataPrime = [NSData gtm_dataByInflatingBytes:[deflated bytes]
                                                length:[deflated length]];
  STAssertNotNil(dataPrime, @"failed to inflate data block");
  STAssertGreaterThan([dataPrime length],
                      (NSUInteger)0, @"failed to inflate data block");
  STAssertEqualObjects(data,
                       dataPrime, @"failed to round trip via *Bytes apis");

  // w/ *Data apis, default level
  deflated = [NSData gtm_dataByDeflatingData:data];
  STAssertNotNil(deflated, @"failed to deflate data block");
  STAssertGreaterThan([deflated length],
                      (NSUInteger)0, @"failed to deflate data block");
  STAssertFalse(HasGzipHeader(deflated), @"has gzip header on zlib data");
  dataPrime = [NSData gtm_dataByInflatingData:deflated];
  STAssertNotNil(dataPrime, @"failed to inflate data block");
  STAssertGreaterThan([dataPrime length],
                      (NSUInteger)0, @"failed to inflate data block");
  STAssertEqualObjects(data,
                       dataPrime, @"failed to round trip via *Data apis");

  // loop over the compression levels
  for (int level = 1 ; level < 9 ; ++level) {
    // w/ *Bytes apis, using our level
    deflated = [NSData gtm_dataByDeflatingBytes:[data bytes]
                                         length:[data length]
                               compressionLevel:level];
    STAssertNotNil(deflated, @"failed to deflate data block");
    STAssertGreaterThan([deflated length],
                        (NSUInteger)0, @"failed to deflate data block");
    STAssertFalse(HasGzipHeader(deflated), @"has gzip header on zlib data");
    dataPrime = [NSData gtm_dataByInflatingBytes:[deflated bytes]
                                          length:[deflated length]];
    STAssertNotNil(dataPrime, @"failed to inflate data block");
    STAssertGreaterThan([dataPrime length],
                        (NSUInteger)0, @"failed to inflate data block");
    STAssertEqualObjects(data,
                         dataPrime, @"failed to round trip via *Bytes apis");

    // w/ *Data apis, using our level
    deflated = [NSData gtm_dataByDeflatingData:data compressionLevel:level];
    STAssertNotNil(deflated, @"failed to deflate data block");
    STAssertGreaterThan([deflated length],
                        (NSUInteger)0, @"failed to deflate data block");
    STAssertFalse(HasGzipHeader(deflated), @"has gzip header on zlib data");
    dataPrime = [NSData gtm_dataByInflatingData:deflated];
    STAssertNotNil(dataPrime, @"failed to inflate data block");
    STAssertGreaterThan([dataPrime length],
                        (NSUInteger)0, @"failed to inflate data block");
    STAssertEqualObjects(data,
                         dataPrime, @"failed to round trip via *Data apis");
  }
}

- (void)testInflateGzip {
  NSData *data = [NSData dataWithBytes:randomDataLarge
                                length:sizeof(randomDataLarge)];
  STAssertNotNil(data, @"failed to alloc data block");

  // w/ *Bytes apis, default level
  NSData *gzipped = [NSData gtm_dataByGzippingBytes:[data bytes]
                                             length:[data length]];
  STAssertNotNil(gzipped, @"failed to gzip data block");
  STAssertGreaterThan([gzipped length],
                      (NSUInteger)0, @"failed to gzip data block");
  STAssertTrue(HasGzipHeader(gzipped),
               @"doesn't have gzip header on gzipped data");
  NSData *dataPrime = [NSData gtm_dataByInflatingBytes:[gzipped bytes]
                                                length:[gzipped length]];
  STAssertNotNil(dataPrime, @"failed to inflate data block");
  STAssertGreaterThan([dataPrime length],
                      (NSUInteger)0, @"failed to inflate data block");
  STAssertEqualObjects(data,
                       dataPrime, @"failed to round trip via *Bytes apis");

  // w/ *Data apis, default level
  gzipped = [NSData gtm_dataByGzippingData:data];
  STAssertNotNil(gzipped, @"failed to gzip data block");
  STAssertGreaterThan([gzipped length],
                      (NSUInteger)0, @"failed to gzip data block");
  STAssertTrue(HasGzipHeader(gzipped),
               @"doesn't have gzip header on gzipped data");
  dataPrime = [NSData gtm_dataByInflatingData:gzipped];
  STAssertNotNil(dataPrime, @"failed to inflate data block");
  STAssertGreaterThan([dataPrime length],
                      (NSUInteger)0, @"failed to inflate data block");
  STAssertEqualObjects(data, dataPrime,
                       @"failed to round trip via *Data apis");

  // loop over the compression levels
  for (int level = 1 ; level < 9 ; ++level) {
    // w/ *Bytes apis, using our level
    gzipped = [NSData gtm_dataByGzippingBytes:[data bytes]
                                       length:[data length]
                             compressionLevel:level];
    STAssertNotNil(gzipped, @"failed to gzip data block");
    STAssertGreaterThan([gzipped length],
                        (NSUInteger)0, @"failed to gzip data block");
    STAssertTrue(HasGzipHeader(gzipped),
                 @"doesn't have gzip header on gzipped data");
    dataPrime = [NSData gtm_dataByInflatingBytes:[gzipped bytes]
                                          length:[gzipped length]];
    STAssertNotNil(dataPrime, @"failed to inflate data block");
    STAssertGreaterThan([dataPrime length],
                        (NSUInteger)0, @"failed to inflate data block");
    STAssertEqualObjects(data, dataPrime,
                         @"failed to round trip via *Bytes apis");

    // w/ *Data apis, using our level
    gzipped = [NSData gtm_dataByGzippingData:data compressionLevel:level];
    STAssertNotNil(gzipped, @"failed to gzip data block");
    STAssertGreaterThan([gzipped length],
                        (NSUInteger)0, @"failed to gzip data block");
    STAssertTrue(HasGzipHeader(gzipped),
                 @"doesn't have gzip header on gzipped data");
    dataPrime = [NSData gtm_dataByInflatingData:gzipped];
    STAssertNotNil(dataPrime, @"failed to inflate data block");
    STAssertGreaterThan([dataPrime length],
                        (NSUInteger)0, @"failed to inflate data block");
    STAssertEqualObjects(data,
                         dataPrime, @"failed to round trip via *Data apis");
  }
}

- (void)testLargeData {
  NSData *data1 = [NSData dataWithBytes:randomDataLarge
                                 length:sizeof(randomDataLarge)];
  STAssertNotNil(data1, @"failed to alloc data block");
  NSData *data2 = [NSData dataWithBytes:randomDataSmall
                                 length:sizeof(randomDataSmall)];
  STAssertNotNil(data2, @"failed to alloc data block");

  NSMutableData *input = [NSMutableData data];
  for (NSUInteger i = 0; i < 200; ++i) {
    [input appendData:data1];
    for (NSUInteger j = 0; j < i; ++ j) {
      [input appendData:data2];
    }
  }

  // Should deflate to > 2048 bytes to take multiple loops during deflation.
  NSData *compressed = [NSData gtm_dataByDeflatingData:input
                                      compressionLevel:9];
  STAssertNotNil(compressed, @"failed to deflate");
  STAssertGreaterThan([compressed length], (NSUInteger)2048,
                      @"should have been more then 2048 bytes");

  // Should inflate to > 2048 bytes to take multiple loops during inflation.
  NSData *uncompressed = [NSData gtm_dataByInflatingData:compressed];
  STAssertNotNil(uncompressed, @"fail to inflate");
  STAssertGreaterThan([uncompressed length], (NSUInteger)2048,
                      @"should have been more then 2048 bytes");

  STAssertEqualObjects(uncompressed, input,
                       @"didn't get the same thing back");
}

@end
