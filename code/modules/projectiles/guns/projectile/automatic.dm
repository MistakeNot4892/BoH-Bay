/obj/item/gun/projectile/automatic/smg
	name = "submachine gun"
	desc = "The WT-550 Saber is a cheap self-defense weapon, mass-produced for paramilitary and private use."
	icon = 'icons/obj/guns/sec_smg.dmi'
	icon_state = "smg"
	item_state = "wt550"
	safety_icon = "safety"
	w_class = ITEM_SIZE_NORMAL
	caliber = CALIBER_PISTOL_SMALL
	origin_tech = "{'" + TECH_COMBAT + "':5,'" + TECH_MATERIAL + "':2}"
	slot_flags = SLOT_BELT|SLOT_BACK
	ammo_type = /obj/item/ammo_casing/pistol/small
	load_method = MAGAZINE
	magazine_type = /obj/item/ammo_magazine/smg/rubber
	allowed_magazines = /obj/item/ammo_magazine/smg
	accuracy_power = 7
	one_hand_penalty = 3
	bulk = -1
	fire_sound = 'sound/weapons/gunshot/gunshot_smg.ogg'
	auto_eject = 1
	auto_eject_sound = 'sound/weapons/smg_empty_alarm.ogg'

	//machine pistol, like SMG but easier to one-hand with
	firemodes = list(
		list(mode_name="semi auto",       burst=1, fire_delay=null,    move_delay=null, one_hand_penalty=3, burst_accuracy=null, dispersion=null),
		list(mode_name="3-round bursts", burst=3, fire_delay=null, move_delay=4,    one_hand_penalty=4, burst_accuracy=list(0,-1,-1),       dispersion=list(0.0, 0.6, 1.0)),
		list(mode_name="short bursts",   burst=5, fire_delay=null, move_delay=4,    one_hand_penalty=5, burst_accuracy=list(0,-1,-1,-1,-2), dispersion=list(0.6, 0.6, 1.0, 1.0, 1.2)),
		list(mode_name="full auto",		can_autofire=1, burst=1, fire_delay=1, one_hand_penalty=7, burst_accuracy = list(0,-1,-1,-2,-2,-2,-3,-3), dispersion = list(1.0, 1.0, 1.0, 1.0, 1.2))
		)

/obj/item/gun/projectile/automatic/smg/on_update_icon()
	..()
	if(ammo_magazine)
		overlays += image(icon, "mag-[round(ammo_magazine.stored_ammo.len,5)]")
	if(ammo_magazine && LAZYLEN(ammo_magazine.stored_ammo))
		overlays += image(icon, "ammo-ok")
	else
		overlays += image(icon, "ammo-bad")

/obj/item/gun/projectile/automatic/assault_rifle
	name = "assault rifle"
	desc = "The Z8 Bulldog is an older model bullpup carbine. Makes you feel like a space marine when you hold it."
	icon = 'icons/obj/guns/bullpup_rifle.dmi'
	icon_state = "carbine"
	item_state = "z8carbine"
	w_class = ITEM_SIZE_HUGE
	force = 10
	caliber = CALIBER_RIFLE
	origin_tech = "{'" + TECH_COMBAT + "':8,'" + TECH_MATERIAL + "':3}"
	ammo_type = /obj/item/ammo_casing/rifle
	slot_flags = SLOT_BACK
	load_method = MAGAZINE
	magazine_type = /obj/item/ammo_magazine/rifle
	allowed_magazines = /obj/item/ammo_magazine/rifle
	auto_eject = 1
	auto_eject_sound = 'sound/weapons/smg_empty_alarm.ogg'
	accuracy = 2
	accuracy_power = 7
	one_hand_penalty = 8
	bulk = GUN_BULK_RIFLE
	burst_delay = 4
	wielded_item_state = "z8carbine-wielded"
	mag_insert_sound = 'sound/weapons/guns/interaction/batrifle_magin.ogg'
	mag_remove_sound = 'sound/weapons/guns/interaction/batrifle_magout.ogg'
	firemodes = list(
		list(mode_name="semi auto",       burst=1,    fire_delay=null,    move_delay=null, use_launcher=null, one_hand_penalty=8, burst_accuracy=null, dispersion=null),
		list(mode_name="3-round bursts", burst=3,    fire_delay=null, move_delay=6,    use_launcher=null, one_hand_penalty=9, burst_accuracy=list(0,-1,-1), dispersion=list(0.0, 0.6, 1.0)),
		list(mode_name="fire grenades",  burst=null, fire_delay=null, move_delay=null, use_launcher=1,    one_hand_penalty=10, burst_accuracy=null, dispersion=null)
		)

	var/use_launcher = 0
	var/obj/item/gun/launcher/grenade/underslung/launcher

/obj/item/gun/projectile/automatic/assault_rifle/Initialize()
	. = ..()
	launcher = new(src)

/obj/item/gun/projectile/automatic/assault_rifle/attackby(obj/item/I, mob/user)
	if((istype(I, /obj/item/grenade)))
		launcher.load(I, user)
	else
		..()

/obj/item/gun/projectile/automatic/assault_rifle/attack_hand(mob/user)
	if(user.get_inactive_hand() == src && use_launcher)
		launcher.unload(user)
	else
		..()

/obj/item/gun/projectile/automatic/assault_rifle/Fire(atom/target, mob/living/user, params, pointblank=0, reflex=0)
	if(use_launcher)
		launcher.Fire(target, user, params, pointblank, reflex)
		if(!launcher.chambered)
			switch_firemodes() //switch back automatically
	else
		..()

