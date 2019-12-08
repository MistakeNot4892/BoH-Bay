//Cloning revival method.
//The pod handles the actual cloning while the computer manages the clone profiles

//Potential replacement for genetics revives or something I dunno (?)

//Find a dead mob with a brain and client.

#define CLONE_BIOMASS 30 //VOREstation Edit

/obj/machinery/clonepod
	name = "cloning pod"
	desc = "An electronically-lockable pod for growing organic tissue."
	density = 1
	anchored = 1
	icon = 'icons/obj/cloning.dmi'
	icon_state = "pod_0"
	req_access = list(access_genetics) // For premature unlocking.
	var/mob/living/occupant
	var/heal_level = 20				// The clone is released once its health reaches this level.
	var/heal_rate = 1
	var/locked = 0
	var/obj/machinery/computer/cloning/connected = null //So we remember the connected clone machine.
	var/mess = 0					// Need to clean out it if it's full of exploded clone.
	var/attempting = 0				// One clone attempt at a time thanks
	var/eject_wait = 0				// Don't eject them as soon as they are created fuckkk

	var/list/containers = list()	// Beakers for our liquid biomass
	var/container_limit = 3			// How many beakers can the machine hold?

/obj/machinery/clonepod/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/stock_parts/manipulator(src)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(src)
	component_parts += new /obj/item/weapon/stock_parts/scanning_module(src)
	component_parts += new /obj/item/weapon/stock_parts/scanning_module(src)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(src)
	component_parts += new /obj/item/stack/cable_coil(src, 2)

	RefreshParts()
	update_icon()

/obj/machinery/clonepod/attack_ai(mob/user as mob)
	add_hiddenprint(user)
	return attack_hand(user)

/obj/machinery/clonepod/attack_hand(mob/user as mob)
	if((isnull(occupant)) || (stat & NOPOWER))
		return
	if((!isnull(occupant)) && (occupant.stat != 2))
		var/completion = (100 * ((occupant.health + 50) / (heal_level + 100))) // Clones start at -150 health
		to_chat(user, "Current clone cycle is [round(completion)]% complete.")
	return

//Start growing a human clone in the pod!
/obj/machinery/clonepod/proc/growclone(var/datum/dna2/record/R)
	if(mess || attempting)
		return 0
/*no modifiers in bay yet
	for(var/modifier_type in R.genetic_modifiers)	//Can't be cloned, even if they had a previous scan
		if(istype(modifier_type, /datum/modifier/no_clone))
			return 0
*/
	// Remove biomass when the cloning is started, rather than when the guy pops out
	remove_biomass(CLONE_BIOMASS)

	attempting = 1 //One at a time!!
	locked = 1

	eject_wait = 1
	spawn(30)
		eject_wait = 0

	var/mob/living/carbon/human/H = new /mob/living/carbon/human(src, R.dna.species)
	occupant = H

	if(!R.dna.real_name)	//to prevent null names
		R.dna.real_name = "clone ([rand(0,999)])"
	H.real_name = R.dna.real_name
	H.gender = R.gender
	H.descriptors = R.body_descriptors

	//Get the clone body ready
	H.adjustCloneLoss(H.maxHealth/2) // We want to put them exactly at the crit level, so we deal this much clone damage
	H.Paralyse(4)

	//Here let's calculate their health so the pod doesn't immediately eject them!!!
	H.updatehealth()

	if(!R.dna)
		H.dna = new /datum/dna()
		H.dna.real_name = H.real_name
	else
		H.dna = R.dna
	H.UpdateAppearance()
	H.sync_organ_dna()
	if(heal_level < 60)
		randmutb(H) //Sometimes the clones come out wrong.
		H.dna.UpdateSE()
		H.dna.UpdateUI()

	H.set_cloned_appearance()
	update_icon()
