#!/usr/bin/python
# -*- coding: utf-8 -*-

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r"""
module: application
version_added: 1.1.0
author:
  - Jim Tarpley (@trippsc2)
short_description: Creates, updates, or deletes an MDT application
description:
  - Creates, updates, or deletes an MDT application.
  - This module makes the assumption that a single directory does not contain files for multiple source applications.
  - This assumption is in-line with how the MDT console works.
  - Changing an application's type is permitted and tested, but I would not recommend it for production use because of potential side effects.
extends_documentation_fragment:
  - trippsc2.mdt.action_group
  - trippsc2.mdt.check_mode
  - trippsc2.mdt.common
options:
  guid:
    type: str
    required: false
    description:
      - The GUID of the application.
      - Either O(name) or O(guid) must be provided.
      - The GUID will be used to identify the application.
      - If O(state=absent), O(guid) and O(name) are mutually exclusive.
  name:
    type: str
    required: false
    description:
      - The name of the application.
      - Either O(name) or O(guid) must be provided.
      - If O(guid) is not provided, the name will be used to identify the application.
      - If O(guid) is provided, it will be used to identify the application and the application's name will be set to the provided value.
      - >-
        If not provided, O(state=present), and the application doesn't already exist, the full name will be created from the O(publisher),
        O(short_name), and O(version) options.
      - If O(state=absent), O(guid) and O(name) are mutually exclusive.
  type:
    type: str
    required: false
    choices:
      - source
      - no_source
      - bundle
    description:
      - The type of application.
      - If O(state=present), this is required.
      - If O(state=absent), this should not be provided.
  paths:
    type: dict
    required: false
    description:
      - The expected configuration for paths at which the application should be found.
      - If not provided and the application does not exist, the application will be placed in the V(Applications) folder.
      - If not provided and the application exists, the application will not be moved or copied into any folders.
      - This refers to the logical placement of the application.  For the physical location of application files, see O(destination_folder).
    suboptions:
      add:
        type: list
        required: false
        elements: str
        description:
          - A list of additional paths to add to the application.
          - These paths are relative to the V(Applications) folder within the MDT share.
          - This is mutually exclusive with O(paths.set).
      remove:
        type: list
        required: false
        elements: str
        description:
          - A list of paths to remove from the application.
          - These paths are relative to the V(Applications) folder within the MDT share.
          - This is mutually exclusive with O(paths.set).
          - If the application is not found at any other paths than these, the module will fail.  Use O(state=absent) to remove the application instead.
      set:
        type: list
        required: false
        elements: str
        description:
          - A list of paths to set for the application.
          - These paths are relative to the V(Applications) folder within the MDT share.
          - This is mutually exclusive with O(paths.add) and O(paths.remove).
          - If this is an empty list, the module will fail.  Use O(state=absent) to remove the application instead.
  publisher:
    type: str
    required: false
    description:
      - The publisher of the application.
      - If O(state=absent), this should not be provided.
      - If not provided, the publisher will be left blank.
  short_name:
    type: str
    required: false
    description:
      - The short name of the application, not including the publisher, version, or language information.
      - If O(state=absent), this should not be provided.
      - If O(state=present), this is required.
  version:
    type: str
    required: false
    description:
      - The version of the application.
      - If O(state=absent), this should not be provided.
      - If not provided and O(state=present), the version will be left blank.
  language:
    type: str
    required: false
    description:
      - The language of the application.
      - If O(state=absent), this should not be provided.
      - If not provided and O(state=present), the language will be left blank.
  command_line:
    type: str
    required: false
    description:
      - The command line to run the application.
      - This is the command line that will be executed when the application is run.
      - This command will be run from the O(working_directory).
      - If O(state=absent), this should not be provided.
      - If O(state=present) and O(type=bundle), this should not be provided.
      - If O(state=present) and O(type=source) or O(type=no_source), this is required.
  working_directory:
    type: path
    required: false
    description:
      - The working directory for the application.
      - This is the directory from which the O(command_line) command will be run.
      - If a relative path is provided, it will be relative to the MDT share root.
      - If O(state=absent), this should not be provided.
      - If O(state=absent) and O(type=bundle), this should not be provided.
      - If not provided, O(state=present), and O(destination_folder) is provided, the working directory will be set to the O(destination_folder).
      - If not provided, O(state=present), and O(destination_folder) is not provided, the working directory will not be provided.
  source_path:
    type: path
    required: false
    description:
      - The source path for the application files.
      - This should be a directory containing the application files.
      - If O(state=absent), this should not be provided.
      - If O(state=present) and O(type=bundle) or O(type=no_source), this should not be provided.
      - If O(state=present) and O(type=source), this is required.
  destination_folder:
    type: str
    required: false
    description:
      - The destination folder for the application files.
      - This is a folder relative to the V(Applications) folder within the MDT share.
      - If O(state=absent), this should not be provided.
      - If O(state=present) and O(type=bundle) or O(type=no_source), this should not be provided.
      - >-
        If not provided, O(state=present), and O(type=source), the application files will be placed in a subfolder of the V(Applications) folder
        named after the full name of the Application.
      - This refers to the physical location of the application files.  For the logical placement of the application, see O(paths).
  comments:
    type: str
    required: false
    description:
      - Comments about the application.
      - If O(state=absent), this should not be provided.
      - If not provided and the application exists, the comments will not be changed.
      - If not provided and the application does not exist, the comments will be left blank.
  enabled:
    type: bool
    required: false
    description:
      - Whether the application is enabled.
      - If O(state=absent), this should not be provided.
      - If not provided and the application exists, the enabled state will not be changed.
      - If not provided and the application does not exist, the application will be created enabled.
  hidden:
    type: bool
    required: false
    description:
      - Whether the application is hidden.
      - If O(state=absent), this should not be provided.
      - If not provided and the application exists, the hidden state will not be changed.
      - If not provided and the application does not exist, the application will be created and not be hidden.
  reboot:
    type: bool
    required: false
    description:
      - Whether the application requires a reboot.
      - If O(state=absent), this should not be provided.
      - If not provided and the application exists, the reboot state will not be changed.
      - If not provided and the application does not exist, the application will be created and not require a reboot.
  state:
    type: str
    required: false
    default: present
    choices:
      - present
      - absent
    description:
      - The state of the application.
      - If V(present), the application will be created or updated.
      - If V(absent), the application will be removed.
"""

