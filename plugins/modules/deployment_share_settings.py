#!/usr/bin/python
# -*- coding: utf-8 -*-

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r"""
module: deployment_share_settings
version_added: 1.1.0
author:
  - Jim Tarpley (@trippsc2)
short_description: Configures MDT deployment share settings
description:
  - Configures MDT deployment share settings.
extends_documentation_fragment:
  - trippsc2.mdt.action_group
  - trippsc2.mdt.check_mode
  - trippsc2.mdt.common
options:
  comments:
    type: str
    required: false
    description:
      - The deployment share comments.
  enable_multicast:
    type: bool
    required: false
    description:
      - Whether multicast is enabled.
  x86:
    type: dict
    required: false
    description:
      - The x86 configuration.
    suboptions:
      enabled:
        type: bool
        required: false
        description:
          - Whether x86 is enabled.
          - If any other x86 options are provided and this is not, this will be set to V(true).
      background_file:
        type: str
        required: false
        description:
          - The x86 background file.
          - If O(x86.enabled=false), this should not be provided.
      extra_directory:
        type: str
        required: false
        description:
          - The x86 extra directory.
          - If an empty string is provided, the extra directory will be removed.
          - If O(x86.enabled=false), this should not be provided.
      feature_packs:
        type: list
        elements: str
        required: false
        description:
          - The x86 feature packs.
          - If O(x86.enabled=false), this should not be provided.
      generic_iso:
        type: dict
        required: false
        description:
          - The x86 generic ISO file information.
          - If O(x86.enabled=false), this should not be provided.
        suboptions:
          enabled:
            type: bool
            required: false
            description:
              - Whether the x86 generic ISO file is enabled.
              - If O(x86.generic_iso.name) is provided and this is not, this will be set to V(true).
              - If O(x86.generic_wim.enabled=false), this cannot be V(true).
          name:
            type: str
            required: false
            description:
              - The x86 generic ISO filename.
              - If O(x86.generic_iso.enabled=false), this should not be provided.
      generic_wim:
        type: dict
        required: false
        description:
          - The x86 generic WIM file information.
          - If O(x86.enabled=false), this should not be provided.
        suboptions:
          enabled:
            type: bool
            required: false
            description:
              - Whether the x86 generic WIM file is enabled.
              - If O(x86.generic_wim.description) is provided and this is not, this will be set to V(true).
          description:
            type: str
            required: false
            description:
              - The x86 generic WIM file description.
              - If O(x86.generic_wim.enabled=false), this should not be provided.
      litetouch_iso:
        type: dict
        required: false
        description:
          - The x86 LiteTouch ISO file information.
          - If O(x86.enabled=false), this should not be provided.
        suboptions:
          enabled:
            type: bool
            required: false
            description:
              - Whether the x86 LiteTouch ISO file is enabled.
              - If O(x86.litetouch_iso.name) is provided and this is not, this will be set to V(true).
          name:
            type: str
            required: false
            description:
              - The x86 LiteTouch ISO filename.
              - If O(x86.litetouch_iso.enabled=false), this should not be provided.
      litetouch_wim:
        type: dict
        required: false
        description:
          - The x86 LiteTouch WIM file information.
          - If O(x86.enabled=false), this should not be provided.
        suboptions:
          description:
            type: str
            required: true
            description:
              - The x86 LiteTouch WIM file description.
      include_drivers:
        type: list
        required: false
        elements: str
        choices:
          - all
          - mass_storage
          - network
          - system
          - video
        description:
          - The x86 driver types to include.
          - If V(all), all drivers in the selection profile are included and no others should be supplied.
          - If O(x86.enabled=false), this should not be provided.
      scratch_space:
        type: int
        required: false
        choices:
          - 32
          - 64
          - 128
          - 256
          - 512
        description:
          - The x86 scratch space.
          - If O(x86.enabled=false), this should not be provided.
      selection_profile:
        type: str
        required: false
        description:
          - The x86 driver selection profile.
          - If O(x86.enabled=false), this should not be provided.
  x64:
    type: dict
    required: false
    description:
      - The x64 configuration.
    suboptions:
      enabled:
        type: bool
        required: false
        description:
          - Whether x86 is enabled.
          - If any other x64 options are provided and this is not, this will be set to V(true).
      background_file:
        type: str
        required: false
        description:
          - The x86 background file.
          - If O(x64.enabled=false), this should not be provided.
      extra_directory:
        type: str
        required: false
        description:
          - The x86 extra directory.
          - If an empty string is provided, the extra directory will be removed.
          - If O(x64.enabled=false), this should not be provided.
      feature_packs:
        type: list
        elements: str
        required: false
        description:
          - The x86 feature packs.
          - If O(x64.enabled=false), this should not be provided.
      generic_iso:
        type: dict
        required: false
        description:
          - The x86 generic ISO file information.
          - If O(x64.enabled=false), this should not be provided.
        suboptions:
          enabled:
            type: bool
            required: false
            description:
              - Whether the x86 generic ISO file is enabled.
              - If O(x64.generic_iso.name) is provided and this is not, this will be set to V(true).
          name:
            type: str
            required: false
            description:
              - The x86 generic ISO filename.
              - If O(x64.generic_iso.enabled=false), this should not be provided.
      generic_wim:
        type: dict
        required: false
        description:
          - The x86 generic WIM file information.
          - If O(x64.enabled=false), this should not be provided.
        suboptions:
          enabled:
            type: bool
            required: false
            description:
              - Whether the x86 generic WIM file is enabled.
              - If O(x64.generic_wim.description) is provided and this is not, this will be set to V(true).
              - If O(x64.generic_wim.enabled=false), this cannot be V(true).
          description:
            type: str
            required: false
            description:
              - The x86 generic WIM file description.
              - If O(x64.generic_wim.enabled=false), this should not be provided.
      litetouch_iso:
        type: dict
        required: false
        description:
          - The x86 LiteTouch ISO file information.
          - If O(x64.enabled=false), this should not be provided.
        suboptions:
          enabled:
            type: bool
            required: false
            description:
              - Whether the x86 LiteTouch ISO file is enabled.
              - If O(x64.litetouch_iso.name) is provided and this is not, this will be set to V(true).
          name:
            type: str
            required: false
            description:
              - The x86 LiteTouch ISO filename.
              - If O(x64.litetouch_iso.enabled=false), this should not be provided.
      litetouch_wim:
        type: dict
        required: false
        description:
          - The x86 LiteTouch WIM file information.
          - If O(x64.enabled=false), this should not be provided.
        suboptions:
          description:
            type: str
            required: true
            description:
              - The x86 LiteTouch WIM file description.
      include_drivers:
        type: list
        required: false
        elements: str
        choices:
          - all
          - mass_storage
          - network
          - system
          - video
        description:
          - The x86 driver types to include.
          - If V(all), all drivers in the selection profile are included and no others should be supplied.
          - If O(x64.enabled=false), this should not be provided.
      scratch_space:
        type: int
        required: false
        choices:
          - 32
          - 64
          - 128
          - 256
          - 512
        description:
          - The x86 scratch space.
          - If O(x64.enabled=false), this should not be provided.
      selection_profile:
        type: str
        required: false
        description:
          - The x86 driver selection profile.
          - If O(x64.enabled=false), this should not be provided.
"""