/*no modifiers in bay yet
	// A modifier is added which makes the new clone be unrobust.
	var/modifier_lower_bound = 25 MINUTES
	var/modifier_upper_bound = 40 MINUTES

	// Upgraded cloners can reduce the time of the modifier, up to 80%
	var/clone_sickness_length = abs(((heal_level - 20) / 100 ) - 1)
	clone_sickness_length = between(0.2, clone_sickness_length, 1.0) // Caps it off just incase.
	modifier_lower_bound = round(modifier_lower_bound * clone_sickness_length, 1)
	modifier_upper_bound = round(modifier_upper_bound * clone_sickness_length, 1)

	H.add_modifier(H.species.cloning_modifier, rand(modifier_lower_bound, modifier_upper_bound))

	// Modifier that doesn't do anything.
	H.add_modifier(/datum/modifier/cloned)

	// This is really stupid.
	for(var/modifier_type in R.genetic_modifiers)
		H.add_modifier(modifier_type)
*/
	for(var/datum/language/L in R.languages)
		H.add_language(L.name)

	H.flavor_texts = R.flavor.Copy()
	H.suiciding = 0
	attempting = 0
	return 1

/obj/machinery/clonepod/proc/GetCloneReadiness()
	if(!occupant)
		return 1


	if(occupant.getCloneLoss() < 45 ) // still going to need some finishing
		return 1

	else
		return 0
//Grow clones to maturity then kick them out.  FREELOADERS
/obj/machinery/clonepod/Process()
	if(stat & NOPOWER) //Autoeject if power is lost
		if(occupant)
			locked = 0
			go_out()
		return

	if((occupant) && (occupant.loc == src))

		if(GetCloneReadiness() && !eject_wait)
			playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)
			src.audible_message("\The [src] signals that the cloning process is complete.")
			connected_message("Cloning Process Complete.")
			locked = 0
			go_out()
			return

		occupant.Paralyse(4)

		//Slowly get that clone healed and finished.
		occupant.adjustCloneLoss(-2 * heal_rate)

		//Premature clones may have brain damage.
		occupant.adjustBrainLoss(-(ceil(0.5*heal_rate)))

		//So clones don't die of oxyloss in a running pod.
		if(occupant.reagents.get_reagent_amount(/datum/reagent/inaprovaline) < 30)
			occupant.reagents.add_reagent(/datum/reagent/inaprovaline, 60)
		occupant.Sleeping(30)
		//Also heal some oxyloss ourselves because inaprovaline is so bad at preventing it!!
		occupant.adjustOxyLoss(-4)

		use_power_oneoff(7500) //This might need tweaking.
		return
	else if((!occupant) || (occupant.loc != src))
		occupant = null
		if(locked)
			locked = 0
		return

	return


//Used for new human mobs created by cloning/goleming/etc.
/mob/living/carbon/human/proc/set_cloned_appearance()
	f_style = "Shaved"
	if(dna.species == "Human") //no more xenos losing ears/tentacles
		h_style = pick("Bedhead", "Bedhead 2", "Bedhead 3")
	worn_underwear.Cut()
	regenerate_icons()



//Let's unlock this early I guess.  Might be too early, needs tweaking.
/obj/machinery/clonepod/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(isnull(occupant))

		if(!istype(W, /obj/item/weapon/screwdriver))
			return
		playsound(src, W.usesound, 50, 1)
		panel_open = !panel_open
		to_chat(user, "<span class='notice'>You [panel_open ? "open" : "close"] the maintenance hatch of [src].</span>")
		update_icon()
		return

		if(!istype(W, /obj/item/weapon/storage/part_replacer))
			display_parts(user)
		return
