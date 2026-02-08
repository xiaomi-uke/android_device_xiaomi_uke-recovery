#!/system/bin/sh

DEBUG=0
[ "$DEBUG" = "1" ] && set -o xtrace;

LOGMSG() {
	echo "I:$@" >> /tmp/recovery.log
}

quit() {
	LOGMSG "$@ is loaded";
}

load_drivers() {
	local path1=/lib/modules;
	local path2=/vendor/lib/modules/1.1;
	local modules="adsp_loader_dlkm focaltech_3683g focaltech_touch goodix_core goodix_ts gpr_dlkm \
								nxp-nci panel_event_notifier pdr_interface pmic_glink q6_notifier_dlkm q6_pdr_dlkm \
								qcom_glink qcom_glink_smem qcom_pil_info qcom_q6v5 qcom_q6v5_pas qcom_ramdump qcom_smd qcom_sysmon \
								qmi_helpers qti_battery_charger rproc_qcom_common snd_event_dlkm spf_core_dlkm xiaomi_touch"

	# loop through the modules
	for i in $modules; do
		# check whether the module is already loaded
		if lsmod | grep "^$i"; then
			quit "$i"
			continue
		fi

		# try to load the module
		insmod "$path1/$i.ko"
		if lsmod | grep "^$i"; then
			quit "$i"
			continue
		fi

		insmod "$path2/$i.ko"
		if lsmod | grep "^$i"; then
			quit "$i"
			continue
		fi

		# module failed to load from all paths
		LOGMSG "$i failed to load"
	done
}

SCRIPT_NAME="$(basename "$0")"

LOGMSG "---$SCRIPT_NAME start---"

load_drivers

LOGMSG "Resetting touchscreen post screen blank..."
echo 1 > /sys/devices/platform/goodix_ts.0/irq_info
echo 1 > /sys/devices/platform/goodix_ts.0/reset

LOGMSG "---$SCRIPT_NAME end---"
exit 0
