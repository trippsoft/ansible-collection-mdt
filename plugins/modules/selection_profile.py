#!/usr/bin/python
# -*- coding: utf-8 -*-

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r"""
module: selection_profile
version_added: 1.1.0
author:
  - Jim Tarpley (@trippsc2)
short_description: Creates, updates, or deletes an MDT selection profile
description:
  - Creates, updates, or deletes an MDT selection profile.
extends_documentation_fragment:
  - trippsc2.mdt.action_group
  - trippsc2.mdt.check_mode
  - trippsc2.mdt.common
options:
  guid:
    type: str
    required: false
    description:
      - The GUID of the selection profile.
      - If O(state=absent), either O(name) or O(guid) must be provided.
      - If provided, the GUID will be used to identify the selection profile.
  name:
    type: str
    required: false
    description:
      - The name of the selection profile.
      - If O(state=absent), either O(name) or O(guid) must be provided.
      - If O(state=present), this is required.
      - If O(guid) is not provided, the name will be used to identify the selection profile.
      - >-
        If O(guid) is provided, the O(guid) will be used to identify the selection profile and the
        selection profile's name will be set to the provided value.
  definition_paths:
    type: dict
    required: false
    description:
      - A list of paths to include in the selection profile.
      - If O(state=present), this is required.
      - If O(state=absent), this should not be provided.
    suboptions:
      add:
        type: list
        required: false
        elements: str
        description:
          - A list of paths to add to the selection profile.
          - This cannot be defined as an empty list.
          - This is mutually exclusive with O(definition_paths.set).
      remove:
        type: list
        required: false
        elements: str
        description:
          - A list of paths to remove from the selection profile.
          - This cannot be defined as an empty list.
          - This is mutually exclusive with O(definition_paths.set).
      set:
        type: list
        required: false
        elements: str
        description:
          - A list of paths to set in the selection profile.
          - This is mutually exclusive with O(definition_paths.add) and O(definition_paths.remove).
  comments:
    type: str
    required: false
    description:
      - Comments about the selection profile.
      - If O(state=absent), this should not be provided.
      - If O(state=present) and the selection profile does not exist, this will set the comments to an empty string.
  enabled:
    type: bool
    required: false
    description:
      - Whether the selection profile is enabled.
      - If O(state=absent), this should not be provided.
      - If O(state=present) and the selection profile does not exist, this will set the selection profile to enabled.
  hidden:
    type: bool
    required: false
    description:
      - Whether the selection profile is hidden.
      - If O(state=absent), this should not be provided.
      - If O(state=present) and the selection profile does not exist, this will set the selection profile to not hidden.
  state:
    type: str
    required: false
    default: present
    choices:
      - present
      - absent
    description:
      - The expected state of the selection profile.
"""

EXAMPLES = r"""
- name: Create selection profile
  trippsc2.mdt.selection_profile:
    mdt_share_path: C:\\MDTShare
    name: Windows 11
    definition:
      add:
        - Operating Systems\\Windows11
        - Applications\\Windows11
    comments: This is the selection profile for Windows 11
    enabled: true
    hidden: false
    state: present

- name: Remove selection profile by name
  trippsc2.mdt.selection_profile_info:
    mdt_share_path: C:\\MDTShare
    name: Windows 11
    state: absent

- name: Remove selection profile by GUID
  trippsc2.mdt.selection_profile_info:
    mdt_share_path: C:\\MDTShare
    guid: "{12345678-1234-1234-1234-123456789012}"
    state: absent
"""

RETURN = r"""
selection_profile:
  type: dict
  returned: O(state=present)
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
        - This should always be V(false).
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
