#!/usr/bin/python
# -*- coding: utf-8 -*-

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r"""
module: boot_image
version_added: 1.1.0
author:
  - Jim Tarpley
short_description: Creates or updates an MDT boot image
description:
  - Creates or updates an MDT boot image.
  - This module cannot be guaranteed to be idempotent.  The boot image SHA256 hash is used to determine if the boot image was changed, but changes are not necessarily meaningful.
  - This module only accounts for x64 boot images, as there are no supported x86 Windows versions.
attributes:
  check_mode:
    support: none
    details:
      - Does not support check mode.
options:
  installation_path:
    type: path
    required: false
    default: C:\\Program Files\\Microsoft Deployment Toolkit
    description:
      - The path to the MDT installation directory.
  compress:
    type: bool
    required: false
    default: false
    description:
      - Whether to compress the boot image.
      - When O(force=true), this option is ignored.
  force:
    type: bool
    required: false
    default: false
    description:
      - Whether to discard the existing boot image and create a new one.
  mdt_share_path:
    type: path
    required: true
    description:
      - The path to the MDT directory.
"""

EXAMPLES = r"""
- name: Generate boot image
  trippsc2.mdt.boot_image:
    installation_path: C:\\Program Files\\Microsoft Deployment Toolkit
    mdt_share_path: C:\\DeploymentShare

- name: Generate and compress boot image
  trippsc2.mdt.boot_image:
    installation_path: C:\\Program Files\\Microsoft Deployment Toolkit
    mdt_share_path: C:\\DeploymentShare
    compress: true

- name: Re-generate boot image
  trippsc2.mdt.boot_image:
    installation_path: C:\\Program Files\\Microsoft Deployment Toolkit
    mdt_share_path: C:\\DeploymentShare
    force: true
"""

RETURN = r"""
litetouch_wim:
  type: dict
  returned:
    - success
  description:
    - The LiteTouch WIM file information.
  options:
    path:
      type: path
      description:
        - The path to the LiteTouch WIM file.
    sha256_hash:
      type: str
      description:
        - The current SHA256 hash of the LiteTouch WIM file.
    sha256_hash_previous:
      type: str
      description:
        - The previous SHA256 hash of the LiteTouch WIM file.
        - This is only included if the LiteTouch WIM file was updated.
litetouch_iso:
  type: dict
  returned:
    - success
  description:
    - The LiteTouch ISO file information.
    - This is only included if the LiteTouch ISO is generated.
  options:
    path:
      type: path
      description:
        - The path to the LiteTouch ISO file.
    sha256_hash:
      type: str
      description:
        - The current SHA256 hash of the LiteTouch ISO file.
    sha256_hash_previous:
      type: str
      description:
        - The previous SHA256 hash of the LiteTouch ISO file.
        - This is only included if the LiteTouch ISO file was updated.
generic_wim:
  type: dict
  returned:
    - success
  description:
    - The generic WIM file information.
    - This is only included if the generic WIM is generated.
  options:
    path:
      type: path
      description:
        - The path to the generic WIM file.
    sha256_hash:
      type: str
      description:
        - The current SHA256 hash of the generic WIM file.
    sha256_hash_previous:
      type: str
      description:
        - The previous SHA256 hash of the generic WIM file.
        - This is only included if the generic WIM file was updated.
generic_iso:
  type: dict
  returned:
    - success
  description:
    - The generic ISO file information.
    - This is only included if the generic ISO is generated.
  options:
    path:
      type: path
      description:
        - The path to the generic ISO file.
    sha256_hash:
      type: str
      description:
        - The current SHA256 hash of the generic ISO file.
    sha256_hash_previous:
      type: str
      description:
        - The previous SHA256 hash of the generic ISO file.
        - This is only included if the generic ISO file was updated.
"""
