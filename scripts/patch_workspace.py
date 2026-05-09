#!/usr/bin/env python3
# Tuist generates the workspace without kakao-ios-sdk because its xcodeproj
# is named KakaoOpenSDK.xcodeproj instead of kakao-ios-sdk.xcodeproj.
# This script adds it to the workspace after every `tuist generate`.

workspace = 'Photi.xcworkspace/contents.xcworkspacedata'

with open(workspace) as f:
    content = f.read()

if 'KakaoOpenSDK' in content:
    print('KakaoSDK already in workspace, skipping.')
    exit(0)

entry = (
    '\n               <FileRef\n'
    '                  location = "group:kakao-ios-sdk/KakaoOpenSDK.xcodeproj">\n'
    '               </FileRef>'
)

idx = content.rfind('</FileRef>')
if idx == -1:
    print('ERROR: Could not find insertion point in workspace.')
    exit(1)

idx += len('</FileRef>')
content = content[:idx] + entry + content[idx:]

with open(workspace, 'w') as f:
    f.write(content)

print('KakaoSDK added to workspace.')
