#! /bin/bash

set -e

MOLECULE_BOX="w2022_cis" molecule test -s application
MOLECULE_BOX="w2022_cis" molecule test -s application_dependency
MOLECULE_BOX="w2022_cis" molecule test -s application_info
MOLECULE_BOX="w2022_cis" molecule test -s boot_image
MOLECULE_BOX="w2022_cis" molecule test -s deployment_share
MOLECULE_BOX="w2022_cis" molecule test -s deployment_share_info
MOLECULE_BOX="w2022_cis" molecule test -s deployment_share_settings
MOLECULE_BOX="w2022_cis" molecule test -s directory
MOLECULE_BOX="w2022_cis" molecule test -s directory_info
MOLECULE_BOX="w2022_cis" molecule test -s driver_info
MOLECULE_BOX="w2022_cis" molecule test -s import_drivers
MOLECULE_BOX="w2022_cis" molecule test -s operating_system
MOLECULE_BOX="w2022_cis" molecule test -s operating_system_info
MOLECULE_BOX="w2022_cis" molecule test -s selection_profile
MOLECULE_BOX="w2022_cis" molecule test -s selection_profile_info
MOLECULE_BOX="w2022_cis" molecule test -s task_sequence
MOLECULE_BOX="w2022_cis" molecule test -s task_sequence_info

MOLECULE_BOX="w2019_cis" molecule test -s application
MOLECULE_BOX="w2019_cis" molecule test -s application_dependency
MOLECULE_BOX="w2019_cis" molecule test -s application_info
MOLECULE_BOX="w2019_cis" molecule test -s boot_image
MOLECULE_BOX="w2019_cis" molecule test -s deployment_share
MOLECULE_BOX="w2019_cis" molecule test -s deployment_share_info
MOLECULE_BOX="w2019_cis" molecule test -s deployment_share_settings
MOLECULE_BOX="w2019_cis" molecule test -s directory
MOLECULE_BOX="w2019_cis" molecule test -s directory_info
MOLECULE_BOX="w2019_cis" molecule test -s driver_info
MOLECULE_BOX="w2019_cis" molecule test -s import_drivers
MOLECULE_BOX="w2019_cis" molecule test -s operating_system
MOLECULE_BOX="w2019_cis" molecule test -s operating_system_info
MOLECULE_BOX="w2019_cis" molecule test -s selection_profile
MOLECULE_BOX="w2019_cis" molecule test -s selection_profile_info
MOLECULE_BOX="w2019_cis" molecule test -s task_sequence
MOLECULE_BOX="w2019_cis" molecule test -s task_sequence_info

MOLECULE_BOX="w2025_base" molecule test -s application
MOLECULE_BOX="w2025_base" molecule test -s application_dependency
MOLECULE_BOX="w2025_base" molecule test -s application_info
MOLECULE_BOX="w2025_base" molecule test -s boot_image
MOLECULE_BOX="w2025_base" molecule test -s deployment_share
MOLECULE_BOX="w2025_base" molecule test -s deployment_share_info
MOLECULE_BOX="w2025_base" molecule test -s deployment_share_settings
MOLECULE_BOX="w2025_base" molecule test -s directory
MOLECULE_BOX="w2025_base" molecule test -s directory_info
MOLECULE_BOX="w2025_base" molecule test -s driver_info
MOLECULE_BOX="w2025_base" molecule test -s import_drivers
MOLECULE_BOX="w2025_base" molecule test -s operating_system
MOLECULE_BOX="w2025_base" molecule test -s operating_system_info
MOLECULE_BOX="w2025_base" molecule test -s selection_profile
MOLECULE_BOX="w2025_base" molecule test -s selection_profile_info
MOLECULE_BOX="w2025_base" molecule test -s task_sequence
MOLECULE_BOX="w2025_base" molecule test -s task_sequence_info
