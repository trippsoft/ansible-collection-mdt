#!/usr/bin/python
# -*- coding: utf-8 -*-

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r"""
module: directory_info
version_added: 1.1.0
author:
  - Jim Tarpley (@trippsc2)
short_description: Gets information about an MDT deployment share directory
description:
  - Gets information about an MDT deployment share directory.
extends_documentation_fragment:
  - trippsc2.mdt.action_group
  - trippsc2.mdt.check_mode_read_only
  - trippsc2.mdt.common
options:
  path:
    type: str
    required: true
    description:
      - The path of the directory within the MDT deployment share.
  recurse:
    type: bool
    required: false
    default: false
    description:
      - Whether to recurse into subdirectories.
"""

EXAMPLES = r"""
- name: Get directory info
  trippsc2.mdt.directory_info:
    mdt_share_path: C:\\MDTShare
    path: Operating Systems\\Windows10

- name: Get directory info with recursion
  trippsc2.mdt.directory_info:
    mdt_share_path: C:\\MDTShare
    path: Operating Systems
    recurse: true
"""

RETURN = r"""
exists:
  type: bool
  returned: success
  description:
    - Whether the directory exists.
directory:
  type: dict
  returned: RV(exists=true)
  description:
    - The directory information.
  contains:
    type:
      type: str
      description:
        - The type of the directory.
    guid:
      type: str
      description:
        - The directory GUID.
    name:
      type: str
      description:
        - The directory name.
    enabled:
      type: bool
      description:
        - Whether the directory is enabled.
    comments:
      type: str
      description:
        - Comments about the directory.
    contents:
      type: list
      elements: dict
      description:
        - The contents of the directory.
        - The structure of the data depends on the type of data in the directory.
"""
