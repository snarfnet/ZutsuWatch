#!/usr/bin/env python3
import os, uuid, shutil

proj_dir = os.path.expanduser("~/ZutsuWatch")
os.makedirs(f"{proj_dir}/ZutsuWatch.xcodeproj", exist_ok=True)
os.makedirs(f"{proj_dir}/ZutsuWatch/Models", exist_ok=True)
os.makedirs(f"{proj_dir}/ZutsuWatch/Views", exist_ok=True)
os.makedirs(f"{proj_dir}/ZutsuWatch/Services", exist_ok=True)
os.makedirs(f"{proj_dir}/ZutsuWatch/Theme", exist_ok=True)
os.makedirs(f"{proj_dir}/ZutsuWatch/Assets.xcassets/AppIcon.appiconset", exist_ok=True)

# Copy source files
src = os.path.expanduser("~/ZutsuWatch_src")
for root, dirs, files in os.walk(src):
    for f in files:
        rel = os.path.relpath(os.path.join(root, f), src)
        dst = os.path.join(proj_dir, "ZutsuWatch", rel)
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        shutil.copy2(os.path.join(root, f), dst)

# Assets catalog
with open(f"{proj_dir}/ZutsuWatch/Assets.xcassets/Contents.json", "w") as f:
    f.write('{"info":{"version":1,"author":"xcode"}}')
with open(f"{proj_dir}/ZutsuWatch/Assets.xcassets/AppIcon.appiconset/Contents.json", "w") as f:
    f.write('{"images":[{"idiom":"universal","platform":"ios","size":"1024x1024"}],"info":{"version":1,"author":"xcode"}}')

def gid():
    return uuid.uuid4().hex[:24].upper()

swift_files = [
    ("ZutsuWatchApp.swift", ""),
    ("PressureData.swift", "Models"),
    ("PressureService.swift", "Services"),
    ("AppTheme.swift", "Theme"),
    ("MainTabView.swift", "Views"),
    ("HomeView.swift", "Views"),
    ("PressureChartView.swift", "Views"),
    ("DiaryView.swift", "Views"),
    ("SettingsView.swift", "Views"),
]

proj_id = gid()
main_group = gid()
src_group = gid()
models_group = gid()
views_group = gid()
services_group = gid()
theme_group = gid()
products_group = gid()
target_id = gid()
app_ref = gid()
config_list_proj = gid()
config_list_target = gid()
config_debug_proj = gid()
config_release_proj = gid()
config_debug_target = gid()
config_release_target = gid()
sources_phase = gid()
resources_phase = gid()
frameworks_phase = gid()
assets_ref = gid()
assets_build = gid()
info_plist_ref = gid()

file_refs = {}
build_files = {}
for fname, _ in swift_files:
    file_refs[fname] = gid()
    build_files[fname] = gid()

# Build pbxproj content
lines = []
lines.append("// !$*UTF8*$!")
lines.append("{")
lines.append("\tarchiveVersion = 1;")
lines.append("\tclasses = {};")
lines.append("\tobjectVersion = 56;")
lines.append("\tobjects = {")
lines.append("")

# PBXBuildFile
lines.append("/* Begin PBXBuildFile section */")
for fname, _ in swift_files:
    lines.append(f'\t\t{build_files[fname]} /* {fname} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_refs[fname]} /* {fname} */; }};')
lines.append(f'\t\t{assets_build} /* Assets.xcassets in Resources */ = {{isa = PBXBuildFile; fileRef = {assets_ref} /* Assets.xcassets */; }};')
lines.append("/* End PBXBuildFile section */")
lines.append("")

# PBXFileReference
lines.append("/* Begin PBXFileReference section */")
for fname, _ in swift_files:
    lines.append(f'\t\t{file_refs[fname]} /* {fname} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {fname}; sourceTree = "<group>"; }};')
lines.append(f'\t\t{info_plist_ref} /* Info.plist */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = "<group>"; }};')
lines.append(f'\t\t{assets_ref} /* Assets.xcassets */ = {{isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = "<group>"; }};')
lines.append(f'\t\t{app_ref} /* ZutsuWatch.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = ZutsuWatch.app; sourceTree = BUILT_PRODUCTS_DIR; }};')
lines.append("/* End PBXFileReference section */")
lines.append("")

