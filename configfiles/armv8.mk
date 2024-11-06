# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2020 Tobias Maedel

define Device/rk3399_tpm312
  DEVICE_VENDOR := RK3399
  DEVICE_MODEL := TPM312
  SOC := rk3399
  SUPPORTED_DEVICES := rk3399,tpm312
  UBOOT_DEVICE_NAME := tpm312-rk3399
  IMAGE/sysupgrade.img.gz := boot-common | boot-script | pine64-img | gzip | append-metadata
endef
TARGET_DEVICES += rk3399_tpm312
