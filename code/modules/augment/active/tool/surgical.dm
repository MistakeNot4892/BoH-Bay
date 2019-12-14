/obj/item/organ/internal/augment/active/polytool/surgical
	name = "surgical toolset"
	action_button_name = "Deploy Surgical Tool"
	desc = "Part of a line of biomedical augmentations, this device contains the full set of tools any surgeon would ever need."
	paths = list(
		/obj/item/bonesetter,
		/obj/item/cautery,
		/obj/item/circular_saw,
		/obj/item/hemostat,
		/obj/item/retractor,
		/obj/item/scalpel,
		/obj/item/surgicaldrill
	)

/obj/item/organ/internal/augment/active/polytool/surgical/left
	allowed_organs = list(BP_AUGMENT_L_ARM)

/obj/item/organ/internal/augment/active/polytool/surgical/right
	allowed_organs = list(BP_AUGMENT_R_ARM)