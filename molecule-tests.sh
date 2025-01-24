#! /bin/bash

set -e

MOLECULE_BOX="w2022_cis" molecule test -s boot_image
MOLECULE_BOX="w2022_cis" molecule test -s deployment_share
MOLECULE_BOX="w2022_cis" molecule test -s directory
MOLECULE_BOX="w2022_cis" molecule test -s directory_info
MOLECULE_BOX="w2022_cis" molecule test -s import_drivers

MOLECULE_BOX="w2019_cis" molecule test -s boot_image
MOLECULE_BOX="w2019_cis" molecule test -s deployment_share
MOLECULE_BOX="w2019_cis" molecule test -s directory
MOLECULE_BOX="w2019_cis" molecule test -s directory_info
MOLECULE_BOX="w2019_cis" molecule test -s import_drivers

MOLECULE_BOX="w2025_base" molecule test -s boot_image
MOLECULE_BOX="w2025_base" molecule test -s deployment_share
MOLECULE_BOX="w2025_base" molecule test -s directory
MOLECULE_BOX="w2025_base" molecule test -s directory_info
MOLECULE_BOX="w2025_base" molecule test -s import_drivers