/obj/item/gun/projectile/automatic/assault_rifle/on_update_icon()
	..()
	if(ammo_magazine)
		if(ammo_magazine.stored_ammo.len)
			icon_state = "carbine-loaded"
		else
			icon_state = "carbine-empty"
	else
		icon_state = "carbine"

/obj/item/gun/projectile/automatic/assault_rifle/examine(mob/user)
	. = ..()
	if(launcher.chambered)
		to_chat(user, "\The [launcher] has \a [launcher.chambered] loaded.")
	else
		to_chat(user, "\The [launcher] is empty.")

/obj/item/weapon/gun/projectile/automatic/l6_saw
	name = "light machine gun"
	desc = "A rather traditionally made L6 SAW with a pleasantly lacquered wooden pistol grip. Has 'Aussec Armoury- 2281' engraved on the reciever." //probably should refluff this
	icon = 'icons/obj/guns/saw.dmi'
	icon_state = "l6closed50"
	item_state = "l6closedmag"
	w_class = ITEM_SIZE_HUGE
	bulk = 10
	force = 10
	slot_flags = 0
	max_shells = 50
	caliber = CALIBER_RIFLE
	origin_tech = list(TECH_COMBAT = 6, TECH_MATERIAL = 1, TECH_ESOTERIC = 2)
	slot_flags = 0 //need sprites for SLOT_BACK
	ammo_type = /obj/item/ammo_casing/rifle
	load_method = MAGAZINE
	magazine_type = /obj/item/ammo_magazine/box/machinegun
	allowed_magazines = list(/obj/item/ammo_magazine/box/machinegun, /obj/item/ammo_magazine/rifle)
	one_hand_penalty = 10
	wielded_item_state = "gun_wielded"
	mag_insert_sound = 'sound/weapons/guns/interaction/lmg_magin.ogg'
	mag_remove_sound = 'sound/weapons/guns/interaction/lmg_magout.ogg'

	//LMG, better sustained fire accuracy than assault rifles (comparable to SMG), higer move delay and one-handing penalty
	//No single-shot or 3-round-burst modes since using this weapon should come at a cost to flexibility.
	firemodes = list(
		list(mode_name="short bursts",	can_autofire=0, burst=5, fire_delay=5, move_delay=12, one_hand_penalty=8, burst_accuracy = list(0,-1,-1,-2,-2),          dispersion = list(0.6, 1.0, 1.0, 1.0, 1.2)),
		list(mode_name="long bursts",	can_autofire=0, burst=8, fire_delay=5, one_hand_penalty=12, burst_accuracy = list(0,-1,-1,-2,-2,-2,-3,-3), dispersion = list(1.0, 1.0, 1.0, 1.0, 1.2)),
		list(mode_name="full auto",		can_autofire=1, burst=4, fire_delay=1, one_hand_penalty=12, burst_accuracy = list(0,-1,-1,-2,-2,-2,-3,-3), dispersion = list(1.0, 1.0, 1.0, 1.0, 1.2)),
		)

	var/cover_open = 0

/obj/item/weapon/gun/projectile/automatic/l6_saw/mag
	magazine_type = /obj/item/ammo_magazine/rifle

/obj/item/weapon/gun/projectile/automatic/l6_saw/special_check(mob/user)
	if(cover_open)
		to_chat(user, "<span class='warning'>[src]'s cover is open! Close it before firing!</span>")
		return 0
	return ..()

/obj/item/weapon/gun/projectile/automatic/l6_saw/proc/toggle_cover(mob/user)
	cover_open = !cover_open
	to_chat(user, "<span class='notice'>You [cover_open ? "open" : "close"] [src]'s cover.</span>")
	update_icon()

/obj/item/weapon/gun/projectile/automatic/l6_saw/attack_self(mob/user as mob)
	if(cover_open)
		toggle_cover(user) //close the cover
	else
		return ..() //once closed, behave like normal

/obj/item/weapon/gun/projectile/automatic/l6_saw/attack_hand(mob/user as mob)
	if(!cover_open && user.get_inactive_hand() == src)
		toggle_cover(user) //open the cover
	else
		return ..() //once open, behave like normal

/obj/item/weapon/gun/projectile/automatic/l6_saw/on_update_icon()
	..()
	if(istype(ammo_magazine, /obj/item/ammo_magazine/box))
		icon_state = "l6[cover_open ? "open" : "closed"]"
		item_state = "l6[cover_open ? "open" : "closed"]"
	else if(ammo_magazine)
		icon_state = "l6[cover_open ? "open" : "closed"]mag"
		item_state = "l6[cover_open ? "open" : "closed"]mag"
	else
		icon_state = "l6[cover_open ? "open" : "closed"]-empty"
		item_state = "l6[cover_open ? "open" : "closed"]-empty"

/obj/item/weapon/gun/projectile/automatic/l6_saw/load_ammo(var/obj/item/A, mob/user)
	if(!cover_open)
		to_chat(user, "<span class='warning'>You need to open the cover to load that into [src].</span>")
		return
	..()

/obj/item/weapon/gun/projectile/automatic/l6_saw/unload_ammo(mob/user, var/allow_dump=1)
	if(!cover_open)
		to_chat(user, "<span class='warning'>You need to open the cover to unload [src].</span>")
		return
	..()
