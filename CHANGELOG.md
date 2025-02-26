# Changelog

All notable changes to this project will be documented in this file.

## [1.2.0] - 2025-02-17

### Collection

- *application* module plugin added.
- *application_info* module plugin added.
- *application_dependency* module plugin added.
- *deployment_share_info* module plugin added.
- *deployment_share_settings* module plugin added.
- *driver_info* module plugin added.
- *operating_system* module plugin added.
- *operating_system_info* module plugin added.
- *selection_profile* module plugin added.
- *selection_profile_info* module plugin added.
- *task_sequence* module plugin added.
- *task_sequence_info* module plugin added.
- Added action group for all module plugins.

### Module Plugin - *deployment_share*

- Replaced `share_name` options with `unc_path` option that includes the entire UNC path.  This was done to allow DFS namespace usage.
- Renamed `path` option to `mdt_share_path` to match other module plugins.
- Added diff support and added support to change description and UNC path on existing shares.

## [1.1.0] - 2025-01-25

### Collection

- *boot_image* module plugin added.
- *directory_info* module plugin added.

### Module Plugin - *directory*

- Replaced `name` and `parent_directory` options with `path` option.
- Renamed `mdt_directory_path` option to `mdt_share_path`.

### Module Plugin - *import_drivers*

- Renamed `mdt_directory_path` option to `mdt_share_path`.

## [1.0.0] - 2025-01-23

### Collection

- Initial release.
- *deployment_share* module plugin added.
- *directory* module plugin added.
- *import_drivers* module plugin added.
