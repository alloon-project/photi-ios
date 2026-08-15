#!/usr/bin/env python3
# Apply small patches needed after every `tuist generate`.
#
# - Tuist generates the workspace without kakao-ios-sdk because its xcodeproj
#   is named KakaoOpenSDK.xcodeproj instead of kakao-ios-sdk.xcodeproj.
# - Xcode explicit Swift modules can make GTMAppAuth resolve AppAuthCore and
#   GTMSessionFetcherCore as empty generated Swift modules instead of their
#   ObjC Clang modules.

workspace = 'Photi.xcworkspace/contents.xcworkspacedata'
gtm_app_auth_project = (
    'Tuist/Dependencies/SwiftPackageManager/.build/checkouts/'
    'GTMAppAuth/GTMAppAuth.xcodeproj/project.pbxproj'
)
core_project_patches = {
    'Tuist/Dependencies/SwiftPackageManager/.build/checkouts/'
    'AppAuth-iOS/AppAuth.xcodeproj/project.pbxproj': (
        '\t\t\t\t60179C533F72B45F6B444262 /* TuistBundle+AppAuthCore.swift in Sources */,\n'
    ),
    'Tuist/Dependencies/SwiftPackageManager/.build/checkouts/'
    'gtm-session-fetcher/GTMSessionFetcher.xcodeproj/project.pbxproj': (
        '\t\t\t\t0E34FFCAA9D761E74384D197 /* TuistBundle+GTMSessionFetcherCore.swift in Sources */,\n'
    ),
}

with open(workspace) as f:
    content = f.read()

if 'KakaoOpenSDK' in content:
    print('KakaoSDK already in workspace, skipping.')
else:
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

try:
    with open(gtm_app_auth_project) as f:
        content = f.read()
except FileNotFoundError:
    print('GTMAppAuth project not found, skipping.')
    exit(0)

if 'SWIFT_ENABLE_EXPLICIT_MODULES = NO;' in content:
    print('GTMAppAuth explicit Swift modules already disabled, skipping.')
else:
    patched = content.replace(
        'SWIFT_VERSION = 5.0;',
        'SWIFT_ENABLE_EXPLICIT_MODULES = NO;\n\t\t\t\tSWIFT_VERSION = 5.0;'
    )
    if patched == content:
        print('ERROR: Could not patch GTMAppAuth build settings.')
        exit(1)

    with open(gtm_app_auth_project, 'w') as f:
        f.write(patched)

    print('GTMAppAuth explicit Swift modules disabled.')

for project, dummy_source in core_project_patches.items():
    try:
        with open(project) as f:
            content = f.read()
    except FileNotFoundError:
        print(f'{project} not found, skipping.')
        continue

    if dummy_source not in content:
        print(f'{project} dummy Swift source already removed, skipping.')
        continue

    with open(project, 'w') as f:
        f.write(content.replace(dummy_source, ''))

    print(f'{project} dummy Swift source removed.')