EXAMPLES = r"""
- name: Configure MDT deployment share settings
  trippsc2.mdt.deployment_share_settings:
    mdt_share_path: C:\\MDTShare
    comments: 'MDT Deployment Share'
    enable_multicast: false
    x86:
      enabled: true
      background_file: 'background.bmp'
      extra_directory: ''
      feature_packs:
        - winpe-mdac
      generic_iso:
        enabled: true
        name: 'Generic_x86.iso'
      generic_wim:
        enabled: true
        description: 'Generic Windows PE (x86)'
      litetouch_iso:
        enabled: true
        name: 'LiteTouch_x86.iso'
      litetouch_wim:
        description: 'Lite Touch Windows PE (x86)'
      include_drivers:
        - mass_storage
        - network
      scratch_space: 32
      selection_profile: All Drivers and Packages
    x64:
      enabled: true
      background_file: 'background.bmp'
      extra_directory: ''
      feature_packs:
        - winpe-mdac
      generic_iso:
        enabled: true
        name: 'Generic_x64.iso'
      generic_wim:
        enabled: true
        description: 'Generic Windows PE (x64)'
      litetouch_iso:
        enabled: true
        name: 'LiteTouch_x64.iso'
      litetouch_wim:
        description: 'Lite Touch Windows PE (x64)'
      include_drivers:
        - mass_storage
        - network
      scratch_space: 32
      selection_profile: All Drivers and Packages
"""

