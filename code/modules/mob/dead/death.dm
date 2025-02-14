/mob/dead
	var/appearance_backup //so they recover their original appearance when de-cultified

/mob/dead/dust()	//ghosts can't be vaporised.
	return

/mob/dead/gib()		//ghosts can't be gibbed.
	return

/mob/dead/cultify(var/obj/machinery/singularity/narsie/N)
	if (N)//cultified by Nar-Sie
		if(iscultist(src) && client && !isantagbanned(src) && !jobban_isbanned(src, CULTIST))
			var/mob/living/simple_animal/construct/harvester/perfect/new_body = new (loc)
			new_body.name = "[mind.name] the Harvester"
			new_body.real_name = mind.name
			mind.transfer_to(new_body)
			new_body.key = mind.key
			new_body.DisplayUI("Cultist")
			return
	if(invisibility != 0)
		appearance_backup = appearance
		icon = 'icons/mob/mob.dmi'
		icon_state = "ghost-narsie"
		overlays = 0
		if(mind && mind.current)
			if(istype(mind.current, /mob/living/carbon/human/))	//dressing our ghost with a few items that he was wearing just before dying
				var/mob/living/carbon/human/H = mind.current	//note that ghosts of players that died more than a few seconds before meeting nar-sie won't have any of these overlays
				//instead of just adding an overlay of the body's uniform and suit, we'll first process them a bit so the leg part is mostly erased, for a ghostly look.
				overlays += crop_human_suit_and_uniform(mind.current)
				overlays += H.overlays_standing[ID_LAYER]
				overlays += H.overlays_standing[EARS_LAYER]
				overlays += H.overlays_standing[GLASSES_LAYER]
				overlays += H.overlays_standing[GLASSES_OVER_HAIR_LAYER]
				overlays += H.overlays_standing[BELT_LAYER]
				overlays += H.overlays_standing[BACK_LAYER]
				overlays += H.overlays_standing[HEAD_LAYER]
				overlays += H.overlays_standing[HANDCUFF_LAYER]
		invisibility = 0
		alpha = 0
		animate(src, alpha = 127, time = 0.5 SECONDS)
		//to_chat(src, "<span class='sinister'>Even as a non-corporal being, you can feel Nar-Sie's presence altering you. You are now visible to everyone.</span>")
		flick("rune_seer",src)

/mob/dead/proc/decultify()
	if(invisibility == 0)
		invisibility = 60
		anim(target = loc, a_icon = 'icons/effects/160x160.dmi', flick_anim = "incense", offX = -WORLD_ICON_SIZE*2+pixel_x, offY = -WORLD_ICON_SIZE*2+pixel_y)
		if (appearance_backup)
			appearance = appearance_backup

/mob/dead/update_canmove()
	return

/mob/dead/blob_act()
	return

var/list/astral_clothing_cache = list()
//returns an image featuring the mob's uniform and suit with its legs faded out
//might be nice later to make a version of this proc for regular ghosts, but for now cultified ghosts will use it as well
/proc/crop_human_suit_and_uniform(var/mob/living/carbon/human/body)
	if (!body)
		return

	var/entry = "astral_clothing_[body.w_uniform ? "\ref[body.w_uniform]" : "no-uniforum"]_[body.wear_suit ? "\ref[body.wear_suit]" : "no-suit"]"

	if (entry in astral_clothing_cache)
		return astral_clothing_cache[entry]

	var/image/human_clothes = image('icons/mob/mob.dmi',"blank")

	var/icon/temp

	//couldn't just re-use the code from human/update_icons.dm because we need to manipulate an /icon, not an /image
	//it's not perfect and won't get the accessories or blood stains but that's good enough for the effect we're trying to get here
	if(body.w_uniform)
		var/uniform_icon = 'icons/mob/uniform.dmi'
		var/uniform_icon_state = "grey_s"

		if(body.w_uniform._color)
			uniform_icon_state = "[body.w_uniform._color]_s"

		if(((M_FAT in body.mutations) && (body.species.anatomy_flags & CAN_BE_FAT)) || body.species.anatomy_flags & IS_BULKY)
			if(body.w_uniform.clothing_flags&ONESIZEFITSALL)
				uniform_icon = 'icons/mob/uniform_fat.dmi'

		if(body.w_uniform.wear_override)
			uniform_icon = body.w_uniform.wear_override

		var/obj/item/clothing/under/under_uniform = body.w_uniform
		if(body.species.name in under_uniform.species_fit) //Allows clothes to display differently for multiple species
			if(body.species.uniform_icons && has_icon(body.species.uniform_icons, "[body.w_uniform.icon_state]_s"))
				uniform_icon = body.species.uniform_icons

		if((body.gender == FEMALE) && (body.w_uniform.clothing_flags & GENDERFIT)) //genderfit
			if(has_icon(uniform_icon, "[body.w_uniform.icon_state]_s_f"))
				uniform_icon_state = "[body.w_uniform.icon_state]_s_f"

		if(body.w_uniform.icon_override)
			uniform_icon	= body.w_uniform.icon_override

		var/icon/I_uniform = icon(uniform_icon,uniform_icon_state)
		var/icon/mask = icon('icons/mob/mob.dmi',"ajourney_mask")

		mask.Blend(I_uniform, ICON_MULTIPLY)

		if (body.wear_suit)
			temp = mask
		else
			human_clothes.overlays += image(mask)

	if(body.wear_suit)
		var/suit_icon = body.wear_suit.icon_override ? body.wear_suit.icon_override : 'icons/mob/suit.dmi'
		var/suit_icon_state = body.wear_suit.icon_state

		var/datum/species/SP = body.species

		if((((M_FAT in body.mutations) && (SP.anatomy_flags & CAN_BE_FAT)) || (SP.anatomy_flags & IS_BULKY)) && !(body.wear_suit.icon_override))
			if(body.wear_suit.clothing_flags&ONESIZEFITSALL)
				suit_icon	= 'icons/mob/suit_fat.dmi'
				if(SP.name in body.wear_suit.species_fit) //Allows clothes to display differently for multiple species
					if(SP.fat_wear_suit_icons && has_icon(SP.fat_wear_suit_icons, body.wear_suit.icon_state))
						suit_icon = SP.wear_suit_icons
				if((body.gender == FEMALE) && (body.wear_suit.clothing_flags & GENDERFIT)) //genderfit
					if(has_icon(suit_icon,"[body.wear_suit.icon_state]_f"))
						suit_icon_state = "[body.wear_suit.icon_state]_f"
		else
			if(SP.name in body.wear_suit.species_fit) //Allows clothes to display differently for multiple species
				if(SP.wear_suit_icons && has_icon(SP.wear_suit_icons, body.wear_suit.icon_state))
					suit_icon = SP.wear_suit_icons
			if((body.gender == FEMALE) && (body.wear_suit.clothing_flags & GENDERFIT)) //genderfit
				if(has_icon(suit_icon,"[body.wear_suit.icon_state]_f"))
					suit_icon_state = "[body.wear_suit.icon_state]_f"

		var/icon/I_suit = icon(suit_icon,suit_icon_state)
		var/icon/mask = icon('icons/mob/mob.dmi',"ajourney_mask")

		mask.Blend(I_suit, ICON_MULTIPLY)

		if (temp)
			temp.Blend(mask, ICON_OVERLAY)
			human_clothes.overlays += image(temp)
		else
			human_clothes.overlays += image(mask)

	astral_clothing_cache[entry] = human_clothes

	return human_clothes
