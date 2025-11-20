import sys
import uuid

def generate_id():
    return uuid.uuid4().hex[:24].upper()

project_path = '/Users/madhurgrover/DivinePrayers/DivinePrayers.xcodeproj/project.pbxproj'

with open(project_path, 'r') as f:
    lines = f.readlines()

new_lines = []
fresh_storekit_id = generate_id()
entitlements_id = generate_id()
fresh_storekit_build_id = generate_id()

# UUIDs from the file
main_group_id = 'DDED519A2D5E9F5C00AE9CD1'
resources_phase_id = 'DDED51A12D5E9F5C00AE9CD1'
debug_config_id = 'DDED51C82D5E9F5D00AE9CD1'
release_config_id = 'DDED51C92D5E9F5D00AE9CD1'
working_storekit_id = 'DD52E1FC2ECE39BC00F7AF95'

in_build_file_section = False
in_file_ref_section = False
in_group_section = False
in_resources_phase = False
in_debug_config = False
in_release_config = False

for line in lines:
    # PBXBuildFile Section
    if 'Begin PBXBuildFile section' in line:
        in_build_file_section = True
        new_lines.append(line)
        new_lines.append(f'\t\t{fresh_storekit_build_id} /* Fresh.storekit in Resources */ = {{isa = PBXBuildFile; fileRef = {fresh_storekit_id} /* Fresh.storekit */; }};\n')
        continue
    if 'End PBXBuildFile section' in line:
        in_build_file_section = False
    
    # PBXFileReference Section
    if 'Begin PBXFileReference section' in line:
        in_file_ref_section = True
        new_lines.append(line)
        new_lines.append(f'\t\t{fresh_storekit_id} /* Fresh.storekit */ = {{isa = PBXFileReference; lastKnownFileType = text; name = Fresh.storekit; path = DivinePrayers/StoreKit/Fresh.storekit; sourceTree = "<group>"; }};\n')
        new_lines.append(f'\t\t{entitlements_id} /* DivinePrayers.entitlements */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.entitlements; name = DivinePrayers.entitlements; path = DivinePrayers/DivinePrayers.entitlements; sourceTree = "<group>"; }};\n')
        continue
    if 'End PBXFileReference section' in line:
        in_file_ref_section = False
        
    # Remove old WorkingStoreKit reference if present
    if working_storekit_id in line and 'PBXFileReference' in line:
        continue

    # PBXGroup Section (Main Group)
    if f'{main_group_id} =' in line:
        in_group_section = True
    if in_group_section and 'children = (' in line:
        new_lines.append(line)
        new_lines.append(f'\t\t\t\t{fresh_storekit_id} /* Fresh.storekit */,\n')
        new_lines.append(f'\t\t\t\t{entitlements_id} /* DivinePrayers.entitlements */,\n')
        continue
    if in_group_section and working_storekit_id in line:
        continue # Remove old reference from group
    if in_group_section and '};' in line:
        in_group_section = False

    # PBXResourcesBuildPhase
    if f'{resources_phase_id} /* Resources */ =' in line:
        in_resources_phase = True
    if in_resources_phase and 'files = (' in line:
        new_lines.append(line)
        new_lines.append(f'\t\t\t\t{fresh_storekit_build_id} /* Fresh.storekit in Resources */,\n')
        continue
    if in_resources_phase and '};' in line:
        in_resources_phase = False

    # XCBuildConfiguration (Debug)
    if f'{debug_config_id} /* Debug */ =' in line:
        in_debug_config = True
    if in_debug_config and 'buildSettings = {' in line:
        new_lines.append(line)
        new_lines.append('\t\t\t\tCODE_SIGN_ENTITLEMENTS = DivinePrayers/DivinePrayers.entitlements;\n')
        continue
    if in_debug_config and '};' in line:
        in_debug_config = False

    # XCBuildConfiguration (Release)
    if f'{release_config_id} /* Release */ =' in line:
        in_release_config = True
    if in_release_config and 'buildSettings = {' in line:
        new_lines.append(line)
        new_lines.append('\t\t\t\tCODE_SIGN_ENTITLEMENTS = DivinePrayers/DivinePrayers.entitlements;\n')
        continue
    if in_release_config and '};' in line:
        in_release_config = False

    new_lines.append(line)

with open(project_path, 'w') as f:
    f.writelines(new_lines)
