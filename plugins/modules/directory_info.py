#!/usr/bin/python
# -*- coding: utf-8 -*-

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r"""
module: directory_info
version_added: 1.1.0
author:
  - Jim Tarpley
short_description: Gets information about an MDT deployment share directory
description:
  - Gets information about an MDT deployment share directory.
attributes:
  check_mode:
    support: full
    details:
      - Fully supports check mode, as it only reads data.
options:
  installation_path:
    type: path
    required: false
    default: C:\\Program Files\\Microsoft Deployment Toolkit
    description:
      - The path to the MDT installation directory.
  path:
    type: str
    required: true
    description:
      - The path of the directory within the MDT deployment share.
  mdt_share_path:
    type: path
    required: true
    description:
      - The path to the MDT directory.
"""

EXAMPLES = r"""
- name: Get directory info
  trippsc2.mdt.directory_info:
    installation_path: C:\\Program Files\\Microsoft Deployment Toolkit
    path: Operating Systems\Windows10
    mdt_share_path: C:\\MDTShare
"""

RETURN = r"""
exists:
  type: bool
  returned:
    - success
  description:
    - Whether the directory exists.
info:
  type: dict
  returned:
    - RV(exists=true)
  description:
    - The directory information.
  options:
    enabled:
      type: bool
      description:
        - Whether the directory is enabled.
    guid:
      type: str
      description:
        - The directory GUID.
    is_directory:
      type: bool
      description:
        - Whether the path is a directory.
        - This will always be true.
    name:
      type: str
      description:
        - The directory name.
    node_type:
      type: str
      description:
        - The node type.
    children:
      type: list
      elements: dict
      description:
        - The children of the directory.
      options:
        enabled:
          type: bool
          description:
            - Whether the child is enabled.
        guid:
          type: str
          description:
            - The child GUID.
        is_directory:
          type: bool
          description:
            - Whether the child is a directory.
        name:
          type: str
          description:
            - The child name.
        node_type:
          type: str
          description:
            - The child node type.
"""
