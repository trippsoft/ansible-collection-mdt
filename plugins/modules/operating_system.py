#!/usr/bin/python
# -*- coding: utf-8 -*-

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r"""
module: operating_system
version_added: 1.1.0
author:
  - Jim Tarpley (@trippsc2)
short_description: Creates, updates, or deletes an MDT operating system
description:
  - Creates, updates, or deletes an MDT operating system.
extends_documentation_fragment:
  - trippsc2.mdt.action_group
  - trippsc2.mdt.check_mode
  - trippsc2.mdt.common
options:
  guid:
    type: str
    required: false
    description:
      - The GUID of the operating system.
      - Either O(name) or O(guid) must be provided.
      - The GUID will be used to identify the operating system.
      - If O(state=absent), O(guid) and O(name) are mutually exclusive.
  name:
    type: str
    required: false
    description:
      - The name of the operating system.
      - Either O(name) or O(guid) must be provided.
      - If O(guid) is not provided, the name will be used to identify the operating system.
      - If O(guid) is provided, it will be used to identify the operating system and the operating system's name will be set to the provided value.
      - >-
        If not provided, O(state=present), and the operating system doesn't already exist, the name will be created from the image name, destination folder,
        and WIM file name.
      - If O(state=absent), O(guid) and O(name) are mutually exclusive.
  paths:
    type: dict
    required: false
    description:
      - The expected configuration for paths at which the operating system should be found.
      - If not provided and the operating system does not exist, the operating system will be placed in the V(Operating Systems) folder.
      - If not provided and the operating system exists, the operating system will not be moved or copied into any folders.
      - This refers to the logical placement of the operating system.  For the physical location of operating system files, see O(destination_folder).
    suboptions:
      add:
        type: list
        required: false
        elements: str
        description:
          - A list of additional paths to add to the operating system.
          - These paths are relative to the V(Operating Systems) folder within the MDT share.
          - This is mutually exclusive with O(paths.set).
      remove:
        type: list
        required: false
        elements: str
        description:
          - A list of paths to remove from the operating system.
          - These paths are relative to the V(Operating Systems) folder within the MDT share.
          - This is mutually exclusive with O(paths.set).
          - >-
            If the operating system is not found at any other paths than these, the module will fail.
            Use O(state=absent) to remove the operating system instead.
      set:
        type: list
        required: false
        elements: str
        description:
          - A list of paths to set for the operating system.
          - These paths are relative to the V(Operating Systems) folder within the MDT share.
          - This is mutually exclusive with O(paths.add) and O(paths.remove).
          - If this is an empty list, the module will fail.  Use O(state=absent) to remove the operating system instead.
  type:
    type: str
    required: false
    choices:
      - source
      - wim
    description:
      - The type of operating system.
      - If O(state=present), this is required.
      - If O(state=absent), this should not be provided.
  source_path:
    type: path
    required: false
    description:
      - The source path for the operating system file(s).
      - If O(state=absent), this should not be provided.
      - If O(state=present), this is required.
      - If O(state=present) and O(type=source), this is the path to the directory containing the installation media files.
      - This installation media files must have an install.wim (not install.esd) file in the sources subdirectory.
      - If O(state=present) and O(type=wim), this is the path to the WIM file.
  destination_folder:
    type: str
    required: false
    description:
      - The destination folder for the operating system files.
      - This is a folder relative to the V(Operating Systems) folder within the MDT share.
      - If O(state=absent), this should not be provided.
      - If O(state=present), this is required.
      - This refers to the physical location of the operating system files.  For the logical placement of the operating system, see O(paths).
  image_index:
    type: int
    required: false
    description:
      - The index of the image in the WIM file to use.
      - If O(state=absent), this should not be provided.
      - This is mutually exclusive with O(image_name) and O(image_edition_id). One of these must be provided.
  image_name:
    type: str
    required: false
    description:
      - The name used to identify the image index in the WIM file to use.
      - If O(state=absent), this should not be provided.
      - This is mutually exclusive with O(image_index) and O(image_edition_id). One of these must be provided.
  image_edition_id:
    type: str
    required: false
    description:
      - The edition ID used to identify the image index in the WIM file to use.
      - If O(state=absent), this should not be provided.
      - This is mutually exclusive with O(image_index) and O(image_name). One of these must be provided.
  comments:
    type: str
    required: false
    description:
      - Comments about the operating system.
      - If O(state=absent), this should not be provided.
      - If not provided and the operating system exists, the comments will not be changed.
      - If not provided and the operating system does not exist, the comments will be left blank.
  enabled:
    type: bool
    required: false
    description:
      - Whether the operating system is enabled.
      - If O(state=absent), this should not be provided.
      - If not provided and the operating system exists, the enabled state will not be changed.
      - If not provided and the operating system does not exist, the operating system will be created enabled.
  hidden:
    type: bool
    required: false
    description:
      - Whether the operating system is hidden.
      - If O(state=absent), this should not be provided.
      - If not provided and the operating system exists, the hidden state will not be changed.
      - If not provided and the operating system does not exist, the operating system will be created and not be hidden.
  state:
    type: str
    required: false
    default: present
    choices:
      - present
      - absent
    description:
      - The state of the operating system.
      - If V(present), the operating system will be created or updated.
      - If V(absent), the operating system will be removed.
"""