# PBXGroup
def group_block(gid_val, name, children, path=None):
    block = []
    block.append(f"\t\t{gid_val} /* {name} */ = {{")
    block.append(f"\t\t\tisa = PBXGroup;")
    block.append(f"\t\t\tchildren = (")
    for c in children:
        block.append(f"\t\t\t\t{c},")
    block.append(f"\t\t\t);")
    if path:
        block.append(f'\t\t\tpath = {path};')
    else:
        block.append(f'\t\t\tname = {name};')
    block.append(f'\t\t\tsourceTree = "<group>";')
    block.append(f"\t\t}};")
    return block

lines.append("/* Begin PBXGroup section */")
lines.extend(group_block(main_group, "Root", [src_group, products_group]))
lines.extend(group_block(products_group, "Products", [app_ref]))

src_children = [file_refs["ZutsuWatchApp.swift"], info_plist_ref, models_group, views_group, services_group, theme_group, assets_ref]
lines.extend(group_block(src_group, "ZutsuWatch", src_children, path="ZutsuWatch"))

lines.extend(group_block(models_group, "Models", [file_refs["PressureData.swift"]], path="Models"))

views_refs = [file_refs[f] for f, g in swift_files if g == "Views"]
lines.extend(group_block(views_group, "Views", views_refs, path="Views"))

lines.extend(group_block(services_group, "Services", [file_refs["PressureService.swift"]], path="Services"))
lines.extend(group_block(theme_group, "Theme", [file_refs["AppTheme.swift"]], path="Theme"))
lines.append("/* End PBXGroup section */")
lines.append("")

# PBXNativeTarget
lines.append("/* Begin PBXNativeTarget section */")
lines.append(f"\t\t{target_id} /* ZutsuWatch */ = {{")
lines.append(f"\t\t\tisa = PBXNativeTarget;")
lines.append(f"\t\t\tbuildConfigurationList = {config_list_target};")
lines.append(f"\t\t\tbuildPhases = ({sources_phase}, {resources_phase}, {frameworks_phase});")
lines.append(f"\t\t\tbuildRules = ();")
lines.append(f"\t\t\tdependencies = ();")
lines.append(f'\t\t\tname = ZutsuWatch;')
lines.append(f'\t\t\tproductName = ZutsuWatch;')
lines.append(f'\t\t\tproductReference = {app_ref};')
lines.append(f'\t\t\tproductType = "com.apple.product-type.application";')
lines.append(f"\t\t}};")
lines.append("/* End PBXNativeTarget section */")
lines.append("")

# PBXProject
lines.append("/* Begin PBXProject section */")
lines.append(f"\t\t{proj_id} /* Project object */ = {{")
lines.append(f"\t\t\tisa = PBXProject;")
lines.append(f"\t\t\tbuildConfigurationList = {config_list_proj};")
lines.append(f'\t\t\tcompatibilityVersion = "Xcode 14.0";')
lines.append(f"\t\t\tdevelopmentRegion = ja;")
lines.append(f"\t\t\thasScannedForEncodings = 0;")
lines.append(f"\t\t\tknownRegions = (ja, en, Base);")
lines.append(f"\t\t\tmainGroup = {main_group};")
lines.append(f"\t\t\tproductRefGroup = {products_group};")
lines.append(f'\t\t\tprojectDirPath = "";')
lines.append(f'\t\t\tprojectRoot = "";')
lines.append(f"\t\t\ttargets = ({target_id});")
lines.append(f"\t\t}};")
lines.append("/* End PBXProject section */")
lines.append("")

# Sources build phase
lines.append("/* Begin PBXSourcesBuildPhase section */")
lines.append(f"\t\t{sources_phase} /* Sources */ = {{")
lines.append(f"\t\t\tisa = PBXSourcesBuildPhase;")
lines.append(f"\t\t\tbuildActionMask = 2147483647;")
lines.append(f"\t\t\tfiles = (")
for fname, _ in swift_files:
    lines.append(f"\t\t\t\t{build_files[fname]} /* {fname} in Sources */,")
lines.append(f"\t\t\t);")
lines.append(f"\t\t\trunOnlyForDeploymentPostprocessing = 0;")
lines.append(f"\t\t}};")
lines.append("/* End PBXSourcesBuildPhase section */")
lines.append("")

# Resources build phase
lines.append("/* Begin PBXResourcesBuildPhase section */")
lines.append(f"\t\t{resources_phase} /* Resources */ = {{")
lines.append(f"\t\t\tisa = PBXResourcesBuildPhase;")
lines.append(f"\t\t\tbuildActionMask = 2147483647;")
lines.append(f"\t\t\tfiles = ({assets_build} /* Assets.xcassets in Resources */,);")
lines.append(f"\t\t\trunOnlyForDeploymentPostprocessing = 0;")
lines.append(f"\t\t}};")
lines.append("/* End PBXResourcesBuildPhase section */")
lines.append("")

