#!/usr/bin/python
# -*- coding: utf-8 -*-

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r"""
module: task_sequence
version_added: 1.1.0
author:
  - Jim Tarpley (@trippsc2)
short_description: Creates, updates, or deletes an MDT task sequence
description:
  - Creates, updates, or deletes an MDT task sequence.
extends_documentation_fragment:
  - trippsc2.mdt.action_group
  - trippsc2.mdt.check_mode
  - trippsc2.mdt.common
options:
  id:
    type: str
    required: false
    description:
      - The ID of the task sequence.
      - Either O(name) or O(id) must be provided.
      - The GUID will be used to identify the task sequence, if provided.
      - If O(state=absent), O(name) and O(id) are mutually exclusive.
      - If O(state=present), this is required and will always be used to identify the task sequence.
  name:
    type: str
    required: false
    description:
      - The name of the task sequence.
      - Either O(name) or O(id) must be provided.
      - If O(id) is not provided, the name will be used to identify the task sequence.
      - If O(state=absent), O(name) and O(id) are mutually exclusive. If O(id) is not provided, this will be used to identify the task sequence.
      - If O(state=present), this is required.
  paths:
    type: dict
    required: false
    description:
      - The expected configuration for paths at which the task sequence should be found.
      - If not provided and the task sequence does not exist, the task sequence will be placed in the V(Task Sequences) folder.
      - If not provided and the task sequence exists, the task sequence will not be moved or copied into any folders.
    suboptions:
      add:
        type: list
        required: false
        elements: str
        description:
          - A list of additional paths to add to the task sequence.
          - These paths are relative to the V(Task Sequences) folder within the MDT share.
          - This is mutually exclusive with O(paths.set).
      remove:
        type: list
        required: false
        elements: str
        description:
          - A list of paths to remove from the task sequence.
          - These paths are relative to the V(Task Sequences) folder within the MDT share.
          - This is mutually exclusive with O(paths.set).
          - >-
            If the task sequence is not found at any other paths than these, the module will fail.
            Use O(state=absent) to remove the task sequence instead.
      set:
        type: list
        required: false
        elements: str
        description:
          - A list of paths to set for the task sequence.
          - These paths are relative to the V(Task Sequences) folder within the MDT share.
          - This is mutually exclusive with O(paths.add) and O(paths.remove).
          - If this is an empty list, the module will fail.  Use O(state=absent) to remove the task sequence instead.
  template:
    type: str
    required: false
    description:
      - The template file name from which the task sequence was imported.
      - The file should be located in the C(Templates) folder within the MDT share or in the C(Templates) folder of the MDT program directory.
      - If O(state=absent), this should not be provided.
      - If O(state=present), this is required.
  operating_system_guid:
    type: str
    required: false
    description:
      - The GUID of the operating system to use for the task sequence.
      - O(operating_system_guid) and O(operating_system_name) are mutually exclusive.
      - If O(state=absent), this should not be provided.
      - If not provided and the task sequence exists, this or O(operating_system_name) are required.
  operating_system_name:
    type: str
    required: false
    description:
      - The name of the operating system to use for the task sequence.
      - O(operating_system_guid) and O(operating_system_name) are mutually exclusive.
      - If O(state=absent), this should not be provided.
      - If not provided and the task sequence exists, this or O(operating_system_guid) are required.
  product_key_type:
    type: str
    required: false
    choices:
      - none
      - mak
      - retail
    description:
      - The type of product key to provide to the task sequence.
      - If O(state=absent), this should not be provided.
      - If not provided, O(state=present), and the task sequence does not exist, this will default to V(none).
      - If not provided, O(state=present), and the task sequence exists, this will default to the existing product key type.
  product_key:
    type: str
    required: false
    description:
      - The product key to provide to the task sequence.
      - If O(state=absent), this should not be provided.
      - If O(product_key_type=none), this should not be provided.
      - If O(product_key_type=mak) or O(product_key_type=retail), this is required.
  admin_password:
    type: str
    required: false
    description:
      - The administrator password to provide to the task sequence.
      - If O(state=absent), this should not be provided.
      - If not provided and the task sequence exists, the administrator password will not be changed.
      - If not provided and the task sequence does not exist, the administrator password will be left blank.
      - If provided as an empty string, the administrator password will be removed.
  full_name:
    type: str
    required: false
    description:
      - The full name of the task sequence.
      - If O(state=absent), this should not be provided.
      - If O(state=present), this is required.
  organization:
    type: str
    required: false
    description:
      - The organization name for the task sequence.
      - If O(state=absent), this should not be provided.
      - If O(state=present), this is required.
  ie_home_page:
    type: str
    required: false
    description:
      - The home page for Internet Explorer.
      - If O(state=absent), this should not be provided.
      - If not provided, O(state=present), and the task sequence exists, this will not be changed.
      - If not provided, O(state=present), and the task sequence does not exist, this will be set to V(about:blank).
      - If provided and O(state=present), the home page will be set to the provided value.
  version:
    type: str
    required: false
    description:
      - The version of the task sequence.
      - If O(state=absent), this should not be provided.
      - If not provided and the task sequence exists, the version will not be changed.
      - If not provided and the task sequence does not exist, the version will be set to V(1.0).
  comments:
    type: str
    required: false
    description:
      - Comments about the task sequence.
      - If O(state=absent), this should not be provided.
      - If not provided and the task sequence exists, the comments will not be changed.
      - If not provided and the task sequence does not exist, the comments will be left blank.
  enabled:
    type: bool
    required: false
    description:
      - Whether the task sequence is enabled.
      - If O(state=absent), this should not be provided.
      - If not provided and the task sequence exists, the enabled state will not be changed.
      - If not provided and the task sequence does not exist, the task sequence will be created enabled.
  hidden:
    type: bool
    required: false
    description:
      - Whether the task sequence is hidden.
      - If O(state=absent), this should not be provided.
      - If not provided and the task sequence exists, the hidden state will not be changed.
      - If not provided and the task sequence does not exist, the task sequence will be created and not be hidden.
  state:
    type: str
    required: false
    default: present
    choices:
      - present
      - absent
    description:
      - The state of the task sequence.
      - If V(present), the task sequence will be created or updated.
      - If V(absent), the task sequence will be removed.
"""

