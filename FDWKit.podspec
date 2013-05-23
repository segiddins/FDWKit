Pod::Spec.new do |s|
  s.name         = 'FDWKit'
  s.version      = '0.0.1'                                                                  # 1
  s.summary      = 'A library that encapsulates the FeedWrangler AP' # 2
  s.author       = { 'Samuel E. Giddins' => 'segiddins@segiddins.me' }                            # 3
  s.source       = { :git => 'https://github.com/segiddins/FDWKit.git', :tag => '0.0.1' }      # 4
  s.source_files = 'Classes', 'External/**/*.{h,m}'                                         # 5
    s.prefix_header_contents = <<-EOS
#ifdef __OBJC__
#import <Foundation/Foundation.h>

#if __IPHONE_OS_VERSION_MIN_REQUIRED
    #import <MobileCoreServices/MobileCoreServices.h>
#endif

#import <SystemConfiguration/SystemConfiguration.h>
#import "AFNetworking.h"
#import "ANKResource.h"
#import "ANKAnnotationReplacement.h"
#import "ANKClient.h"
#import "ANKClient+ANKHandlerBlocks.h"
#import "NSArray+ANKAdditions.h"
#import "NSDictionary+ANKAdditions.h"
#endif

    EOS
    s.public_header_files = 'FDWKit/*.h', '*.h'

    s.ios.deployment_target = '5.0'

    s.requires_arc = true

    s.dependency 'AFNetworking', '~> 1.2.0'
end
