/obj/item/clothing/suit/bio_suit/anomaly
	name = "Anomaly suit"
	desc = "A suit that protects against exotic alien energies and biological contamination."
	icon_state = "bio_anom"
	max_pressure_protection = FIRESUIT_MAX_PRESSURE
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/head/bio_hood/anomaly
	name = "Anomaly hood"
	desc = "A hood that protects the head and face from exotic alien energies and biological contamination."
	icon_state = "bio_anom"
	item_state = "bio_anom"
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE
	max_pressure_protection = FIRESUIT_MAX_PRESSURE

/obj/item/clothing/suit/space/void/excavation
	name = "excavation voidsuit"
	desc = "A specially shielded voidsuit that insulates against some exotic alien energies, as well as the more mundane dangers of excavation."
	icon_state = "rig-excavation"
	armor = list(
		melee = ARMOR_MELEE_RESISTANT,
		energy = ARMOR_ENERGY_RESISTANT,
		bomb = ARMOR_BOMB_PADDED,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_SHIELDED
	)
	allowed = list(/obj/item/flashlight,/obj/item/tank,/obj/item/suit_cooling_unit,/obj/item/stack/flag,/obj/item/storage/excavation,/obj/item/pickaxe,/obj/item/scanner/health,/obj/item/measuring_tape,/obj/item/ano_scanner,/obj/item/depth_scanner,/obj/item/core_sampler,/obj/item/gps,/obj/item/pinpointer/radio,/obj/item/radio/beacon,/obj/item/pickaxe/xeno,/obj/item/storage/bag/fossils)

/obj/item/clothing/head/helmet/space/void/excavation
	name = "excavation voidsuit helmet"
	desc = "A sophisticated voidsuit helmet, capable of protecting the wearer from many exotic alien energies."
	icon_state = "rig0-excavation"
	item_state = "excavation-helm"
	armor = list(
		melee = ARMOR_MELEE_RESISTANT,
		energy = ARMOR_ENERGY_RESISTANT,
		bomb = ARMOR_BOMB_PADDED,
		bio = ARMOR_BIO_SHIELDED,
		rad = ARMOR_RAD_SHIELDED
	)
	light_overlay = "hardhat_light"

/obj/item/clothing/suit/space/void/excavation/prepared
	helmet = /obj/item/clothing/head/helmet/space/void/excavation

/obj/item/storage/belt/archaeology
	name = "excavation gear-belt"
	desc = "Can hold various excavation gear."
	icon_state = "gearbelt"
	item_state = ACCESSORY_SLOT_UTILITY
	can_hold = list(
		/obj/item/storage/box/samplebags,
		/obj/item/core_sampler,
		/obj/item/pinpointer/radio,
		/obj/item/radio/beacon,
		/obj/item/gps,
		/obj/item/measuring_tape,
		/obj/item/flashlight,
		/obj/item/pickaxe,
		/obj/item/depth_scanner,
		/obj/item/camera,
		/obj/item/paper,
		/obj/item/photo,
		/obj/item/folder,
		/obj/item/pen,
		/obj/item/folder,
		/obj/item/material/clipboard,
		/obj/item/anodevice,
		/obj/item/clothing/glasses,
		/obj/item/wrench,
		/obj/item/storage/excavation,
		/obj/item/anobattery,
		/obj/item/ano_scanner,
		/obj/item/taperoll,
		/obj/item/pickaxe/xeno/hand)