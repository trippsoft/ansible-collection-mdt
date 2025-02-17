#!/usr/bin/python
# -*- coding: utf-8 -*-

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r"""
module: selection_profile_info
version_added: 1.1.0
author:
  - Jim Tarpley (@trippsc2)
short_description: Gets information about an MDT selection profile
description:
  - Gets information about an MDT selection profile.
extends_documentation_fragment:
  - trippsc2.mdt.action_group
  - trippsc2.mdt.check_mode_read_only
  - trippsc2.mdt.common
options:
  guid:
    type: str
    required: false
    description:
      - The GUID of the selection profile.
      - This is mutually exclusive with O(name).  One of the two must be provided.
  name:
    type: str
    required: false
    description:
      - The name of the selection profile.
      - This is mutually exclusive with O(guid).  One of the two must be provided.
"""

EXAMPLES = r"""
- name: Get selection profile info by name
  trippsc2.mdt.selection_profile_info:
    mdt_share_path: C:\\MDTShare
    name: Windows 11

- name: Get selection profile info by GUID
  trippsc2.mdt.selection_profile_info:
    mdt_share_path: C:\\MDTShare
    guid: "{12345678-1234-1234-1234-123456789012}"
"""

RETURN = r"""
exists:
  type: bool
  returned: success
  description:
    - Whether the selection profile exists.
selection_profile:
  type: dict
  returned: RV(exists=true)
  description:
      - The selection profile information.
  contains:
    guid:
      type: str
      description:
        - The GUID of the selection profile.
    name:
      type: str
      description:
        - The name of the selection profile.
    read_only:
      type: bool
      description:
        - Whether the selection profile is read-only.
    definition:
      type: list
      elements: str
      description:
        - The paths included within the selection profile.
    comments:
      type: str
      description:
        - Comments about the selection profile.
    enabled:
      type: bool
      description:
        - Whether the selection profile is enabled.
    hidden:
      type: bool
      description:
        - Whether the selection profile is hidden.
"""
