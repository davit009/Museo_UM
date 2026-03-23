import os
import re
import shutil

# Configuration
LIB_DIR = 'lib'
PROJECT_NAME = 'museo_app'

# Define mapping from old to new path (relative to lib/)
mapping = {
    'utils/profanity_filter.dart': 'core/utils/profanity_filter.dart',
    'ui/admin/admin_dashboard_screen.dart': 'features/admin/screens/admin_dashboard_screen.dart',
    'services/admin_service.dart': 'features/admin/services/admin_service.dart',
    'ui/login/login_screen.dart': 'features/auth/screens/login_screen.dart',
    'ui/login/register_screen.dart': 'features/auth/screens/register_screen.dart',
    'services/auth_service.dart': 'features/auth/services/auth_service.dart',
    'ui/museum/como_llegar_screen.dart': 'features/museum/screens/como_llegar_screen.dart',
    'ui/museum/datos_curiosos_screen.dart': 'features/museum/screens/datos_curiosos_screen.dart',
    'ui/museum/etapas_screen.dart': 'features/museum/screens/etapas_screen.dart',
    'ui/museum/home_screen.dart': 'features/museum/screens/home_screen.dart',
    'ui/museum/informacion_screen.dart': 'features/museum/screens/informacion_screen.dart',
    'ui/museum/intro_historia_screen.dart': 'features/museum/screens/intro_historia_screen.dart',
    'ui/museum/jubilados_screen.dart': 'features/museum/screens/jubilados_screen.dart',
    'ui/museum/musica_screen.dart': 'features/museum/screens/musica_screen.dart',
    'ui/museum/splash_screen.dart': 'features/museum/screens/splash_screen.dart',
    'ui/chat/restricted_chat_screen.dart': 'features/chat/screens/restricted_chat_screen.dart',
    'models/restricted_message.dart': 'features/chat/models/restricted_message.dart',
    'ui/museum/comments_bottom_sheet.dart': 'features/social/screens/comments_bottom_sheet.dart',
    'ui/museum/muro_screen.dart': 'features/social/screens/muro_screen.dart',
    'ui/social/community_directory_screen.dart': 'features/social/screens/community_directory_screen.dart',
    'ui/social/social_hub_screen.dart': 'features/social/screens/social_hub_screen.dart',
    'ui/profile/edit_profile_screen.dart': 'features/social/screens/edit_profile_screen.dart',
    'ui/profile/profile_screen.dart': 'features/social/screens/profile_screen.dart',
    'ui/profile/settings_screen.dart': 'features/social/screens/settings_screen.dart',
    'ui/notifications/notifications_screen.dart': 'features/social/screens/notifications_screen.dart',
    'ui/widgets/connect_button.dart': 'features/social/widgets/connect_button.dart',
    'ui/widgets/profile_bottom_sheet.dart': 'features/social/widgets/profile_bottom_sheet.dart',
    'models/connection.dart': 'features/social/models/connection.dart',
    'models/profile.dart': 'features/social/models/profile.dart',
    'services/social_service.dart': 'features/social/services/social_service.dart',
    'services/muro_service.dart': 'features/social/services/muro_service.dart',
    'ui/wall/info.txt': 'features/social/info.txt',
    # Ensure constants stays same
    'core/constants.dart': 'core/constants.dart',
    'main.dart': 'main.dart'
}

# Normalize paths for Windows (though git bash/powershell usually handles /)
def norm(p): return p.replace('/', os.sep)
mapping = {norm(k): norm(v) for k, v in mapping.items()}

# 1. Update Imports in all Dart files
dart_files = []
for root, dirs, files in os.walk(LIB_DIR):
    for f in files:
        if f.endswith('.dart'):
            dart_files.append(os.path.join(root, f))

# Regex to match import '...';
import_pattern = re.compile(r"import\s+['\"](.*?)['\"];")

def resolve_import(current_file_path, import_str):
    if import_str.startswith('package:' + PROJECT_NAME + '/'):
        rel_to_lib = import_str.replace('package:' + PROJECT_NAME + '/', '')
        rel_to_lib = norm(rel_to_lib)
        if rel_to_lib in mapping:
            return f"package:{PROJECT_NAME}/{mapping[rel_to_lib].replace(os.sep, '/')}"
        return import_str
    
    if import_str.startswith('package:') or import_str.startswith('dart:'):
        return import_str
        
    # Relative import
    current_dir = os.path.dirname(current_file_path)
    # Target absolute path
    target_path = os.path.normpath(os.path.join(current_dir, import_str))
    
    # Check if target is inside lib
    lib_abs = os.path.abspath(LIB_DIR)
    target_abs = os.path.abspath(target_path)
    
    if target_abs.startswith(lib_abs):
        rel_to_lib = os.path.relpath(target_abs, lib_abs)
        if rel_to_lib in mapping:
            new_rel = mapping[rel_to_lib].replace(os.sep, '/')
            return f"package:{PROJECT_NAME}/{new_rel}"
        else:
            # File didn't move or is not mapped, use package: format anyway for consistency
            return f"package:{PROJECT_NAME}/{rel_to_lib.replace(os.sep, '/')}"
            
    return import_str

for df in dart_files:
    with open(df, 'r', encoding='utf-8') as f:
        content = f.read()
    
    def replacer(match):
        imp = match.group(1)
        new_imp = resolve_import(df, imp)
        return f"import '{new_imp}';"

    new_content = import_pattern.sub(replacer, content)
    
    if new_content != content:
        with open(df, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Updated imports in {df}")

# 2. Move files
for old_rel, new_rel in mapping.items():
    if old_rel == new_rel: continue
    
    old_abs = os.path.join(LIB_DIR, old_rel)
    new_abs = os.path.join(LIB_DIR, new_rel)
    
    if os.path.exists(old_abs):
        os.makedirs(os.path.dirname(new_abs), exist_ok=True)
        shutil.move(old_abs, new_abs)
        print(f"Moved {old_rel} -> {new_rel}")

# 3. Cleanup empty directories
for root, dirs, files in os.walk(LIB_DIR, topdown=False):
    for d in dirs:
        dir_path = os.path.join(root, d)
        if not os.listdir(dir_path):
            os.rmdir(dir_path)
            print(f"Removed empty dir: {dir_path}")

print("Refactoring complete!")