/*test
		if(!component_parts)
			return
		if(panel_open)
			var/obj/item/weapon/stock_parts/circuitboard/CB = /obj/item/weapon/stock_parts/circuitboard/clonepod
			var/P
			for(var/obj/item/weapon/stock_parts/A in component_parts)
				for(var/T in CB.req_components)
					if(ispath(A.type, T))
						P = T
						break
				for(var/obj/item/weapon/stock_parts/B in R.contents)
					if(istype(B, P) && istype(A, P))
						if(B.rating > A.rating)
							R.remove_from_storage(B, src)
							R.handle_item_insertion(A, 1)
							component_parts -= A
							component_parts += B
							B.loc = null
							to_chat(user, "<span class='notice'>[A.name] replaced with [B.name].</span>")
							break
				update_icon()
				RefreshParts()
		else
			to_chat(user, "<span class='notice'>Following parts detected in the machine:</span>")
			for(var/var/obj/item/C in component_parts) //var/var/obj/item/C?
				to_chat(user, "<span class='notice'>    [C.name]</span>")
		return
*/

	if(istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/modular_computer/pda))
		if(!check_access(W))
			to_chat(user, "<span class='warning'>Access Denied.</span>")
			return
		if((!locked) || (isnull(occupant)))
			return
		if((occupant.health < -20) && (occupant.stat != 2))
			to_chat(user, "<span class='warning'>Access Refused.</span>")
			return
		else
			locked = 0
			to_chat(user, "System unlocked.")
	else if(istype(W,/obj/item/weapon/reagent_containers/glass))
		if(LAZYLEN(containers) >= container_limit)
			to_chat(user, "<span class='warning'>\The [src] has too many containers loaded!</span>")
		else if(do_after(user, 1 SECOND))
			user.visible_message("[user] has loaded \the [W] into \the [src].", "You load \the [W] into \the [src].")
			containers += W
			user.drop_item()
			W.forceMove(src)
		return
	else if(W.iswrench())
		if(locked && (anchored || occupant))
			to_chat(user, "<span class='warning'>Can not do that while [src] is in use.</span>")
		else
			if(anchored)
				anchored = 0
				connected.pods -= src
				connected = null
			else
				anchored = 1
			playsound(src, W.usesound, 100, 1)
			if(anchored)
				user.visible_message("[user] secures [src] to the floor.", "You secure [src] to the floor.")
			else
				user.visible_message("[user] unsecures [src] from the floor.", "You unsecure [src] from the floor.")
	else if(istype(W, /obj/item/device/multitool))
		var/obj/item/device/multitool/M = W
		M.connecting = src
		to_chat(user, "<span class='notice'>You load connection data from [src] to [M].</span>")
		M.update_icon()
		return
	else
		..()

/obj/machinery/clonepod/emag_act(var/remaining_charges, var/mob/user)
	if(isnull(occupant))
		return
	to_chat(user, "You force an emergency ejection.")
	locked = 0
	go_out()
	return 1

//Put messages in the connected computer's temp var for display.
/obj/machinery/clonepod/proc/connected_message(var/message)
	if((isnull(connected)) || (!istype(connected, /obj/machinery/computer/cloning)))
		return 0
	if(!message)
		return 0

	connected.temp = "[name] : [message]"
	connected.updateUsrDialog()
	return 1

/obj/machinery/clonepod/RefreshParts()
	..()
	var/rating = 0
	for(var/obj/item/weapon/stock_parts/P in component_parts)
		if(istype(P, /obj/item/weapon/stock_parts/scanning_module) || istype(P, /obj/item/weapon/stock_parts/manipulator))
			rating += P.rating

	heal_level = rating * 10 - 20
	heal_rate = round(rating / 4)

/obj/machinery/clonepod/verb/eject()
	set name = "Eject Cloner"
	set category = "Object"
	set src in oview(1)

	if(usr.stat != 0)
		return
	go_out()
	add_fingerprint(usr)
	return

/obj/machinery/clonepod/proc/go_out()
	if(locked)
		return

	if(mess) //Clean that mess and dump those gibs!
		mess = 0
		gibs(src.loc)
		update_icon()
		return

	if(!(occupant))
		return

	if(occupant.client)
		occupant.client.eye = occupant.client.mob
		occupant.client.perspective = MOB_PERSPECTIVE
	occupant.loc = src.loc
	eject_wait = 0 //If it's still set somehow.
	if(ishuman(occupant)) //Need to be safe.
		var/mob/living/carbon/human/patient = occupant
		if(!(patient.species.species_flags & SPECIES_FLAG_NO_SCAN)) //If, for some reason, someone makes a genetically-unalterable clone, let's not make them permanently disabled.
			domutcheck(occupant) //Waiting until they're out before possible transforming.
	occupant = null

	update_icon()
	return

// Returns the total amount of biomass reagent in all of the pod's stored containers
/obj/machinery/clonepod/proc/get_biomass()
	var/biomass_count = 0
	if(LAZYLEN(containers))
		for(var/obj/item/weapon/reagent_containers/glass/G in containers)
			for(var/datum/reagent/R in G.reagents.reagent_list)
				if(R.id == "biomass")
					biomass_count += R.volume

	return biomass_count