# Frameworks build phase
lines.append("/* Begin PBXFrameworksBuildPhase section */")
lines.append(f"\t\t{frameworks_phase} /* Frameworks */ = {{")
lines.append(f"\t\t\tisa = PBXFrameworksBuildPhase;")
lines.append(f"\t\t\tbuildActionMask = 2147483647;")
lines.append(f"\t\t\tfiles = ();")
lines.append(f"\t\t\trunOnlyForDeploymentPostprocessing = 0;")
lines.append(f"\t\t}};")
lines.append("/* End PBXFrameworksBuildPhase section */")
lines.append("")

# Build configurations
common_proj_debug = """ALWAYS_SEARCH_USER_PATHS = NO; CLANG_ENABLE_MODULES = YES; COPY_PHASE_STRIP = NO; DEBUG_INFORMATION_FORMAT = dwarf; GCC_OPTIMIZATION_LEVEL = 0; MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE; ONLY_ACTIVE_ARCH = YES; SDKROOT = iphoneos; SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG; SWIFT_OPTIMIZATION_LEVEL = "-Onone";"""
common_proj_release = """ALWAYS_SEARCH_USER_PATHS = NO; CLANG_ENABLE_MODULES = YES; COPY_PHASE_STRIP = NO; DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym"; ENABLE_NS_ASSERTIONS = NO; MTL_ENABLE_DEBUG_INFO = NO; SDKROOT = iphoneos; SWIFT_COMPILATION_MODE = wholemodule; SWIFT_OPTIMIZATION_LEVEL = "-O"; VALIDATE_PRODUCT = YES;"""
common_target = """ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon; CODE_SIGN_STYLE = Manual; CURRENT_PROJECT_VERSION = 1; DEVELOPMENT_TEAM = 83VGKGSQUH; GENERATE_INFOPLIST_FILE = NO; INFOPLIST_FILE = ZutsuWatch/Info.plist; IPHONEOS_DEPLOYMENT_TARGET = 17.0; MARKETING_VERSION = 1.0; PRODUCT_BUNDLE_IDENTIFIER = com.zutsuwatch.app; PRODUCT_NAME = "$(TARGET_NAME)"; SWIFT_EMIT_LOC_STRINGS = YES; SWIFT_VERSION = 5.0; TARGETED_DEVICE_FAMILY = "1,2";"""

lines.append("/* Begin XCBuildConfiguration section */")
for cid, name, settings in [
    (config_debug_proj, "Debug", common_proj_debug),
    (config_release_proj, "Release", common_proj_release),
    (config_debug_target, "Debug", common_target),
    (config_release_target, "Release", common_target),
]:
    lines.append(f"\t\t{cid} /* {name} */ = {{")
    lines.append(f"\t\t\tisa = XCBuildConfiguration;")
    lines.append(f"\t\t\tbuildSettings = {{ {settings} }};")
    lines.append(f'\t\t\tname = {name};')
    lines.append(f"\t\t}};")
lines.append("/* End XCBuildConfiguration section */")
lines.append("")

# Config lists
lines.append("/* Begin XCConfigurationList section */")
for cl_id, name, configs in [
    (config_list_proj, "PBXProject", [config_debug_proj, config_release_proj]),
    (config_list_target, "PBXNativeTarget", [config_debug_target, config_release_target]),
]:
    lines.append(f"\t\t{cl_id} /* Build configuration list for {name} */ = {{")
    lines.append(f"\t\t\tisa = XCConfigurationList;")
    lines.append(f"\t\t\tbuildConfigurations = ({configs[0]} /* Debug */, {configs[1]} /* Release */,);")
    lines.append(f"\t\t\tdefaultConfigurationIsVisible = 0;")
    lines.append(f"\t\t\tdefaultConfigurationName = Release;")
    lines.append(f"\t\t}};")
lines.append("/* End XCConfigurationList section */")
lines.append("")

lines.append("\t};")
lines.append(f"\trootObject = {proj_id} /* Project object */;")
lines.append("}")

with open(f"{proj_dir}/ZutsuWatch.xcodeproj/project.pbxproj", "w") as f:
    f.write("\n".join(lines))

print("Project created at " + proj_dir)
