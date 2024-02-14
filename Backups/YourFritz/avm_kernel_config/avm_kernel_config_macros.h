/* vim: set tabstop=4 syntax=asm : */
/* SPDX-License-Identifier: GPL-2.0-or-later */
#ifndef _AVM_KERNEL_CONFIG_MACROS_H
#define _AVM_KERNEL_CONFIG_MACROS_H

	.macro	AVM_KERNEL_CONFIG_START
		.section	"configarea", "a", %progbits
.L_avm_kernel_config_first_byte:
	.endm

	.macro	AVM_KERNEL_CONFIG_END
.L_avm_kernel_config_last_byte:
	.endm

	.macro	AVM_KERNEL_CONFIG_PTR
		.int		.L_avm_kernel_config_entries
		.align		4
	.endm

	.macro	AVM_KERNEL_CONFIG_ENTRY tag, label
		.int		\tag
		.ifeq		\tag
			.int	0
			.align	4
		.else
			.int	.L_avm_\label
		.endif
	.endm

	.macro	AVM_VERSION_INFO buildnumber, svnversion, firmwarestring
		.align		3
.L_avm_version_info:
1:
		.ascii		"\buildnumber"
		.zero		32 - (. - 1b)
2:
		.ascii		"\svnversion"
		.zero		32 - (. - 2b)
3:
		.ascii		"\firmwarestring"
		.zero		128 - (. - 3b)
	.endm

	.macro	AVM_MODULE_MEMORY index, module, core_size, symbol_size, symbol_text_size
		.ifeq	\index
			.int		0
			.int		0
			.int		0
			.int		0
		.else
			.pushsection	"configareastrings", "a", %progbits
.L_avm_module_memory_\index:
			.asciz		"\module"
			.align		2
			.popsection
			.int		.L_avm_module_memory_\index
			.int		\core_size
			.int		\symbol_size
			.int		\symbol_text_size
		.endif
	.endm

	.macro	AVM_DEVICE_TREE_BLOB subrevision
	.endm

	.macro	AVM_DEVICE_TREE subrevision
		.int		avm_kernel_config_tags_device_tree_subrev_\subrevision
		.int		._L_avm_device_tree_\subrevision
	.endm

#endif