// Removes [amount] biomass, spread across all containers. Doesn't have any check that you actually HAVE enough biomass, though.
/obj/machinery/clonepod/proc/remove_biomass(var/amount = CLONE_BIOMASS)		//Just in case it doesn't get passed a new amount, assume one clone
	var/to_remove = 0	// Tracks how much biomass has been found so far
	if(LAZYLEN(containers))
		for(var/obj/item/weapon/reagent_containers/glass/G in containers)
			if(to_remove < amount)	//If we have what we need, we can stop. Checked every time we switch beakers
				for(var/datum/reagent/R in G.reagents.reagent_list)
					if(R.id == "biomass")		// Finds Biomass
						var/need_remove = max(0, amount - to_remove)	//Figures out how much biomass is in this container
						if(R.volume >= need_remove)						//If we have more than enough in this beaker, only take what we need
							R.remove_self(need_remove)
							to_remove = amount
						else											//Otherwise, take everything and move on
							to_remove += R.volume
							R.remove_self(R.volume)
					else
						continue
			else
				return 1
	return 0

// Empties all of the beakers from the cloning pod, used to refill it
/obj/machinery/clonepod/verb/empty_beakers()
	set name = "Eject Beakers"
	set category = "Object"
	set src in oview(1)

	if(usr.stat != 0)
		return

	add_fingerprint(usr)
	drop_beakers()
	return

// Actually does all of the beaker dropping
// Returns 1 if it succeeds, 0 if it fails. Added in case someone wants to add messages to the user.
/obj/machinery/clonepod/proc/drop_beakers()
	if(LAZYLEN(containers))
		var/turf/T = get_turf(src)
		if(T)
			for(var/obj/item/weapon/reagent_containers/glass/G in containers)
				G.forceMove(T)
				containers -= G
		return	1
	return 0

/obj/machinery/clonepod/proc/malfunction()
	if(occupant)
		connected_message("Critical Error!")
		mess = 1
		update_icon()
		occupant.ghostize()
		spawn(5)
			qdel(occupant)
	return

/obj/machinery/clonepod/relaymove(mob/user as mob)
	if(user.stat)
		return
	go_out()
	return

/obj/machinery/clonepod/emp_act(severity)
	if(prob(100/severity))
		malfunction()
	..()

/obj/machinery/clonepod/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/atom/movable/A as mob|obj in src)
				A.loc = src.loc
				ex_act(severity)
			qdel(src)
			return
		if(2.0)
			if(prob(50))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
				qdel(src)
				return
		if(3.0)
			if(prob(25))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
				qdel(src)
				return
		else
	return

/obj/machinery/clonepod/update_icon()
	..()
	icon_state = "pod_0"
	if(occupant && !(stat & NOPOWER))
		icon_state = "pod_1"
	else if(mess)
		icon_state = "pod_g"


/obj/machinery/clonepod/full/New()
	..()
	for(var/i = 1 to container_limit)
		containers += new /obj/item/weapon/reagent_containers/glass/bottle/biomass(src)

//Health Tracker Implant

/obj/item/weapon/implant/health
	name = "health implant"
	var/healthstring = ""

/obj/item/weapon/implant/health/proc/sensehealth()
	if(!implanted)
		return "ERROR"
	else
		if(isliving(implanted))
			var/mob/living/L = implanted
			healthstring = "[round(L.getOxyLoss())] - [round(L.getFireLoss())] - [round(L.getToxLoss())] - [round(L.getBruteLoss())]"
		if(!healthstring)
			healthstring = "ERROR"
		return healthstring

//Disk stuff.
//The return of data disks?? Just for transferring between genetics machine/cloning machine.
//TO-DO: Make the genetics machine accept them.
/obj/item/weapon/disk/data
	name = "Cloning Data Disk"
	icon = 'icons/obj/cloning.dmi'
	icon_state = "datadisk0" //Gosh I hope syndies don't mistake them for the nuke disk.
	item_state = "card-id"
	w_class = ITEM_SIZE_SMALL
	var/datum/dna2/record/buf = null
	var/read_only = 0 //Well,it's still a floppy disk

/obj/item/weapon/disk/data/proc/initializeDisk()
	buf = new
	buf.dna=new

/obj/item/weapon/disk/data/demo
	name = "data disk - 'God Emperor of Mankind'"
	read_only = 1

	New()
		initializeDisk()
		buf.types=DNA2_BUF_UE|DNA2_BUF_UI
		//data = "066000033000000000AF00330660FF4DB002690"
		//data = "0C80C80C80C80C80C8000000000000161FBDDEF" - Farmer Jeff
		buf.dna.real_name="God Emperor of Mankind"
		buf.dna.unique_enzymes = md5(buf.dna.real_name)
		buf.dna.UI=list(0x066,0x000,0x033,0x000,0x000,0x000,0xAF0,0x033,0x066,0x0FF,0x4DB,0x002,0x690)
		//buf.dna.UI=list(0x0C8,0x0C8,0x0C8,0x0C8,0x0C8,0x0C8,0x000,0x000,0x000,0x000,0x161,0xFBD,0xDEF) // Farmer Jeff
		buf.dna.UpdateUI()