EXAMPLES = r"""
- name: Create a MDT task sequence with MAK product key
  trippsc2.mdt.task_sequence:
    mdt_share_path: C:\\MDTShare
    id: WIN11-ENT
    name: Windows 11 Enterprise
    template: Client.xml
    operating_system_name: Windows 11 Enterprise
    product_key_type: mak
    product_key: 12345-67890-12345-67890-12345
    version: 1.0
    comments: This is a test task sequence.
    enabled: true
    hidden: false
    state: present

- name: Create an MDT task sequence and retail product key
  trippsc2.mdt.task_sequence:
    mdt_share_path: C:\\MDTShare
    id: WIN11-ENT
    name: Windows 11 Enterprise
    template: Client.xml
    operating_system_name: Windows 11 Enterprise
    product_key_type: retail
    product_key: 12345-67890-12345-67890-12345
    version: 1.0
    comments: This is a test task sequence.
    enabled: true
    hidden: false
    state: present

- name: Create an MDT task sequence with admin password
  trippsc2.mdt.task_sequence:
    mdt_share_path: C:\\MDTShare
    id: WIN11-ENT
    name: Windows 11 Enterprise
    template: Client.xml
    operating_system_name: Windows 11 Enterprise
    admin_password: Password123!
    version: 1.0
    comments: This is a test task sequence.
    enabled: true
    hidden: false
    state: present

- name: Create an MDT task sequence with paths
  trippsc2.mdt.task_sequence:
    mdt_share_path: C:\\MDTShare
    id: WIN11-ENT
    name: Windows 11 Enterprise
    template: Client.xml
    operating_system_name: Windows 11 Enterprise
    paths:
      set:
        - Windows 11\\Site 1
        - Windows 11\\Site 2
        - Windows 11\\Site 3
    version: 1.0
    comments: This is a test task sequence.
    enabled: true
    hidden: false
    state: present

- name: Remove an task sequence by ID
  trippsc2.mdt.task sequence:
    mdt_share_path: C:\\MDTShare
    id: WIN11-ENT
    state: absent

- name: Remove an task sequence by name
  trippsc2.mdt.task sequence:
    mdt_share_path: C:\\MDTShare
    name: Windows 11 Enterprise
    state: absent
"""

RETURN = r"""
task_sequence:
  type: dict
  returned: O(state=present)
  description:
      - The task sequence information.
  contains:
    guid:
      type: str
      description:
        - The GUID of the task sequence.
    id:
      type: str
      description:
        - The ID of the task sequence.
    name:
      type: str
      description:
        - The name of the task sequence.
    template:
      type: str
      description:
        - The template file name from which the task sequence was imported.
    operating_system:
      type: dict
      description:
        - The operating system deployed by the task sequence.
      contains:
        guid:
          type: str
          description:
            - The GUID of the operating system.
        name:
          type: str
          description:
            - The name of the operating system.
    version:
      type: str
      description:
        - The version of the task sequence.
    product_key_type:
      type: str
      description:
        - The type of private key supplied to the MDT task sequence (retail or mak).
    full_name:
      type: str
      description:
        - The full name of the task sequence.
    organization:
      type: str
      description:
        - The organization name for the task sequence.
    ie_home_page:
      type: str
      description:
        - The home page for Internet Explorer.
    paths:
      type: list
      elements: str
      description:
        - The paths at which the task sequence is found.
    comments:
      type: str
      description:
        - Comments about the task sequence.
    enabled:
      type: bool
      description:
        - Whether the task sequence is enabled.
    hidden:
      type: bool
      description:
        - Whether the task sequence is hidden.
"""