EXAMPLES = r"""
- name: Create an MDT source application
  trippsc2.mdt.application:
    mdt_share_path: C:\\MDTShare
    type: source
    short_name: 7zip
    version: '24.09'
    command_line: 7z2409-x64.exe /S
    source_path: C:\\Temp\\7zip
    destination_folder: 7zip 24.09
    state: present

- name: Create an MDT no source application
  trippsc2.mdt.application:
    mdt_share_path: C:\\MDTShare
    type: no_source
    short_name: 7zip
    version: '24.09'
    command_line: 7z2409-x64.exe /S
    working_directory: C:\\Temp\\7zip
    state: present

- name: Create an MDT application bundle
  trippsc2.mdt.application:
    mdt_share_path: C:\\MDTShare
    type: bundle
    short_name: 7zip
    version: '24.09'
    state: present

- name: Remove an application
  trippsc2.mdt.application:
    mdt_share_path: C:\\MDTShare
    name: 7zip 24.09
    state: absent
"""

RETURN = r"""
application:
  type: dict
  returned: O(state=present)
  description:
    - The current state of the application.
  contains:
    guid:
      type: str
      description:
        - The GUID of the application.
    name:
      type: str
      description:
        - The full name of the application.
    publisher:
      type: str
      description:
        - The publisher of the application.
    short_name:
      type: str
      description:
        - The short name of the application.
    version:
      type: str
      description:
        - The version of the application.
    language:
      type: str
      description:
        - The language of the application.
    comments:
      type: str
      description:
        - Comments about the application.
    command_line:
      type: str
      description:
        - The command line to run the application.
    working_directory:
      type: str
      description:
        - The working directory for the application.
    enabled:
      type: bool
      description:
        - Whether the application is enabled.
    hidden:
      type: bool
      description:
        - Whether the application is hidden.
    reboot:
      type: bool
      description:
        - Whether the application requires a reboot.
    files_path:
      type: str
      returned: O(source_path) is provided
      description:
        - The source path for the application files.
    paths:
      type: list
      elements: str
      description:
        - The paths at which the application is found.
    files:
      type: list
      elements: dict
      returned: O(source_path) is provided
      description:
        - The list of files in the application source.
      contains:
        path:
          type: str
          description:
            - The relative path of the file within the source path.
        sha256_checksum:
          type: str
          description:
            - The SHA256 checksum of the file.
"""