/obj/item/weapon/disk/data/monkey
	name = "data disk - 'Mr. Muggles'"
	read_only = 1

	New()
		..()
		initializeDisk()
		buf.types=DNA2_BUF_SE
		var/list/new_SE=list(0x098,0x3E8,0x403,0x44C,0x39F,0x4B0,0x59D,0x514,0x5FC,0x578,0x5DC,0x640,0x6A4)
		for(var/i=new_SE.len;i<=DNA_SE_LENGTH;i++)
			new_SE += rand(1,1024)
		buf.dna.SE=new_SE
		buf.dna.SetSEValueRange(GLOB.MONKEYBLOCK,0xDAC, 0xFFF)

/obj/item/weapon/disk/data/New()
	..()
	var/diskcolor = pick(0,1,2)
	icon_state = "datadisk[diskcolor]"

/obj/item/weapon/disk/data/attack_self(mob/user as mob)
	read_only = !read_only
	to_chat(user, "You flip the write-protect tab to [read_only ? "protected" : "unprotected"].")

/obj/item/weapon/disk/data/examine(mob/user)
	..(user)
	to_chat(user, text("The write-protect tab is set to [read_only ? "protected" : "unprotected"]."))
	return

/*
 *	Diskette Box
 */

/obj/item/weapon/storage/box/disks
	name = "Diskette Box"
	icon_state = "disk_kit"

/obj/item/weapon/storage/box/disks/New()
	..()
	new /obj/item/weapon/disk/data(src)
	new /obj/item/weapon/disk/data(src)
	new /obj/item/weapon/disk/data(src)
	new /obj/item/weapon/disk/data(src)
	new /obj/item/weapon/disk/data(src)
	new /obj/item/weapon/disk/data(src)
	new /obj/item/weapon/disk/data(src)

/*
 *	Manual -- A big ol' manual.
 */

/obj/item/weapon/paper/Cloning
	name = "H-87 Cloning Apparatus Manual"
	info = {"<h4>Getting Started</h4>
	Congratulations, your station has purchased the H-87 industrial cloning device!<br>
	Using the H-87 is almost as simple as brain surgery! Simply insert the target humanoid into the scanning chamber and select the scan option to create a new profile!<br>
	<b>That's all there is to it!</b><br>
	<i>Notice, cloning system cannot scan inorganic life or small primates.  Scan may fail if subject has suffered extreme brain damage.</i><br>
	<p>Clone profiles may be viewed through the profiles menu. Scanning implants a complementary HEALTH MONITOR IMPLANT into the subject, which may be viewed from each profile.
	Profile Deletion has been restricted to \[Station Head\] level access.</p>
	<h4>Cloning from a profile</h4>
	Cloning is as simple as pressing the CLONE option at the bottom of the desired profile.<br>
	Per your company's EMPLOYEE PRIVACY RIGHTS agreement, the H-87 has been blocked from cloning crewmembers while they are still alive.<br>
	<br>
	<p>The provided CLONEPOD SYSTEM will produce the desired clone.  Standard clone maturation times (With SPEEDCLONE technology) are roughly 90 seconds.
	The cloning pod may be unlocked early with any \[Medical Researcher\] ID after initial maturation is complete.</p><br>
	<i>Please note that resulting clones may have a small DEVELOPMENTAL DEFECT as a result of genetic drift.</i><br>
	<h4>Profile Management</h4>
	<p>The H-87 (as well as your station's standard genetics machine) can accept STANDARD DATA DISKETTES.
	These diskettes are used to transfer genetic information between machines and profiles.
	A load/save dialog will become available in each profile if a disk is inserted.</p><br>
	<i>A good diskette is a great way to counter aforementioned genetic drift!</i><br>
	<br>
	<font size=1>This technology produced under license from Thinktronic Systems, LTD.</font>"}

//SOME SCRAPS I GUESS
/* EMP grenade/spell effect
		if(istype(A, /obj/machinery/clonepod))
			A:malfunction()
*/
