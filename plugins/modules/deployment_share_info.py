#!/usr/bin/python
# -*- coding: utf-8 -*-

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r"""
module: deployment_share_info
version_added: 1.1.0
author:
  - Jim Tarpley (@trippsc2)
short_description: Gets information about an MDT deployment share
description:
  - Gets information about an MDT deployment share.
extends_documentation_fragment:
  - trippsc2.mdt.action_group
  - trippsc2.mdt.check_mode_read_only
  - trippsc2.mdt.common
"""

EXAMPLES = r"""
- name: Get MDT deployment share info
  trippsc2.mdt.deployment_share_info:
    mdt_share_path: C:\\MDTShare
"""

RETURN = r"""
exists:
  type: bool
  returned: success
  description:
    - Whether the deployment share exists.
deployment_share:
  type: dict
  returned: RV(exists=true)
  description:
      - The deployment share information.
  contains:
    comments:
      type: str
      description:
        - The deployment share comments.
    description:
      type: str
      description:
        - The deployment share description.
    enable_multicast:
      type: bool
      description:
        - Whether multicast is enabled.
    unc_path:
      type: str
      description:
        - The deployment share UNC path.
    database:
      type: dict
      description:
        - The database configuration.
      contains:
        enabled:
          type: bool
          description:
            - Whether a SQL database is configured.
        instance:
          type: str
          returned: |
            RV(deployment_share.database.enabled=true)
            Database.Instance is configured
          description:
            - The SQL instance.
        name:
          type: str
          returned: RV(deployment_share.database.enabled=true)
          description:
            - The database name.
        netlib:
          type: str
          returned: RV(deployment_share.database.enabled=true)
          description:
            - The SQL netlib.
        port:
          type: int
          returned: RV(deployment_share.database.enabled=true)
          description:
            - The SQL port.
        sql_server:
          type: str
          returned: RV(deployment_share.database.enabled=true)
          description:
            - The SQL server.
        sql_share:
          type: str
          returned: |
            RV(deployment_share.database.enabled=true)
            Database.SQLShare is configured
          description:
            - The SQL share.
    monitor:
      type: dict
      description:
        - The monitoring configuration.
      contains:
        enabled:
          type: bool
          description:
            - Whether monitoring is enabled.
        host:
          type: str
          returned: RV(deployment_share.monitor.enabled=true)
          description:
            - The monitoring hostname/FQDN.
        event_port:
          type: int
          returned: RV(deployment_share.monitor.enabled=true)
          description:
            - The monitoring event port.
        data_port:
          type: int
          returned: RV(deployment_share.monitor.enabled=true)
          description:
            - The monitoring data port.
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
