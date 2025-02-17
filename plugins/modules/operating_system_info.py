#!/usr/bin/python
# -*- coding: utf-8 -*-

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r"""
module: operating_system_info
version_added: 1.1.0
author:
  - Jim Tarpley (@trippsc2)
short_description: Gets information about an MDT operating system
description:
  - Gets information about an MDT operating system.
extends_documentation_fragment:
  - trippsc2.mdt.action_group
  - trippsc2.mdt.check_mode_read_only
  - trippsc2.mdt.common
options:
  guid:
    type: str
    required: false
    description:
      - The GUID of the operating system.
      - This is mutually exclusive with O(name).  One of the two must be provided.
  name:
    type: str
    required: false
    description:
      - The name of the operating system.
      - This is mutually exclusive with O(guid).  One of the two must be provided.
"""

EXAMPLES = r"""
- name: Get operating system info by name
  trippsc2.mdt.operating_system_info:
    mdt_share_path: C:\\MDTShare
    name: Windows 11 Enterprise

- name: Get operating system info by GUID
  trippsc2.mdt.operating_system_info:
    mdt_share_path: C:\\MDTShare
    guid: "{12345678-1234-1234-1234-123456789012}"
"""

RETURN = r"""
exists:
  type: bool
  returned: success
  description:
    - Whether the operating system exists.
operating_system:
  type: dict
  returned: RV(exists=true)
  description:
      - The operating system information.
  contains:
    guid:
      type: str
      description:
        - The GUID of the operating system.
    name:
      type: str
      description:
        - The name of the operating system.
    type:
      type: str
      description:
        - The type of MDT operating system (source or wim).
    paths:
      type: list
      elements: str
      description:
        - The paths at which the operating system is found.
    files_path:
      type: str
      description:
        - The source path for the operating system files.
    build:
      type: str
      description:
        - The build version of the operating system.
    description:
      type: str
      description:
        - The description of the operating system.
    flags:
      type: str
      description:
        - The flags (edition ID) of the operating system.
    hal:
      type: str
      description:
        - The HAL of the operating system.
    image_name:
      type: str
      description:
        - The image name of the operating system.
    image_index:
      type: int
      description:
        - The image index of the operating system.
    image_file:
      type: str
      description:
        - The path to the image file for the operating system.
    languages:
      type: list
      elements: str
      description:
        - The languages of the operating system.
    os_type:
      type: str
      description:
        - The OS type of the operating system.
    platform:
      type: str
      description:
        - The platform of the operating system.
    size:
      type: int
      description:
        - The size of the operating system.
    comments:
      type: str
      description:
        - Comments about the operating system.
    enabled:
      type: bool
      description:
        - Whether the operating system is enabled.
    hidden:
      type: bool
      description:
        - Whether the operating system is hidden.
"""
