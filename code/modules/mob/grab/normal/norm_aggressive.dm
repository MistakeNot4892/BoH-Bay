/decl/grab/normal/aggressive
	name = "aggressive grab"
	upgrab =   /decl/grab/normal/neck
	downgrab = /decl/grab/normal/passive
	shift = 12
	stop_move = 1
	reverse_facing = 0
	can_absorb = 0
	shield_assailant = 0
	point_blank_mult = 1.5
	damage_stage = 1
	same_tile = 0
	can_throw = 1
	force_danger = 1
	breakability = 3
	icon_state = "reinforce1"
	break_chance_table = list(5, 20, 40, 80, 100)

/decl/grab/normal/aggressive/process_effect(var/obj/item/grab/G)
	var/mob/affecting_mob = G.get_affecting_mob()
	if(istype(affecting_mob))
		if(G.target_zone in list(BP_L_HAND, BP_R_HAND))
			affecting_mob.drop_l_hand()
			affecting_mob.drop_r_hand()
		// Keeps those who are on the ground down
		if(affecting_mob.lying)
			affecting_mob.Weaken(4)

	// Keeps those who are on the ground down - mostly
	if(affecting.lying && prob(50))
		affecting.Weaken(2)

/datum/grab/normal/aggressive/can_upgrade(var/obj/item/grab/G)
	if(!(G.target_zone in list(BP_CHEST, BP_HEAD)))
		to_chat(G.assailant, "<span class='warning'>You need to be grabbing their torso or head for this!</span>")
		return FALSE
	var/obj/item/clothing/C = G.affecting.head
	if(istype(C)) //hardsuit helmets etc
		if((C.max_pressure_protection) && C.armor["melee"] > 20)
			to_chat(G.assailant, "<span class='warning'>\The [C] is in the way!</span>")
			return FALSE
		if(!(G.target_zone in list(BP_CHEST, BP_HEAD)))
			to_chat(G.assailant, SPAN_WARNING("You need to be grabbing their torso or head for this!"))
			return FALSE
		var/mob/living/carbon/human/affecting_mob = G.get_affecting_mob()
		if(istype(affecting_mob))
			var/obj/item/clothing/C = affecting_mob.head
			if(istype(C)) //hardsuit helmets etc
				if((C.max_pressure_protection) && C.armor["melee"] > 20)
					to_chat(G.assailant, SPAN_WARNING("\The [C] is in the way!"))
					return FALSE