EXAMPLES = r"""
- name: Create an MDT operating system from source files by ID
  trippsc2.mdt.operating_system:
    mdt_share_path: C:\\MDTShare
    type: source
    name: Windows 11 Enterprise
    source_path: C:\\temp\\win11
    destination_folder: Windows 11
    image_index: 6
    state: present

- name: Create an MDT operating system from source files by name
  trippsc2.mdt.operating_system:
    mdt_share_path: C:\\MDTShare
    type: source
    name: Windows 11 Enterprise
    source_path: C:\\temp\\win11
    destination_folder: Windows 11
    image_name: Windows 11 Enterprise
    state: present

- name: Create an MDT operating system from source files by edition ID
  trippsc2.mdt.operating_system:
    mdt_share_path: C:\\MDTShare
    type: source
    name: Windows 11 Enterprise
    source_path: C:\\temp\\win11
    destination_folder: Windows 11
    image_edition_id: Enterprise
    state: present

- name: Create an MDT operating system from WIM file by ID
  trippsc2.mdt.operating system:
    mdt_share_path: C:\\MDTShare
    type: wim
    name: Windows 11 Enterprise
    source_path: C:\\temp\\win11\\install.wim
    destination_folder: Windows 11
    image_index: 6
    state: present

- name: Create an MDT operating system from WIM file by name
  trippsc2.mdt.operating system:
    mdt_share_path: C:\\MDTShare
    type: wim
    name: Windows 11 Enterprise
    source_path: C:\\temp\\win11\\install.wim
    destination_folder: Windows 11
    image_name: Windows 11 Enterprise
    state: present

- name: Create an MDT operating system from WIM file by edition ID
  trippsc2.mdt.operating system:
    mdt_share_path: C:\\MDTShare
    type: wim
    name: Windows 11 Enterprise
    source_path: C:\\temp\\win11\\install.wim
    destination_folder: Windows 11
    image_edition_id: Enterprise
    state: present

- name: Remove an operating system
  trippsc2.mdt.operating system:
    mdt_share_path: C:\\MDTShare
    name: Windows 11 Enterprise
    state: absent
"""

RETURN = r"""
operating_system:
  type: dict
  returned: O(state=present)
  description:
    - The current state of the operating system.
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
    files:
      type: list
      elements: dict
      returned: Source files were provided
      description:
        - The list of source files that were changed.
      contains:
        path:
          type: str
          description:
            - The path to the file.
            - The file paths are relative to the source files path (or destination path).
        sha256_checksum:
          type: str
          description:
            - The SHA256 checksum of the file.
"""