RETURN = r"""
deployment_share:
  type: dict
  returned: success
  description:
      - The deployment share information.
  contains:
    comments:
      type: str
      description:
        - The deployment share comments.
    enable_multicast:
      type: bool
      description:
        - Whether multicast is enabled.
    x86:
      type: dict
      description:
        - The x86 configuration.
      contains:
        enabled:
          type: bool
          description:
            - Whether x86 is enabled.
        background_file:
          type: str
          returned: RV(deployment_share.x86.enabled=true)
          description:
            - The x86 background file.
        extra_directory:
          type: str
          returned: |
            RV(deployment_share.x86.enabled=true)
            Boot.x86.ExtraDirectory is configured
          description:
            - The x86 extra directory.
        feature_packs:
          type: list
          elements: str
          returned: RV(deployment_share.x86.enabled=true)
          description:
            - The x86 feature packs.
        generic_iso:
          type: dict
          returned: RV(deployment_share.x86.enabled=true)
          description:
            - The x86 generic ISO file information.
          contains:
            enabled:
              type: bool
              description:
                - Whether the x86 generic ISO file is enabled.
            name:
              type: str
              returned: RV(deployment_share.x86.generic_iso.enabled=true)
              description:
                - The x86 generic ISO filename.
        generic_wim:
          type: dict
          returned: RV(deployment_share.x86.enabled=true)
          description:
            - The x86 generic WIM file information.
          contains:
            enabled:
              type: bool
              description:
                - Whether the x86 generic WIM file is enabled.
            description:
              type: str
              returned: RV(deployment_share.x86.generic_wim.enabled=true)
              description:
                - The x86 generic WIM file description.
        litetouch_iso:
          type: dict
          returned: RV(deployment_share.x86.enabled=true)
          description:
            - The x86 LiteTouch ISO file information.
          contains:
            enabled:
              type: bool
              description:
                - Whether the x86 LiteTouch ISO file is enabled.
            name:
              type: str
              returned: RV(deployment_share.x86.litetouch_iso.enabled=true)
              description:
                - The x86 LiteTouch ISO filename.
        litetouch_wim:
          type: dict
          returned: RV(deployment_share.x86.enabled=true)
          description:
            - The x86 LiteTouch WIM file information.
          contains:
            description:
              type: str
              description:
                - The x86 LiteTouch WIM file description.
        include_drivers:
          type: list
          elements: str
          returned: RV(deployment_share.x86.enabled=true)
          description:
            - The x86 driver types to include.
            - If V(all), all drivers in the selection profile are included.
        scratch_space:
          type: int
          returned: RV(deployment_share.x86.enabled=true)
          description:
            - The x86 scratch space.
        selection_profile:
          type: str
          returned: RV(deployment_share.x86.enabled=true)
          description:
            - The x86 selection profile.
    x64:
      type: dict
      description:
        - The x64 configuration.
      contains:
        enabled:
          type: bool
          description:
            - Whether x64 is enabled.
        background_file:
          type: str
          returned: RV(deployment_share.x64.enabled=true)
          description:
            - The x64 background file.
        extra_directory:
          type: str
          returned: |
            RV(deployment_share.x64.enabled=true)
            Boot.x64.ExtraDirectory is configured
          description:
            - The x64 extra directory.
        feature_packs:
          type: list
          elements: str
          returned: RV(deployment_share.x64.enabled=true)
          description:
            - The x64 feature packs.
        generic_iso:
          type: dict
          returned: RV(deployment_share.x64.enabled=true)
          description:
            - The x64 generic ISO file information.
          contains:
            enabled:
              type: bool
              description:
                - Whether the x64 generic ISO file is enabled.
            name:
              type: str
              returned: RV(deployment_share.x64.generic_iso.enabled=true)
              description:
                - The x64 generic ISO filename.
        generic_wim:
          type: dict
          returned: RV(deployment_share.x64.enabled=true)
          description:
            - The x64 generic WIM file information.
          contains:
            enabled:
              type: bool
              description:
                - Whether the x64 generic WIM file is enabled.
            description:
              type: str
              returned: RV(deployment_share.x64.generic_wim.enabled=true)
              description:
                - The x64 generic WIM file description.
        litetouch_iso:
          type: dict
          returned: RV(deployment_share.x64.enabled=true)
          description:
            - The x64 LiteTouch ISO file information.
          contains:
            enabled:
              type: bool
              description:
                - Whether the x64 LiteTouch ISO file is enabled.
            name:
              type: str
              returned: RV(deployment_share.x64.litetouch_iso.enabled=true)
              description:
                - The x64 LiteTouch ISO filename.
        litetouch_wim:
          type: dict
          returned: RV(deployment_share.x64.enabled=true)
          description:
            - The x64 LiteTouch WIM file information.
          contains:
            description:
              type: str
              description:
                - The x64 LiteTouch WIM file description.
        include_drivers:
          type: list
          elements: str
          returned: RV(deployment_share.x64.enabled=true)
          description:
            - The x64 driver types to include.
            - If V(all), all drivers in the selection profile are included.
        scratch_space:
          type: int
          returned: RV(deployment_share.x64.enabled=true)
          description:
            - The x64 scratch space.
        selection_profile:
          type: str
          returned: RV(deployment_share.x64.enabled=true)
          description:
            - The x64 selection profile.
"""
